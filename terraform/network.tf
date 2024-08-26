# network.tf

# Определение сети VPC
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

# Создание подсетей на основе конфигураций переменной подсетей
resource "yandex_vpc_subnet" "subnet" {
  for_each = {
    "central1-a" = {
      name       = "central1-a"
      zone       = var.default_zone_a
      cidr_block = "10.0.1.0/24"
    },
    "central1-b" = {
      name       = "central1-b"
      zone       = var.default_zone_b
      cidr_block = "10.0.2.0/24"
    },
    "central1-d" = {
      name       = "central1-d"
      zone       = var.default_zone_d
      cidr_block = "10.0.3.0/24"
    }
  }

  name           = each.value.name
  zone           = each.value.zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = [each.value.cidr_block]
}
