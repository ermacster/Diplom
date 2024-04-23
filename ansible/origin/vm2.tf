#Zabbix-test
resource "yandex_compute_instance" "vm-zabbix" {
  name        = "vm-zabbix"
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
    subnet_id          = yandex_vpc_subnet.bastion-external-segment-test.id
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}