##############  Создаём группы безопасности в AWS   ################
### По-умолчанию для ВМ в AWS любой траффик запрещён. 
### Чтобы траффик пошёл, необходимо создать правила, описывающие разрешённые сетевые взаимодействия для всех ВМ

# Создаём группу безопасности для доступа по ssh
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.diplom-vpc.id

  ingress {
    description      = "SSH to VMs"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
  }

  tags = {
    Name = "diplom_allow_ssh"
  }
}

# Создаём группу безопасности для доступа от нас куда угодно
resource "aws_security_group" "allow_all_output" {
  name        = "allow_output"
  description = "Allow All Output traffic"
  vpc_id      = aws_vpc.diplom-vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "diplom_allow_all_output"
  }
}

# Создаём группу безопасности для разрешения пинга
resource "aws_security_group" "allow_ping" {
  name        = "allow_ping"
  description = "Allow ping"
  vpc_id      = aws_vpc.diplom-vpc.id

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "diplom_allow_ping"
  }
}

# Создаём группу безопасности для разрешения любой связи внутри нашей VPC
resource "aws_security_group" "allow_internal_traffic" {
  name        = "allow_internal_traffic"
  description = "Allow internal_traffic"
  vpc_id      = aws_vpc.diplom-vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
     cidr_blocks      = [local.cidr_vpc]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
     cidr_blocks      = [local.cidr_vpc]
  }

  tags = {
    Name = "diplom_allow_internal_traffic"
  }
}

# Создаём группу безопасности для доступа на 80 и 443 порт
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.diplom-vpc.id

  ingress {
    description      = "http to VMs"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
  }
  ingress {
    description      = "https to VMs"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
  }

  tags = {
    Name = "diplom_allow_web"
  }
}

