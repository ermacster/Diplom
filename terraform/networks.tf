
resource "yandex_vpc_network" "internal-bastion-network" {
  folder_id = local.folder_id
  name      = "internal-bastion-network"
}

#Днс Зона для fqdn
resource "yandex_dns_zone" "zone1" {
  name        = "my-private-zone"
  description = "desc"

  labels = {
    label1 = "label-1-value"
  }

  zone             = "ermac.com."
  public           = false
  private_networks = [yandex_vpc_network.internal-bastion-network.id]

}

#внутренняя частная a
resource "yandex_vpc_subnet" "bastion-internal-segment-a" {
  name           = "bastion-internal-segment-a"
  network_id     = yandex_vpc_network.internal-bastion-network.id
  zone           = "ru-central1-a" # Укажите нужную зону
  v4_cidr_blocks = ["172.16.15.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

#внутренняя частная b
resource "yandex_vpc_subnet" "bastion-internal-segment-b" {
  name           = "bastion-internal-segment-b"
  network_id     = yandex_vpc_network.internal-bastion-network.id
  zone           = "ru-central1-b" # Укажите нужную зону
  v4_cidr_blocks = ["172.16.16.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

#внутренняя публичная с
resource "yandex_vpc_subnet" "bastion-internal-segment-c" {
  name           = "bastion-internal-segment-c"
  network_id     = yandex_vpc_network.internal-bastion-network.id
  zone           = "ru-central1-d" # Укажите нужную зону
  v4_cidr_blocks = ["172.16.17.0/24"]
}

#NAT for privat
resource "yandex_vpc_gateway" "nat_gateway" {
  name      = "test-gateway"
  folder_id = local.folder_id
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "test-route-table"
  network_id = yandex_vpc_network.internal-bastion-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

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
    for_each = ["80", "443", "22", "53", "5601", "10051", "10050", "9200"]
    content {
      protocol          = "TCP"
      description       = "Allow protocols inside "
      from_port         = egress.value
      to_port           = egress.value
      v4_cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "ingress" {
    for_each = ["80", "443", "53", "5601", "10051", "10050", "9200"]
    content {
      protocol          = "TCP"
      description       = "Allow protocols inside "
      from_port         = ingress.value
      to_port           = ingress.value
      v4_cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description       = "Allow ping"
    protocol          = "ICMP"
    from_port         = -1
    to_port           = -1
    predefined_target = "self_security_group"
  }
  ingress {
    description       = "Allow allow ping"
    protocol          = "ICMP"
    from_port         = -1
    to_port           = -1
    predefined_target = "self_security_group"
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
resource "yandex_alb_http_router" "htr2" {
 folder_id = local.folder_id
name      = "htr2"
labels = {
  tf-label    = "tf-label-value"
  empty-label = ""
}
}

resource "yandex_alb_virtual_host" "my-vh" {
 name           = "my-vh"
http_router_id = yandex_alb_http_router.htr2.id
route {
  name = "route-to-hell"
 http_route {
   http_route_action {
    backend_group_id = yandex_alb_backend_group.backend_group.id
   timeout          = "60s"
}
 }
}
}


#Балансер
resource "yandex_alb_load_balancer" "test-balancer" {
  name               = "test-balancer"
  network_id         = yandex_vpc_network.internal-bastion-network.id
  security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]

 allocation_policy {
   location {
     zone_id   = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.bastion-internal-segment-c.id
 }
}

listener {
  name = "listener-test"
  endpoint {
    address {
     external_ipv4_address {
     }
   }
  ports = [80]
}
http {
  handler {
    http_router_id = yandex_alb_http_router.htr2.id
  }
}
}
}






