# Переменные задают основные параметры проекта

locals {

#  Регион Где будем создавать ВМ

    region-of-project            = "us-east-1"

# Указываем, в какой зоне создаём ВМ

    Subnet_availability_zones-1  = "us-east-1a"
    Subnet_availability_zones-2  = "us-east-1b"

# Указываем типы ВМ

    rproxy_type_vm               = "t2.micro"
    nodes_type_vm                = "t2.micro"
    web_node_type_vm             = "t2.micro"
    grafana_node_type_vm         = "t2.micro"
    db_node_type_vm              = "t2.small"
    gitlab_node_type_vm          = "t3.xlarge"
    gitlabrunner_node_type_vm    = "t3.micro"
    monitoring_node_type_vm      = "t3.micro"

# Указываем из каких образов будем создавать ВМ

    VM_instance_ami              = data.aws_ami.ubuntu.id

# Указываем все диапазоны и отдельные ip-адреса

    cidr_vpc                     = "192.168.0.0/16"
    cidr_public_subnet           = "192.168.0.0/24"
    cidr_private_subnet-1        = "192.168.1.0/24"
    cidr_private_subnet-2        = "192.168.2.0/24"

# Имя файла ключа. Он будет создан с расширением pem
    ssh_key_filename             = "alexander-key-to-aws"

# Параметры сервера обратного прокси

    rproxy_local_ip              = "192.168.0.4"
    rproxy_hostname              = "citytours.ge"
    domain_name                  = "citytours.ge"

#    start_db_node_local_ip    = "192.168.1.4"

# Параметры ВМ для кластера mysql

    db_nodes_local_ip            = ["192.168.1.4", "192.168.1.5"]
    db_nodes_hostname            = ["db01.citytours.ge", "db02.citytours.ge"]

    db01_node_local_ip           = local.db_nodes_local_ip[0]
    db01_node_hostname           = local.db_nodes_hostname[0]

    db02_node_local_ip           = local.db_nodes_local_ip[1]
    db02_node_hostname           = local.db_nodes_hostname[1]

# Параметры создаваемой БД и настроек сайта

    db_nodes_mysql_root_password = "123456"
    db_wordpress_dbhost          = local.db01_node_hostname
    db_wordpress_dbname          = "wordpress"
    db_wordpress_dbusername      = "wordpress"
    db_wordpress_dbuserpassword  = "wordpress"

# Параметры Веб-сервера

    web_node_local_ip            = "192.168.1.6"
    web_node_hostname            = "app.citytours.ge"

# Параметры сервера Gitlab и Gitlab runner

    gitlab_node_local_ip         = "192.168.1.7"
    gitlab_node_hostname         = "gitlab.citytours.ge"
    gitlab_root_password         = "2222222222"
    gitlab_root_token            = "33333333333333333333"
    gitlab_runner_init_token     = "4444444444"
    gitlab_project_name          = "Website CI/CD"

    gitlabrunner_node_local_ip   = "192.168.1.8"
    gitlabrunner_node_hostname   = "runner.citytours.ge"

# Параметры сервера мониторинга

    monitoring_node_local_ip     = "192.168.1.9"
    monitoring_node_hostname     = "monitoring.citytours.ge"

}


# Настраиваем AWS Provider
provider "aws" {
  region = local.region-of-project
}


# Ищем свежайший образ Ubuntu server
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


# Создаём закрытый ключ
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Создаём объект Ключевой пары
resource "aws_key_pair" "kp" {
#  key_name   = "alexander-key-to-aws"       # Create "myKey" to AWS!!
   key_name   = local.ssh_key_filename       # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

# Копипуем содержимое ключа к себе в файл и назначаем корректные права
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ~/.ssh/${aws_key_pair.kp.key_name}.pem && chmod 600 ~/.ssh/${aws_key_pair.kp.key_name}.pem"
  }

# Копипуем содержимое ключа в файл для копирования ансиблом в некоторве ВМ
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ../ansible/roles/common/files/${aws_key_pair.kp.key_name}.pem"
  }
}