
#виртуальная сеть
resource "yandex_vpc_network" "external-bastion-network" {
  name = "external-bastion-network"
}

#наружная сеть
#resource "yandex_vpc_subnet" "bastion-external-segment" {
# name           = "bastion-external-segment"
#network_id     = yandex_vpc_network.external-bastion-network.id
#zone           = "ru-central1-a" # Укажите нужную зону
#v4_cidr_blocks = ["172.16.18.0/28"]
#}


resource "yandex_vpc_network" "internal-bastion-network" {
  folder_id = local.folder_id
  name      = "internal-bastion-network"
}

#внутренняя частная a
resource "yandex_vpc_subnet" "bastion-internal-segment-a" {
  name           = "bastion-internal-segment-a"
  network_id     = yandex_vpc_network.internal-bastion-network.id
  zone           = "ru-central1-a" # Укажите нужную зону
  v4_cidr_blocks = ["172.16.15.0/24"]
  #route_table_id = yandex_vpc_route_table.rt.id
}

#внутренняя частная b
resource "yandex_vpc_subnet" "bastion-internal-segment-b" {
  name           = "bastion-internal-segment-b"
  network_id     = yandex_vpc_network.internal-bastion-network.id
  zone           = "ru-central1-b" # Укажите нужную зону
  v4_cidr_blocks = ["172.16.16.0/24"]
  #route_table_id = yandex_vpc_route_table.rt.id
}

#внутренняя публичная с
resource "yandex_vpc_subnet" "bastion-internal-segment-c" {
  name           = "bastion-internal-segment-c"
  network_id     = yandex_vpc_network.internal-bastion-network.id
  zone           = "ru-central1-d" # Укажите нужную зону
  v4_cidr_blocks = ["172.16.17.0/24"]
}

#NAT for privat
#resource "yandex_vpc_gateway" "nat_gateway" {
# name      = "test-gateway"
# folder_id = local.folder_id
# shared_egress_gateway {}
#}

#resource "yandex_vpc_route_table" "rt" {
# name       = "test-route-table"
# network_id = yandex_vpc_network.internal-bastion-network.id

#static_route {
# destination_prefix = "0.0.0.0/0"
#gateway_id         = yandex_vpc_gateway.nat_gateway.id
#}
#}

#firewall for bastion
resource "yandex_vpc_security_group" "secure-bastion-sg" {
  network_id = yandex_vpc_network.internal-bastion-network.id
  ingress {
    description    = "Allow ssh protocol from internet"
    protocol       = "TCP"
    port           = "22"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#firewall for bastion internal
resource "yandex_vpc_security_group" "internal-bastion-sg" {
  network_id = yandex_vpc_network.internal-bastion-network.id
  ingress {
    description    = "Allow ssh protocol from internet"
    protocol       = "TCP"
    port           = "22"
    v4_cidr_blocks = ["172.16.15.254/32"]
  }

  ingress {
    description       = "Health checks from NLB"
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }

  dynamic "egress" {
    for_each = ["80", "443", "22"]
    content {
      protocol          = "TCP"
      description       = "Allow protocols inside "
      from_port         = egress.value
      to_port           = egress.value
      predefined_target = "self_security_group"
    }

  }
}



#target group
resource "yandex_alb_target_group" "tgs" {
  name = "tgs"

  target {
    subnet_id  = yandex_compute_instance.vm-web-b.network_interface[0].subnet_id
    ip_address = yandex_compute_instance.vm-web-b.network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_compute_instance.vm-web-a.network_interface[0].subnet_id
    ip_address = yandex_compute_instance.vm-web-a.network_interface[0].ip_address
  }

}

#Бекенд
resource "yandex_alb_backend_group" "backend_group" {
  http_backend {
    name             = "bkg-test"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.tgs.id]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

#httprouter
#resource "yandex_alb_http_router" "htr2" {
# folder_id = local.folder_id
#name      = "htr2"
#labels = {
#  tf-label    = "tf-label-value"
#  empty-label = ""
#}
#}

#resource "yandex_alb_virtual_host" "my-vh" {
# name           = "my-vh"
#http_router_id = yandex_alb_http_router.htr2.id
#route {
#  name = "route-to-hell"
# http_route {
#   http_route_action {
#    backend_group_id = yandex_alb_backend_group.backend_group.id
#   timeout          = "60s"
#}
# }
#}
#route_options {
#security_profile_id = "fevcrrg5fci3bf6n6460"
#}
#}

#Балансер
#resource "yandex_alb_load_balancer" "test-balancer" {
#  name               = "test-balancer"
#  network_id         = yandex_vpc_network.internal-bastion-network.id
#  security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]

# allocation_policy {
#   location {
#     zone_id   = "ru-central1-b"
#    subnet_id = yandex_vpc_subnet.bastion-internal-segment-c.id
# }
#}

#listener {
#  name = "listener-test"
#  endpoint {
#    address {
#     external_ipv4_address {
#     }
#   }
#  ports = [9000]
#}
#http {
#  handler {
#    http_router_id = yandex_alb_http_router.htr2.id
#  }
#}
#}
#}






