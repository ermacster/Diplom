#виртуальная сеть
resource "yandex_vpc_network" "vpc" { 
  name = "my-vpc"
}

#частная сеть a
resource "yandex_vpc_subnet" "private-subnet-a" { 
  name = "private-subnet-a"
  network_id = yandex_vpc_network.vpc.id
  zone = "ru-central1-a" # Укажите нужную зону
  v4_cidr_blocks = ["10.10.10.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}
#частная сеть b
resource "yandex_vpc_subnet" "private-subnet-b" { 
  name = "private-subnet-b"
  network_id = yandex_vpc_network.vpc.id
  zone = "ru-central1-b" # Укажите нужную зону
  v4_cidr_blocks = ["10.10.20.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

#публичная сеть
resource "yandex_vpc_subnet" "public-subnet" { 
  name = "public-subnet"
  network_id = yandex_vpc_network.vpc.id
  zone = "ru-central1-a" # Укажите нужную 
  v4_cidr_blocks = ["10.10.30.0/24"]
  
}
#NAT for privat
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "test-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "test-route-table"
  network_id = yandex_vpc_network.vpc.id

 static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat_gateway.id
  }
}


#firewall
resource yandex_vpc_security_group "vm_group_service" { 
  network_id = yandex_vpc_network.vpc.id
  ingress {
    description    = "Allow HTTP protocol from local subnets"
    protocol       = "TCP"
    port           = "80"
    v4_cidr_blocks = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
  }

  ingress {
    description    = "Allow HTTPS protocol from local subnets"
    protocol       = "TCP"
    port           = "443"
    v4_cidr_blocks = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
  }

  ingress {
    description = "Health checks from NLB"
    protocol = "TCP"
    predefined_target = "loadbalancer_healthchecks" 
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#firewall for bastion
resource yandex_vpc_security_group "vm_group_bastion" { 
  network_id = yandex_vpc_network.vpc.id
  ingress {
    description    = "Allow ssh protocol from local subnets"
    protocol       = "TCP"
    port           = "22"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#target group
resource "yandex_alb_target_group" "tgs" {
  name = "tgs"

  target {
    subnet_id = yandex_compute_instance.vm-web2.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.vm-web2.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_compute_instance.vm-web1.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.vm-web1.network_interface.0.ip_address
  }
  
}

#Бекенд
resource "yandex_alb_backend_group" "backend_group" {
 http_backend {
    name = "bkg-test"
    weight = 1
    port = 80
    target_group_ids = [yandex_alb_target_group.tgs.id]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout = "10s"
      interval = "2s"
      healthy_threshold = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

#httprouter
resource "yandex_alb_http_router" "htr" {
  name = "htr"
  labels = {
    tf-label = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-vh" {
  name = "my-vh"
  http_router_id = yandex_alb_http_router.htr.id
  route {
    name = "route-to-hell"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend_group.id
        timeout = "60s"
      }
    }
  }
  #route_options {
   # security_profile_id = "fevcrrg5fci3bf6n6460"
 # }
}

#Балансер
resource "yandex_alb_load_balancer" "test-balancer" {
  name = "test-balancer"
  network_id = yandex_vpc_network.vpc.id
  security_group_ids = [yandex_vpc_security_group.vm_group_service.id]

  allocation_policy {
    location {
      zone_id = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-subnet.id
    }
  }

  listener {
    name = "listener-test"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 9000 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.htr.id
      }
    }
  }
}