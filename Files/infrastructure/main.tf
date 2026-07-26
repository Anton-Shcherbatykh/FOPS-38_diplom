# Создание VPC сети
resource "yandex_vpc_network" "main" {
  name = "main-vpc"
}

# Создание подсетей в разных зонах доступности
locals {
  zones = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

resource "yandex_vpc_subnet" "subnets" {
  count          = length(local.zones)
  name           = "subnet-${local.zones[count.index]}"
  zone           = local.zones[count.index]
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.${count.index + 1}.0.0/24"]
}

# Создание группы безопасности с базовыми правилами
resource "yandex_vpc_security_group" "default" {
  name        = "default-sg"
  description = "Default security group for infrastructure"
  network_id  = yandex_vpc_network.main.id

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from anywhere (temporary)"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}