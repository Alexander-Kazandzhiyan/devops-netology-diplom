
# Терраформ создаёт inventory файл для ansible для настройки db_nodes
resource "local_file" "inventory_db_nodes" {
  content = <<-DOC
# Ansible inventory containing variable values from Terraform.
# Generated by Terraform.
[nodes:children]
db_nodes
[db_nodes]

%{ for i in [0,1] }
db0${i+1} ansible_host=${aws_instance.diplom-vm-db_node[i].private_ip} ansible_ssh_private_key_file=~/.ssh/${aws_key_pair.kp.key_name}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q ubuntu@${aws_instance.diplom-vm-rproxy.public_ip} -i ~/.ssh/${aws_key_pair.kp.key_name}.pem -oStrictHostKeyChecking=accept-new"'
%{ endfor }
    DOC
  filename = "../ansible/db_nodes/inventory_db_nodes"

  depends_on = [
    aws_instance.diplom-vm-db_node,
  ]
}
