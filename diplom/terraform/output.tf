##############  Выведем некоторые параметры проекта по завершении развёртывания инфраструктуры и ВМ  ############

# Получаем данные Региона AWS
data "aws_region" "current" {}

# Выводим регион
output "region" {
  value = data.aws_region.current.id
}

# Выводим ID ВМ rproxy
output "instance_rproxy_id" {
  description = "ID of the RPROXY VM"
  value       = aws_instance.diplom-vm-rproxy.id
}

output "instance_rproxy_local_ip" {
  description = "Local IP address of the RPROXY VM"
  value       = aws_instance.diplom-vm-rproxy.private_ip
}

output "instance_rproxy_public_ip" {
  description = "Public IP address of RPROXY VM"
  value       = aws_instance.diplom-vm-rproxy.public_ip
}
