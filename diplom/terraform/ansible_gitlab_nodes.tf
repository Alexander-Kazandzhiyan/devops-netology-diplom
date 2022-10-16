# Организовываем задержку до появления файла inventory и ещё 30 сек
resource "null_resource" "wait_inventory_gitlab_nodes" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    local_file.inventory_gitlab_nodes
  ]
}

# запускаем ansible playbook для донастройки gitlab_nodes
resource "null_resource" "gitlab_nodes_ansible_playbook_prepare_nodes" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменных с именами хостов для назначения на gitlab_nodes
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_gitlab_nodes.filename} --extra-vars \"gitlab_node_hostname=${local.gitlab_node_hostname} gitlabrunner_node_hostname=${local.gitlabrunner_node_hostname} \" ../ansible/gitlab_nodes/provision_gitlab_nodes.yaml -u ubuntu"
  }
  depends_on = [
    null_resource.wait_inventory_gitlab_nodes, aws_instance.diplom-vm-gitlab_node, aws_instance.diplom-vm-gitlabrunner_node, null_resource.rproxy_ansible_playbook
  ]
}

# запускаем ansible playbook для установки gitlab
resource "null_resource" "gitlab_nodes_ansible_playbook_setup_products" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста c gitlab 
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_gitlab_nodes.filename} --extra-vars \"gitlab_node_hostname=${local.gitlab_node_hostname} gitlabrunner_node_hostname=${local.gitlabrunner_node_hostname} gitlab_root_password=${local.gitlab_root_password} gitlab_root_token=${local.gitlab_root_token} gitlab_runner_init_token=${local.gitlab_runner_init_token} \" ../ansible/gitlab_nodes/provision_gitlab_on_node.yaml -u ubuntu"
  }
  depends_on = [
    null_resource.wait_inventory_gitlab_nodes, aws_instance.diplom-vm-gitlab_node, aws_instance.diplom-vm-gitlabrunner_node, null_resource.rproxy_ansible_playbook, null_resource.gitlab_nodes_ansible_playbook_prepare_nodes
  ]
}

# запускаем ansible playbook для установки runner.
resource "null_resource" "gitlabrunner_nodes_ansible_playbook_setup_products" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста c gitlab 
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_gitlab_nodes.filename} --extra-vars \"gitlab_node_hostname=${local.gitlab_node_hostname} gitlabrunner_node_hostname=${local.gitlabrunner_node_hostname} gitlab_root_password=${local.gitlab_root_password} gitlab_runner_init_token=${local.gitlab_runner_init_token} \" ../ansible/gitlab_nodes/provision_gitlabrunner_on_node.yaml -u ubuntu"
  }
  depends_on = [
    null_resource.wait_inventory_gitlab_nodes, aws_instance.diplom-vm-gitlab_node, aws_instance.diplom-vm-gitlabrunner_node, null_resource.rproxy_ansible_playbook, null_resource.gitlab_nodes_ansible_playbook_prepare_nodes, null_resource.gitlab_nodes_ansible_playbook_setup_products
  ]
}

