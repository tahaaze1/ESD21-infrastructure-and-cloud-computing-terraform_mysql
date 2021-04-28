# Mysql com Terraform
## Aula 2 Infrastructure and Cloud Computing - Atividade Terraform

## Desafio

> Subir uma máquina virtual no Azure, AWS ou GCP instalando o MySQL e que esteja acessível no host da máquina na porta 3306, usando Terraform. 
Se quiser usar o Ansible para configurar a máquina é interessante mas não obrigatório, pode configurar via script também. 
Enviar a URL GitHub do código.

## Pré-requisitos
- [Terraform](https://www.terraform.io/downloads.html)
- [Azure Cli](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli)

## Instalação
### Método 1
```sh 
git clone https://github.com/luissena/es21-terraform_mysql.git && cd es21-terraform_mysql

terraform init
terraform plan -var 'location=westus2' -var 'admin_username=usermaster' -var 'admin_password=senh@master' -var 'mysql_user_name=usermaster' -var 'mysql_user_pass=senh@master'
terraform apply -var 'location=westus2' -var 'admin_username=usermaster' -var 'admin_password=senh@master' -var 'mysql_user_name=usermaster' -var 'mysql_user_pass=senh@master' -auto-approve

#execute o comando abaixo para obter o endereço IP
terraform output

# para acessar o banco
mysql -h IP -u usermaster -P 3306 -psenh@master

# se precisar acessar a VM use o comando abaixo
ssh usermaster@IP -i private_key.pem
```

### Método 2
Crie um arquivo terraform.tfvars com as variaveis abaixo:

```
#location westus2 ou eastus
location=westus2
#usuario para acesso ssh
admin_username=usermaster
#senha do usuario
admin_password=senh@master
#usuario para acesso ao banco
mysql_user_name=usermaster
#senha para acesso ao banco
mysql_user_pass=senh@master
```

```sh 
git clone https://github.com/luissena/es21-terraform_mysql_ansible.git && cd es21-terraform_mysql_ansible

terraform init
terraform plan
terraform apply -auto-approve

#execute o comando abaixo para obter o endereço IP
terraform output

# para acessar o banco
mysql -h IP -u usermaster -P 3306 -ppassword

# se precisar acessar a VM use o comando abaixo
ssh usermaster@IP -i private_key.pem
```

### Para limpar tudo execute o comando
```sh
terraform destroy -var 'location=westus2' -var 'admin_username=usermaster' -var 'admin_password=p@$$w0rd' -var 'mysql_user_name=usermaster' -var 'mysql_user_pass=senh@master' -auto-approve
```
