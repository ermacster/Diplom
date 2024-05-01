
#веб 1
resource "yandex_compute_instance" "vm-web-a" {
  name        = "vm-web-a"
  hostname    = "vm-web-a"
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
      image_id = "fd82vchjp2kdjiuam29k"
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
resource "yandex_compute_instance" "vm-web-b" {
  name        = "vm-web-b"
  hostname    = "vm-web-b"
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
      image_id = "fd82vchjp2kdjiuam29k"
      size     = 10
    }

  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment-b.id
    #security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    nat                = false
  }

  scheduling_policy {
    preemptible = true
  }
}
#Elastics+filebeat
resource "yandex_compute_instance" "vm-elastics" {
  name        = "vm-elastics"
  hostname    = "vm-elastics"
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
      image_id = "fd82vchjp2kdjiuam29k"
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
  hostname    = "vm-zabbix"
  zone        = "ru-central1-d"
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
      image_id = "fd82vchjp2kdjiuam29k"
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
  hostname    = "vm-kibana"
  zone        = "ru-central1-d"
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
      image_id = "fd82vchjp2kdjiuam29k"
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
  hostname    = "bastion-host"
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
      image_id = "fd8enutfdqqdnpc8t8mm"
      size     = 10
    }
  }

  #network_interface {
  #subnet_id = yandex_vpc_subnet.bastion-external-segment.id
  #security_group_ids = [yandex_vpc_security_group.secure-bastion-sg.id]
  #nat = true # The subnet ID of the existing subnet
  #}

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-internal-segment-a.id
    security_group_ids = [yandex_vpc_security_group.secure-bastion-sg.id, yandex_vpc_security_group.internal-bastion-sg.id]
    ip_address         = "172.16.15.254"
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}
