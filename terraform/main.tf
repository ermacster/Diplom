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
    service_account_key_file = "/home/ermac/Diplom/Diplom/terraform/authorized_key.json"
  zone = "ru-central1-a"
}


