##############  Создаём ВМ мониторинга для работы Grafana+Prometheus+AlertManager  ############

# Описываем создаваемую ВМ monitoring_node для сервера мониторинга
resource "aws_instance" "diplom-vm-monitoring_node" {

# Для создания ВМ указываем найденный нами образ, точнее его id
  ami = local.VM_instance_ami

# Указываем тип ВМ
  instance_type = local.monitoring_node_type_vm

# Привязываем созданный ранее сетевой интерфейс
  network_interface {
    network_interface_id = aws_network_interface.diplom-private-network_interface-monitoring_node.id
    device_index = 0
  }

# Указываем ключевую пару для доступа
  key_name = aws_key_pair.kp.key_name

  depends_on = [aws_network_interface.diplom-private-network_interface-monitoring_node]

  tags = {
    Name = "diplom-vm-monitoring_node"
  }
}

