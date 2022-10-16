# Организовываем задержку до появления файла inventory и ещё 30 сек
resource "null_resource" "wait_inventory_grafana_node" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    local_file.inventory_grafana_node
  ]
}

# запускаем ansible playbook для донастройки grafana_node
resource "null_resource" "grafana_node_ansible_playbook_prepare_grafananode" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста для назначения на web_node
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_grafana_node.filename} --extra-vars \"grafana_node_hostname=${local.grafana_node_hostname} domain_name=${local.domain_name}  \" ../ansible/grafana_node/provision_grafana_node.yaml -u ubuntu"
  }
  depends_on = [
    null_resource.wait_inventory_grafana_node, aws_instance.diplom-vm-grafana_node, null_resource.rproxy_ansible_playbook
  ]
}

# запускаем ansible playbook для донастройки nginx и выкладки сайта на grafana_node
resource "null_resource" "grafana_node_ansible_playbook_setup_nginx_and_site" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста для назначения на web_node
#    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_web_node.filename} --extra-vars \"web_node_hostname=${local.web_node_hostname} domain_name=${local.domain_name}  \" ../ansible/web_node/provision_nginx.yaml -u ubuntu"
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_grafana_node.filename} --extra-vars \"grafana_node_hostname=${local.grafana_node_hostname} domain_name=${local.domain_name}  \" ../ansible/grafana_node/provision_nginx.yaml -u ubuntu"
  }

  depends_on = [
#    null_resource.wait_inventory_web_node, aws_instance.diplom-vm-web_node
    null_resource.grafana_node_ansible_playbook_prepare_grafananode
  ]
}
