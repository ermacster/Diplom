#веб 1
resource "yandex_compute_instance" "vm-web1" {
  name        = "vm-in-public-network"
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
  }

  scheduling_policy {
    preemptible = true
  }
}

#веб 2
resource "yandex_compute_instance" "vm-w2" {
  name        = "vm-w2"
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
    subnet_id          = yandex_vpc_subnet.private-subnet.id
    security_group_ids = [yandex_vpc_security_group.vm_group_service.id]

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
    #security_group_ids = ["yandex_vpc_security_group.vm_group_service.id"]
    nat                = true # The subnet ID of the existing subnet
  }

  scheduling_policy {
    preemptible = true
  }
}
