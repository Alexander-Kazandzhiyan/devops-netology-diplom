# Получаем данные Региона AWS
data "aws_region" "current" {}

# Выводим регион
output "region" {
  value = data.aws_region.current.id
}


# количество  ВМ
#  count = local.VM_instance_count

# Выводим ID ВМ
#output "instance_node01_id" {
#  description = "ID of the EC2 instance"
#  value       = aws_instance.Test-VM-Node01.id
#}

#output "instance_node02_id" {
#  description = "ID of the EC2 instance"
#  value       = aws_instance.Test-VM-Node02.id
#}


#output "instance_node01_local_ip" {
#  description = "Local IP address of the EC2 instance"
#  value       = aws_instance.Test-VM-Node01.private_ip
#}

#output "instance_node02_local_ip" {
#  description = "Local IP address of the EC2 instance"
#  value       = aws_instance.Test-VM-Node02.private_ip
#}


# Выводим ID ВМ rproxy
output "instance_rproxy_id" {
  description = "ID of the RPROXY VM"
  value       = aws_instance.diplom-vm-rproxy.id
}


#output "instance_bastion_subnet" {
#  description = "Subnet of the EC2 instance"
#  value       = aws_instance.Test-VM-Bastion.subnet_id
#}

output "instance_rproxy_local_ip" {
  description = "Local IP address of the RPROXY VM"
  value       = aws_instance.diplom-vm-rproxy.private_ip
}

output "instance_rproxy_public_ip" {
  description = "Public IP address of RPROXY VM"
  value       = aws_instance.diplom-vm-rproxy.public_ip
}
