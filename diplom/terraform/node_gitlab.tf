
# Описываем создаваемую ВМ для сервера gitlab
resource "aws_instance" "diplom-vm-gitlab_node" {

# Для создания ВМ указываем найденный нами образ, точнее его id
  ami = local.VM_instance_ami

# Указываем тип ВМ
  instance_type = local.gitlab_node_type_vm

# Привязываем созданный ранее сетевой интерфейс
  network_interface {
    network_interface_id = aws_network_interface.diplom-private-network_interface-gitlab_node.id
    device_index = 0
  }

# Указываем ключевую пару для доступа
  key_name = aws_key_pair.kp.key_name

root_block_device {
    volume_size = 20 # in GB
    volume_type = "gp2"
#    encrypted   = false
#    kms_key_id  = data.aws_kms_key.customer_master_key.arn
  }


#  depends_on = [aws_network_interface.diplom-private-network_interface-web_node]

  tags = {
    Name = "diplom-vm-gitlab_node"
  }
}

