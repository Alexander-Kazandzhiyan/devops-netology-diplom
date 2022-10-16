# Создаём Облачную сеть
resource "aws_vpc" "diplom-vpc" {
  cidr_block = local.cidr_vpc

  tags = {
    Name = "diplom-vpc"
  }
}

# Создаём внутреннюю подсеть Private1
resource "aws_subnet" "diplom-private-subnet-1" {
  vpc_id            = aws_vpc.diplom-vpc.id
  cidr_block        = local.cidr_private_subnet-1
  availability_zone = local.Subnet_availability_zones-1

  tags = {
    Name = "diplom-private-Subnet-1"
  }
}

# Создаём внутреннюю подсеть Private2
resource "aws_subnet" "diplom-private-subnet-2" {
  vpc_id            = aws_vpc.diplom-vpc.id
  cidr_block        = local.cidr_private_subnet-2
  availability_zone = local.Subnet_availability_zones-2

  tags = {
    Name = "diplom-private-Subnet-2"
  }
}

# Создаём публичную подсеть Public
resource "aws_subnet" "diplom-public-subnet" {
  vpc_id            = aws_vpc.diplom-vpc.id
  cidr_block        = local.cidr_public_subnet
  availability_zone = local.Subnet_availability_zones-1

  # просим выделять публичные адреса всем объектам в подсети
  map_public_ip_on_launch = true

  tags = {
    Name = "diplom-public-Subnet"
  }
}




# Создаём шлюз в Интернет
resource "aws_internet_gateway" "diplom-igw" {
  vpc_id = aws_vpc.diplom-vpc.id

  tags = {
    Name = "diplom-internet-gateway"
  }
}


# Создаём сетевой интерфейс в public сети для Reverse Proxy
resource "aws_network_interface" "diplom-public-network_interface-rproxy" {

  subnet_id   = aws_subnet.diplom-public-subnet.id
  private_ips = [local.rproxy_local_ip]

  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_all_output.id, aws_security_group.allow_internal_traffic.id, aws_security_group.allow_ping.id, aws_security_group.allow_web.id,]

  tags = {
    Name = "diplom-public-network_interface-rproxy"
  }
}


# Объект - задержка
resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
}


# Создаём Elastic IP  - постоянный публичный адрес для Reverse Proxy
resource "aws_eip" "diplom-elastic-ip-rproxy" {
  vpc = true

  # Направляем этот адрес на интерфейс rproxy в публичной сети и прикрепляем к его адресу в публичной сети
  network_interface         = aws_network_interface.diplom-public-network_interface-rproxy.id
#  associate_with_private_ip = "192.168.0.4"
  associate_with_private_ip = local.rproxy_local_ip

  # Зависимость указана чтоб обеспечить при создании Elastic IP всех нужных сущностей, а также задержку
  depends_on                = [aws_internet_gateway.diplom-igw, aws_network_interface.diplom-public-network_interface-rproxy, null_resource.wait]
}


# создаём дефолтную таблицу маршрутов для выхода в интернет через Interne Gateway
resource "aws_default_route_table" "diplom-default-route-table" {

  default_route_table_id = aws_vpc.diplom-vpc.default_route_table_id
#  vpc_id = aws_vpc.Test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.diplom-igw.id
  }

  depends_on = [aws_internet_gateway.diplom-igw]

  tags = {
    Name = "diplom-default-route-table"
  }
}


# создаём Elastic IP - публичный адрес для использования для NAT Gateway
resource "aws_eip" "diplom-elastic-ip_for_nat-gw" {
  vpc = true
  tags = {
    Name = "diplom-elastic-ip_for_nat-gw"
  }
}

# Создаём NAT Gateway
resource "aws_nat_gateway" "diplom-nat-gw" {
  allocation_id = aws_eip.diplom-elastic-ip_for_nat-gw.id
  subnet_id     = aws_subnet.diplom-public-subnet.id

  tags = {
    Name = "diplom-nat-gw"
  }

  # Создаём зависимость так как NAT Gw нуждается в Internet Gw
  depends_on = [aws_internet_gateway.diplom-igw]
}


