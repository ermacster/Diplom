#вывод для бастиона
output "bastion_external_ip" {
  value = yandex_compute_instance.bastion-host.network_interface[0].nat_ip_address
}
resource "null_resource" "save_external_ip_to_file" {
  provisioner "local-exec" {
    command = "echo '${yandex_compute_instance.bastion-host.network_interface[0].nat_ip_address}' > /home/ermac/Diplom/Diplom/ansible/bastion_external_ip.txt"
  }
}

#Вывод для заббикс
output "zabbix_external_ip" {
  value = yandex_compute_instance.vm-zabbix.network_interface[0].nat_ip_address
}
output "zabbix_fqdn" {
  value = yandex_compute_instance.vm-zabbix.fqdn
}
resource "null_resource" "save_external_ip_to_file_and_fqdn" {
  provisioner "local-exec" {
    command = <<EOT
      echo '${yandex_compute_instance.vm-zabbix.network_interface[0].nat_ip_address}' > /home/ermac/Diplom/Diplom/ansible/zabbix_external_ip.txt;
      echo '${yandex_compute_instance.vm-zabbix.fqdn}' > /home/ermac/Diplom/Diplom/ansible/zabbix_fqdn.txt;
    EOT   
  }
}

#Вывод для web-a
output "web-a_fqdn" {
  value = yandex_compute_instance.vm-web-a.fqdn
}
resource "null_resource" "save_fqdn_to_file_web-a" {
  provisioner "local-exec" {
    command = "echo '${yandex_compute_instance.vm-web-a.fqdn}' > /home/ermac/Diplom/Diplom/ansible/web-a_fqdn.txt"
  }
}

#Вывод для web-b
output "web-b_fqdn" {
  value = yandex_compute_instance.vm-web-b.fqdn
}
resource "null_resource" "save_fqdn_to_file_web-b" {
  provisioner "local-exec" {
    command = "echo '${yandex_compute_instance.vm-web-b.fqdn}' > /home/ermac/Diplom/Diplom/ansible/web-b_fqdn.txt"
  }
}

#Вывод для elastic
output "elastics_fqdn" {
  value = yandex_compute_instance.vm-elastics.fqdn
}
resource "null_resource" "save_fqdn_to_file_elastics" {
  provisioner "local-exec" {
    command = "echo '${yandex_compute_instance.vm-elastics.fqdn}' > /home/ermac/Diplom/Diplom/ansible/elastics_fqdn.txt"
  }
}

#Вывод для kibana
output "kibana_external_ip" {
  value = yandex_compute_instance.vm-kibana.network_interface[0].nat_ip_address
}
output "kibana_fqdn" {
  value = yandex_compute_instance.vm-kibana.fqdn
}
resource "null_resource" "save_external_ip_to_file_kibana" {
  provisioner "local-exec" {
    command = <<EOT
      echo '${yandex_compute_instance.vm-kibana.network_interface[0].nat_ip_address}' > /home/ermac/Diplom/Diplom/ansible/kibana_external_ip.txt;
      echo '${yandex_compute_instance.vm-kibana.fqdn}' > /home/ermac/Diplom/Diplom/ansible/kibana_fqdn.txt;
    EOT
  }
}