# Create network interface
resource "azurerm_network_interface" "nic" {
    name                = var.nic_name
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "eth0Config"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.1.11"
        public_ip_address_id          = azurerm_public_ip.publicip.id
    }

    depends_on = [ azurerm_subnet.subnet,
                   azurerm_public_ip.publicip ]
}

resource "azurerm_network_interface_security_group_association" "nicsq" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  depends_on = [ azurerm_network_interface.nic,
                 azurerm_network_security_group.nsg ]
} 

resource "null_resource" "mysql" {
  triggers = {
    order = azurerm_linux_virtual_machine.vm.id
  }

  provisioner "remote-exec" {
    connection {
      type         = "ssh"
      user         = var.admin_username
      private_key  = tls_private_key.ssh_key.private_key_pem
      host         = azurerm_public_ip.publicip.ip_address
  }
  
  inline = [
      "sudo apt update && sudo apt upgrade -y",
      "cd /tmp && wget https://dev.mysql.com/get/mysql-apt-config_0.8.16-1_all.deb",
      "export DEBIAN_FRONTEND='noninteractive'",
      "sudo echo mysql-apt-config mysql-apt-config/select-server select mysql-8.0 | debconf-set-selections",
      "sudo echo mysql-community-server mysql-community-server/root-pass password ${var.mysql_user_pass} | debconf-set-selections",
      "sudo echo mysql-community-server mysql-community-server/re-root-pass password ${var.mysql_user_pass} | debconf-set-selections",
      "sudo -E dpkg -i mysql-apt-config_0.8.16-1_all.deb",
      "sudo apt update -y",
      "sudo -E apt install -y mysql-server",
      "sudo mysql -e \"CREATE USER IF NOT EXISTS '${var.mysql_user_name}'@'%' IDENTIFIED BY '${var.mysql_user_pass}';\"",
      "sudo mysql -e \"GRANT ALL PRIVILEGES ON *.* TO '${var.mysql_user_name}'@'%' WITH GRANT OPTION;\"",
      "sudo systemctl restart mysql"
    ]
  }

}
# Output public IP and private key
output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

output "tls_private_key" {
  sensitive = true
  value     = tls_private_key.ssh_key.private_key_pem
}

resource "local_file" "private_key" {
  content          = tls_private_key.ssh_key.private_key_pem
  filename         = "private_key.pem"
  file_permission  = "0400"
}
terraform {
	required_providers {
		azurerm = {
			source = "hashicorp/azurerm"
			version = ">= 2.26"
		}
	}
	required_version = ">= 0.14.9"
}

provider "azurerm" {
	features {}
}

resource "azurerm_resource_group" "rg" {
	name     = var.rg_name
	location = var.location
}

data "azurerm_public_ip" "ip" {
    name                = azurerm_public_ip.publicip.name
    resource_group_name = azurerm_resource_group.rg.name
    depends_on          = [ azurerm_linux_virtual_machine.vm ]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
    name                = var.public_ip_name
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
    name                = var.nsg_name
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    
    security_rule {
        name                        = "SSH"
        priority                    = 1001
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "22"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }

    security_rule {
        name                        = "MYSQL"
        priority                    = 1002
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "3306"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }

}

#Create a ssh key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create subnet
resource "azurerm_subnet" "subnet" {
    name                  = var.subnet_name
    resource_group_name   = azurerm_resource_group.rg.name
    virtual_network_name  = azurerm_virtual_network.vnet.name
    address_prefixes      = ["10.0.1.0/24"]

    depends_on = [  azurerm_virtual_network.vnet ]
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = var.virtual_network_name
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
    name                  = var.vm_name
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic.id]
    size                  = "Standard_DS1_v2"

   
    os_disk {
        name                  = format("%s-%s",var.vm_name, var.vm_disk_name)
        caching               = "ReadWrite"
        storage_account_type  = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = lookup(var.sku, var.location)
        version   = "latest"
    }

    computer_name  = var.vm_name
    admin_username = var.admin_username
    admin_password = var.admin_password
    disable_password_authentication = true

    admin_ssh_key {
      username   = var.admin_username
      public_key = tls_private_key.ssh_key.public_key_openssh
    }

    depends_on = [ azurerm_network_interface.nic ]
}
