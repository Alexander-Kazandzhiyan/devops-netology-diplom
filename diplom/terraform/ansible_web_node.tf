# Организовываем задержку до появления файла inventory и ещё 30 сек
resource "null_resource" "wait_inventory_web_node" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    local_file.inventory_web_node
  ]
}

# запускаем ansible playbook для донастройки web_node
resource "null_resource" "web_node_ansible_playbook_prepare_webnode" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста для назначения на web_node
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_web_node.filename} --extra-vars \"web_node_hostname=${local.web_node_hostname} domain_name=${local.domain_name}  \" ../ansible/web_node/provision_web_node.yaml -u ubuntu"
  }
  depends_on = [
    null_resource.wait_inventory_web_node, aws_instance.diplom-vm-web_node, null_resource.rproxy_ansible_playbook
  ]
}

# запускаем ansible playbook для установки Apache и Wordpress на web_node. Мы будем использовать mysql из кластера на db-nodes
resource "null_resource" "web_node_ansible_playbook_setup_apache_and_wordpress" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста для назначения на web_node
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_web_node.filename} --extra-vars \"web_node_hostname=${local.web_node_hostname} domain_name=${local.domain_name} db_wordpress_dbhost=${local.db_wordpress_dbhost} db_wordpress_dbname=${local.db_wordpress_dbname} db_wordpress_dbusername=${local.db_wordpress_dbusername} db_wordpress_dbuserpassword=${local.db_wordpress_dbuserpassword}  \" ../ansible/web_node/provision_apache_wordpress.yaml -u ubuntu"
  }

  depends_on = [
#    null_resource.wait_inventory_web_node, aws_instance.diplom-vm-web_node
    null_resource.web_node_ansible_playbook_prepare_webnode
  ]
}
