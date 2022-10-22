##############  Создаём ВМ для сервера обратного Proxy ############

# Описываем создаваемую ВМ rproxy
resource "aws_instance" "diplom-vm-rproxy" {

# Для создания ВМ указываем найденный нами образ, точнее его id
  ami = local.VM_instance_ami

# Указываем тип ВМ
  instance_type = local.rproxy_type_vm

# Привязываем созданный ранее сетевой интерфейс в публичной сети
  network_interface {
    network_interface_id = aws_network_interface.diplom-public-network_interface-rproxy.id
    device_index = 0
  }

# Указываем ключевую пару для доступа
  key_name = aws_key_pair.kp.key_name

#  depends_on = [aws_network_interface.diplom-public-network_interface-rproxy, aws_eip.diplom-elastic-ip-rproxy, null_resource.wait]
  depends_on = [aws_network_interface.diplom-public-network_interface-rproxy, aws_eip.diplom-elastic-ip-rproxy]

  tags = {
    Name = "diplom-vm-rproxy"
  }
}

