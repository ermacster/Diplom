resource "yandex_vpc_network" "vpc" {
  name = "my-vpc"
}

resource "yandex_vpc_subnet" "private-subnet" {
  name = "private-subnet"
  network_id = yandex_vpc_network.vpc.id
  zone = "ru-central1-a" # Укажите нужную зону
  v4_cidr_blocks = ["10.10.10.0/24"]
  #range = "192.168.1.0/24" # Укажите нужный диапазон IP адресов
}

resource "yandex_vpc_subnet" "public-subnet" {
  name = "public-subnet"
  network_id = yandex_vpc_network.vpc.id
  zone = "ru-central1-a" # Укажите нужную зону
  v4_cidr_blocks = ["10.10.20.0/24"]
  }