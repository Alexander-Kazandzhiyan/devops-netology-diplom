# Организовываем задержку до появления файла inventory и ещё 30 сек
resource "null_resource" "wait_inventory_db_nodes" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    local_file.inventory_db_nodes
  ]
}


# запускаем ansible playbook для проверки  db_node
#resource "null_resource" "db_nodes_ansible_playbook_testconnect" {
#  provisioner "local-exec" {
#    command = "ANSIBLE_FORCE_COLOR=1 ansible -i ${local_file.inventory_db_nodes.filename} -u ubuntu -m ping all"
#  }
#  depends_on = [
#    null_resource.wait_inventory_db_nodes, aws_instance.diplom-vm-db_node, null_resource.rproxy_ansible_playbook
#  ]
#}

# запускаем ansible playbook для донастройки db_nodes
resource "null_resource" "db_node_ansible_playbook" {
  provisioner "local-exec" {
# тут в командной строке пересылается значения переменных с именами хостов для назначения на ВМ
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_db_nodes.filename} --extra-vars \"db01_node_hostname=${local.db01_node_hostname} db02_node_hostname=${local.db02_node_hostname}\" ../ansible/db_nodes/provision_db_nodes.yaml -u ubuntu"
  }
  depends_on = [
    null_resource.wait_inventory_db_nodes, aws_instance.diplom-vm-db_node, null_resource.rproxy_ansible_playbook
  ]
}

# запускаем ansible playbook для настройки Mysql Cluster на  db_nodes
resource "null_resource" "db_node_ansible_playbook_mysql_cluster" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста для назначения на web_node
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_db_nodes.filename} --extra-vars \"db01_node_hostname=${local.db01_node_hostname} db02_node_hostname=${local.db02_node_hostname}\" ../ansible/db_nodes/provision_db_nodes_mysql_cluster.yaml -u ubuntu"
  }
  depends_on = [
    null_resource.db_node_ansible_playbook, aws_instance.diplom-vm-db_node, null_resource.rproxy_ansible_playbook
  ]
}
