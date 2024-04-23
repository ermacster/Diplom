
#веб 1
resource "yandex_compute_instance" "vm-web1" {
  name        = "vm-web-a"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"
  metadata = {
  user-data = "${file("cloud-init.yaml")}"
 }
 

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
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment-a.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
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
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment-b.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
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
  metadata = {
  user-data = "${file("cloud-init.yaml")}"
 }
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
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment-b.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    nat                = false
  }

  scheduling_policy {
    preemptible = true
  }
}

#Zabbix
resource "yandex_compute_instance" "vm-zabbix" {
  name        = "vm-zabbix"
  zone        = "ru-central1-b"
  platform_id = "standard-v2"
  metadata = {
  user-data = "${file("cloud-init.yaml")}"
 }
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
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment-c.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}


#Kibana
resource "yandex_compute_instance" "vm-kibana" {
  name        = "vm-kibana"
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
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment-c.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    nat                = true

  }

  scheduling_policy {
    preemptible = true
  }
}



#Бастион

resource "yandex_compute_instance" "bastion-host" {
  name        = "bastion-host"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"
  metadata = {
  user-data = "${file("cloud-init.yaml")}"
 }

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8mfcsu31d3139ufj78"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-external-segment.id
    security_group_ids = [yandex_vpc_security_group.secure-bastion-sg.id]
    nat                = true # The subnet ID of the existing subnet
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment-a.id
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    ip_address = "172.16.15.254"
  }

  scheduling_policy {
    preemptible = true
  }
}