# Создаём таблицу маршрутов для выхода в интернет из private subnet через NAT
resource "aws_route_table" "diplom-route-table-private-via-nat" {

  vpc_id = aws_vpc.diplom-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.diplom-nat-gw.id
  }

  tags = {
    Name = "diplom-route-table-private-via-nat"
  }
}

# Создаём привязку Private-1 подсети к таблице маршрутов через NAT
resource "aws_route_table_association" "diplom-private1-to-NAT-route_table-assoc" {
  subnet_id      = aws_subnet.diplom-private-subnet-1.id
  route_table_id = aws_route_table.diplom-route-table-private-via-nat.id
}


 # Создаём сетевой интерфейс в private-1 сети для db0x_node
resource "aws_network_interface" "diplom-private-network_interface-db_node" {

  # Указываем подсеть
  subnet_id   = aws_subnet.diplom-private-subnet-1.id

  count = 2

  # адрес для db_node
#  private_ips = [cidrhost(local.cidr_private_subnet-1, 4+count.index)]
  private_ips = [local.db_nodes_local_ip[count.index]]


  # Подключаем группы безопасности для разрешения разного траффика
  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_all_output.id, aws_security_group.allow_internal_traffic.id, aws_security_group.allow_ping.id, aws_security_group.allow_web.id,]

  tags = {
    Name = "diplom-private-network_interface-db_${count.index}_node"
  }
}

 # Создаём сетевой интерфейс в private-1 сети для web_node
resource "aws_network_interface" "diplom-private-network_interface-web_node" {

  # Указываем подсеть
  subnet_id   = aws_subnet.diplom-private-subnet-1.id

  # адрес для web_node
  private_ips = [local.web_node_local_ip]

  # Подключаем группы безопасности для разрешения разного траффика
  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_all_output.id, aws_security_group.allow_internal_traffic.id, aws_security_group.allow_ping.id, aws_security_group.allow_web.id,]

  tags = {
    Name = "diplom-private-network_interface-web_node"
  }
}

 # Создаём сетевой интерфейс в private-1 сети для gitlab_node
resource "aws_network_interface" "diplom-private-network_interface-gitlab_node" {

  # Указываем подсеть
  subnet_id   = aws_subnet.diplom-private-subnet-1.id

  # адрес для web_node
  private_ips = [local.gitlab_node_local_ip]

  # Подключаем группы безопасности для разрешения разного траффика
  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_all_output.id, aws_security_group.allow_internal_traffic.id, aws_security_group.allow_ping.id, aws_security_group.allow_web.id,]

  tags = {
    Name = "diplom-private-network_interface-gitlab_node"
  }
}

 # Создаём сетевой интерфейс в private-1 сети для gitlabrunner_node
resource "aws_network_interface" "diplom-private-network_interface-gitlabrunner_node" {

  # Указываем подсеть
  subnet_id   = aws_subnet.diplom-private-subnet-1.id

  # адрес для web_node
  private_ips = [local.gitlabrunner_node_local_ip]

  # Подключаем группы безопасности для разрешения разного траффика
  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_all_output.id, aws_security_group.allow_internal_traffic.id, aws_security_group.allow_ping.id, aws_security_group.allow_web.id,]

  tags = {
    Name = "diplom-private-network_interface-gitlabrunner_node"
  }
}


 # Создаём сетевой интерфейс в private-1 сети для grafana_node
resource "aws_network_interface" "diplom-private-network_interface-grafana_node" {

  # Указываем подсеть
  subnet_id   = aws_subnet.diplom-private-subnet-1.id

  # адрес для web_node
  private_ips = [local.grafana_node_local_ip]

  # Подключаем группы безопасности для разрешения разного траффика
  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_all_output.id, aws_security_group.allow_internal_traffic.id, aws_security_group.allow_ping.id, aws_security_group.allow_web.id,]

  tags = {
    Name = "diplom-private-network_interface-grafana_node"
  }
}


