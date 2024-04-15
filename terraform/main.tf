terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

locals {
  folder_id = "b1gfcg9sv09pksgqrav5"
  cloud_id = "b1g22bfvv8svr6ve4095"
}

provider "yandex" {
    cloud_id = local.cloud_id
    folder_id = local.folder_id
    service_account_key_file = "/home/ermac/Desktop/Diplom/authorized_key.json"
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "vm_in_existing_subnet" {
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
    subnet_id = "e9b46pofe87mnjl84ot7"  # The subnet ID of the existing subnet
  }

  scheduling_policy {
    preemptible = true
  }  
}


  
