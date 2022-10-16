
# Терраформ создаёт файл hosts со списком всех серверов для внутренноего употребления на этих серверах
resource "local_file" "hosts" {
  content = <<-DOC
# this hosts creates in Terraform and was installed via Ansible.
127.0.0.1 localhost
${aws_instance.diplom-vm-rproxy.private_ip} ${local.rproxy_hostname}
${aws_instance.diplom-vm-gitlab_node.private_ip} ${local.gitlab_node_hostname}
${aws_instance.diplom-vm-web_node.private_ip} ${local.web_node_hostname}
%{ for i in [0,1] }
${aws_instance.diplom-vm-db_node[i].private_ip} ${local.db_nodes_hostname[i]}
%{ endfor }
${aws_instance.diplom-vm-gitlabrunner_node.private_ip} ${local.gitlabrunner_node_hostname}
    DOC
  filename = "../ansible/commonfiles/hosts"

  depends_on = [
    aws_instance.diplom-vm-rproxy,
    aws_instance.diplom-vm-db_node,
    aws_instance.diplom-vm-web_node,
    aws_instance.diplom-vm-gitlab_node,
    aws_instance.diplom-vm-gitlabrunner_node,
#    aws_instance.diplom-vm-grafana_node
#${aws_instance.diplom-vm-grafana_node.private_ip} ${local.grafana_node_hostname}
#${aws_instance.diplom-vm-web_node.private_ip} ${local.web_node_hostname}
#%{ for i in [0,1] }
#${aws_instance.diplom-vm-db_node[i].private_ip} ${local.db_nodes_hostname[i]}
#%{ endfor }
  ]
}
