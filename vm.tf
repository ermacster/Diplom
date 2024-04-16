resource "yandex_compute_instance" "vm-1" {# для теста
  name = "vm-in-private-network"
  zone = "ru-central1-a"
  platform_id = "standard-v2"
  resources {
    cores = 2
    memory = 1
    core_fraction = 20      
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l45jhe4nvt0ih7h2e"
      size = 10
    }

  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat = true # The subnet ID of the existing subnet
  }

  scheduling_policy {
    preemptible = true
  }  
}

resource "yandex_compute_instance" "WEB-1" {
  name = "WEB-1"
  zone = "ru-central1-a"
  platform_id = "standard-v2"
  resources {
    cores = 2
    memory = 1
    core_fraction = 20      
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l45jhe4nvt0ih7h2e"
      size = 10
    }

  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    
  }

  scheduling_policy {
    preemptible = true
  }  
}
