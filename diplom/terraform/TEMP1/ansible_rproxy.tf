# Организовываем задержку до появления файла inventory и ещё 30 сек
resource "null_resource" "wait_inventory" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    local_file.inventory_rproxy
  ]
}

# запускаем ansible playbook для донастройки rproxy
resource "null_resource" "rproxy_ansible_playbook" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста для назначения на rproxy
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook --timeout 40 -i ${local_file.inventory_rproxy.filename} --extra-vars \"rproxy_hostname=${local.rproxy_hostname} domain_name=${local.domain_name}  \" ../ansible/rproxy/provision_rproxy.yaml -u ubuntu"
  }
  depends_on = [
    null_resource.wait_inventory, aws_instance.diplom-vm-rproxy
  ]
}

# запускаем ansible playbook для настройки nginx в  качестве обратного прокси
resource "null_resource" "rproxy_nginx_ansible_playbook" {
  provisioner "local-exec" {
# тут в командной строке пересылается значение переменной с именем хоста для назначения на rproxy
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook --timeout 40 -i ${local_file.inventory_rproxy.filename} --extra-vars \"rproxy_hostname=${local.rproxy_hostname} domain_name=${local.domain_name}  \" ../ansible/rproxy/provision_rproxy_nginx.yaml -u ubuntu"
  }

  depends_on = [
    null_resource.wait_inventory, aws_instance.diplom-vm-rproxy, null_resource.rproxy_ansible_playbook
  ]
}
