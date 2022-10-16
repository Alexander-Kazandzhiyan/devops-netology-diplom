# запускаем ansible playbook для создания проекта в gitlab
resource "null_resource" "gitlab_CICD" {
  provisioner "local-exec" {
# тут 
#   command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i 127.0.0.1                                     --extra-vars \"gitlab_node_hostname=${local.gitlab_node_hostname} gitlab_root_token=${local.gitlab_project_name} \" ../ansible/website_CICD/gitlab_website_CICD_project.yaml"
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_gitlab_nodes.filename} --extra-vars \"gitlab_node_hostname=${local.gitlab_node_hostname} gitlab_root_token=${local.gitlab_root_token} gitlab_root_password=${local.gitlab_root_password} gitlab_project_name=${local.gitlab_project_name} \" ../ansible/website_CICD/gitlab_website_CICD_project.yaml -u ubuntu"
#   command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ${local_file.inventory_gitlab_nodes.filename} --extra-vars \"gitlab_node_hostname=${local.gitlab_node_hostname} gitlabrunner_node_hostname=${local.gitlabrunner_node_hostname} gitlab_root_password=${local.gitlab_root_password} gitlab_runner_init_token=${local.gitlab_runner_init_token} \" ../ansible/website_CICD/gitlab_website_CICD_project.yaml -u ubuntu"
  }
  depends_on = [
    aws_instance.diplom-vm-gitlab_node, aws_instance.diplom-vm-gitlabrunner_node, null_resource.gitlab_nodes_ansible_playbook_setup_products, null_resource.gitlabrunner_nodes_ansible_playbook_setup_products
  ]
}

