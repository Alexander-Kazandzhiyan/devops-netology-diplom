# Терраформ создаёт inventory файл для ansible

resource "local_file" "inventory_full1" {
  content = <<-DOC
# Ansible inventory containing variable values from Terraform.
# Generated by Terraform.
[nodes:children]
db_nodes
gitlab_nodes
gitlabrunner_nodes
monitoring_nodes
rproxys
web_nodes

[db_nodes]
%{ for i in [0,1] }
db0${i+1} ansible_host=${aws_instance.diplom-vm-db_node[i].private_ip} ansible_ssh_private_key_file=~/.ssh/${aws_key_pair.kp.key_name}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q ubuntu@${aws_instance.diplom-vm-rproxy.public_ip} -i ~/.ssh/${aws_key_pair.kp.key_name}.pem -oStrictHostKeyChecking=accept-new"'
%{ endfor }

[gitlab_nodes]
gitlab_node ansible_host=${aws_instance.diplom-vm-gitlab_node.private_ip} ansible_ssh_private_key_file=~/.ssh/${aws_key_pair.kp.key_name}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q ubuntu@${aws_instance.diplom-vm-rproxy.public_ip} -i ~/.ssh/${aws_key_pair.kp.key_name}.pem -oStrictHostKeyChecking=accept-new"'

[gitlabrunner_nodes]
gitlabrunner_node ansible_host=${aws_instance.diplom-vm-gitlabrunner_node.private_ip} ansible_ssh_private_key_file=~/.ssh/${aws_key_pair.kp.key_name}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q ubuntu@${aws_instance.diplom-vm-rproxy.public_ip} -i ~/.ssh/${aws_key_pair.kp.key_name}.pem -oStrictHostKeyChecking=accept-new"'

[monitoring_nodes]
monitoring_node ansible_host=${aws_instance.diplom-vm-monitoring_node.private_ip} ansible_ssh_private_key_file=~/.ssh/${aws_key_pair.kp.key_name}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q ubuntu@${aws_instance.diplom-vm-rproxy.public_ip} -i ~/.ssh/${aws_key_pair.kp.key_name}.pem -oStrictHostKeyChecking=accept-new"'

[rproxys]
rproxy ansible_host=${aws_instance.diplom-vm-rproxy.public_ip} ansible_ssh_private_key_file=~/.ssh/${aws_key_pair.kp.key_name}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[web_nodes]
web_node ansible_host=${aws_instance.diplom-vm-web_node.private_ip} ansible_ssh_private_key_file=~/.ssh/${aws_key_pair.kp.key_name}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q ubuntu@${aws_instance.diplom-vm-rproxy.public_ip} -i ~/.ssh/${aws_key_pair.kp.key_name}.pem -oStrictHostKeyChecking=accept-new"'

    DOC
  filename = "../ansible/inventory/inventory_full"


  depends_on = [
    aws_instance.diplom-vm-db_node,
    aws_instance.diplom-vm-gitlab_node, aws_instance.diplom-vm-gitlabrunner_node,
    aws_instance.diplom-vm-monitoring_node,
    aws_instance.diplom-vm-rproxy,
    aws_instance.diplom-vm-web_node
  ]
}