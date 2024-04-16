resource "yandex_vpc_network" "vpc" { #виртуальная сеть
  name = "my-vpc"
}

resource "yandex_vpc_subnet" "private-subnet" { #частная сеть
  name = "private-subnet"
  network_id = yandex_vpc_network.vpc.id
  zone = "ru-central1-a" # Укажите нужную зону
  v4_cidr_blocks = ["10.10.10.0/24"]
  
}

resource "yandex_vpc_subnet" "public-subnet" { #публичная сеть
  name = "public-subnet"
  network_id = yandex_vpc_network.vpc.id
  zone = "ru-central1-a" # Укажите нужную зону
  v4_cidr_blocks = ["10.10.20.0/24"]
  }

resource yandex_vpc_security_group vm_group_sg { #firewall
  network_id = yandex_vpc_network.vpc.id
  ingress {
    description    = "Allow HTTP protocol from local subnets"
    protocol       = "TCP"
    port           = "80"
    v4_cidr_blocks = ["10.10.10.0/24", "10.10.20.0/24"]
  }

  ingress {
    description    = "Allow HTTPS protocol from local subnets"
    protocol       = "TCP"
    port           = "443"
    v4_cidr_blocks = ["10.10.10.0/24", "10.10.20.0/24"]
  }

  ingress {
    description = "Health checks from NLB"
    protocol = "TCP"
    predefined_target = "loadbalancer_healthchecks" # [198.18.235.0/24, 198.18.248.0/24]
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_alb_target_group" "TG" {
  name = "TG"

  target {
    subnet_id = yandex_compute_instance.WEB-1.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.WEB-1.network_interface.0.ip_address
  }

 # target {
   # subnet_id = yandex_compute_instance.vm.network_interface.0.subnet_id
   # ip_address = yandex_compute_instance.vm.network_interface.0.ip_address
 # }
  
}