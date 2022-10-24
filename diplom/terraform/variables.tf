# Переменные задают основные параметры проекта

# Внимание! Некоторые переменные, использованные в Terraform, также используются в Ansible, 
# поэтому они дублируются в файле ../ansible/variables.yaml
# Меняя значения, следите за синхронностью изменений!

locals {

#========== Параметры, касающиеся создаваемой инфраструктуры в AWS

#  Регион Где будем создавать ВМ
    region-of-project            = "us-east-1"

# Указываем, в какой зоне создаём подсети, и соответственно там же будут и создаваемые ВМ
    Subnet_availability_zones-1  = "us-east-1a"
    Subnet_availability_zones-2  = "us-east-1b"

# Указываем типы ВМ. Мы проявили вольность и выбрали максимально дешёвые ВМ, возможно ниже по мощности, чем заявленные в задании проекта.
# Тем не менее этого минимально достаточно для выполнения проекта. А типы всегда можно поменять в большую сторону.
    rproxy_type_vm               = "t2.micro"
    nodes_type_vm                = "t2.micro"
    web_node_type_vm             = "t2.micro"
    grafana_node_type_vm         = "t2.micro"
    db_node_type_vm              = "t2.small"
    gitlab_node_type_vm          = "t3.xlarge"
    gitlabrunner_node_type_vm    = "t3.micro"
    monitoring_node_type_vm      = "t3.micro"

# Указываем из каких образов будем создавать ВМ
# В Качестве OS выбрана Ubuntu. Свежайший образ, которой мы ищем при развёртывании инфраструктуры
    VM_instance_ami              = data.aws_ami.ubuntu.id

# Указываем все диапазоны ip-адресов Виртуальной частной облачной сети VPC AWS и пдсетей

    cidr_vpc                     = "192.168.0.0/16"
    cidr_public_subnet           = "192.168.0.0/24"
    cidr_private_subnet-1        = "192.168.1.0/24"
    cidr_private_subnet-2        = "192.168.2.0/24"


#======== Параметры касающиеся создания ВМ

# Имя файла ключа. Он будет создан с расширением pem
    ssh_key_filename             = "alexander-key-to-aws"

# Токен для управления CloudFlare DNS
    cloudflare_api_token = "t44iHmKOjkxjsRvyyLzw27jCQb1WMT2DSr6IUgkI"

# Доменное имя, использованное в проекте
    domain_name                  = "citytours.ge"


# Параметры для ВМ Обратного прокси

    rproxy_local_ip              = "192.168.0.4"
    rproxy_hostname              = "citytours.ge"

# Параметры ВМ для кластера mysql

    db_nodes_local_ip            = ["192.168.1.4", "192.168.1.5"]
    db_nodes_hostname            = ["db01.citytours.ge", "db02.citytours.ge"]

    db01_node_local_ip           = local.db_nodes_local_ip[0]
    db01_node_hostname           = local.db_nodes_hostname[0]

    db02_node_local_ip           = local.db_nodes_local_ip[1]
    db02_node_hostname           = local.db_nodes_hostname[1]

# Параметры Веб-сервера

    web_node_local_ip            = "192.168.1.6"
    web_node_hostname            = "app.citytours.ge"

# Параметры сервера Gitlab и Gitlab runner

    gitlab_node_local_ip         = "192.168.1.7"
    gitlab_node_hostname         = "gitlab.citytours.ge"

    gitlabrunner_node_local_ip   = "192.168.1.8"
    gitlabrunner_node_hostname   = "runner.citytours.ge"

# Параметры сервера мониторинга

    monitoring_node_local_ip     = "192.168.1.9"
    monitoring_node_hostname     = "monitoring.citytours.ge"

}
