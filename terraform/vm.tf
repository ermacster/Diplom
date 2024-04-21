
#веб 1
resource "yandex_compute_instance" "vm-web1" {
  name        = "vm-web-a"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l45jhe4nvt0ih7h2e"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-a.id
    security_group_ids = [yandex_vpc_security_group.vm_group_service.id]
    nat                = false
  }

  scheduling_policy {
    preemptible = true
  }
}

#веб 2
resource "yandex_compute_instance" "vm-web2" {
  name        = "vm-web2"
  zone        = "ru-central1-b"
  platform_id = "standard-v2"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l45jhe4nvt0ih7h2e"
      size     = 10
    }

  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-b.id
    security_group_ids = [yandex_vpc_security_group.vm_group_service.id]
    nat                = false
  }

  scheduling_policy {
    preemptible = true
  }
}
#Elastics+filebeat
resource "yandex_compute_instance" "vm-elastics" {
  name        = "vm-elastics2"
  zone        = "ru-central1-b"
  platform_id = "standard-v2"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l45jhe4nvt0ih7h2e"
      size     = 10
    }

  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-b.id
    security_group_ids = [yandex_vpc_security_group.vm_group_service.id]
    nat                = false
  }

  scheduling_policy {
    preemptible = true
  }
}

#Zabbix
resource "yandex_compute_instance" "vm-zabbix" {
  name        = "vm-zabbix"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l45jhe4nvt0ih7h2e"
      size     = 10
    }

  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.vm_group_service.id]
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}

#Kibana
resource "yandex_compute_instance" "vm-kibana" {
  name        = "vm-kibana"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l45jhe4nvt0ih7h2e"
      size     = 10
    }

  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.vm_group_service.id]
    nat                = true

  }

  scheduling_policy {
    preemptible = true
  }
}



#Бастион

resource "yandex_compute_instance" "vm-base" {
  name        = "vm-base"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l45jhe4nvt0ih7h2e"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = ["yandex_vpc_security_group.vm_group_bastion.id"]
    nat                = true # The subnet ID of the existing subnet
  }

  scheduling_policy {
    preemptible = true
  }
}
