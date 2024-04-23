#виртуальная сеть
resource "yandex_vpc_network" "external-bastion-network-test" { 
  name = "external-bastion-network"
}

#наружная сеть
resource "yandex_vpc_subnet" "bastion-external-segment-test" { 
  name = "bastion-external-segment-test"
  network_id = yandex_vpc_network.external-bastion-network-test.id
  zone = "ru-central1-a" # Укажите нужную зону
  v4_cidr_blocks = ["172.16.20.0/28"]
}
