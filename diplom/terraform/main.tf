# Все переменные (параметры проекта) вынесены в файл variables.tf

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
  owners = ["099720109477"]
}

# Создаём закрытый ключ
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Создаём объект Ключевой пары
resource "aws_key_pair" "kp" {
  key_name   = local.ssh_key_filename
  public_key = tls_private_key.pk.public_key_openssh

# Копипуем содержимое ключа к себе в файл и назначаем корректные права
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ~/.ssh/${aws_key_pair.kp.key_name}.pem && chmod 600 ~/.ssh/${aws_key_pair.kp.key_name}.pem"
  }

# Копипуем содержимое ключа в файл в отдельную папку для копирования ансиблом в некоторве ВМ
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ../ansible/roles/common/files/${aws_key_pair.kp.key_name}.pem"
  }
}