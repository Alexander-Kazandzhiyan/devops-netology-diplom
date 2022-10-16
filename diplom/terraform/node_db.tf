
# Описываем создаваемую ВМ db0x_node для кластера mysql
resource "aws_instance" "diplom-vm-db_node" {

count = 2

# Для создания ВМ указываем найденный нами образ, точнее его id
  ami = local.VM_instance_ami

# Указываем тип ВМ
  instance_type = local.db_node_type_vm

# Привязываем созданный ранее сетевой интерфейс
  network_interface {
    network_interface_id = aws_network_interface.diplom-private-network_interface-db_node[count.index].id
    device_index = 0
  }

# Указываем ключевую пару для доступа
  key_name = aws_key_pair.kp.key_name

  depends_on = [aws_network_interface.diplom-private-network_interface-db_node]

  tags = {
    Name = "diplom-vm-db_node_${1+count.index}"
  }
}

