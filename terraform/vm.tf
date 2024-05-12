
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
    security_group_ids = [yandex_vpc_security_group.internal-bastion-sg.id]
    nat                = false
  }

  scheduling_policy {
    preemptible = true
  }
}


#Elastics
resource "yandex_compute_instance" "vm-elastics" {
  name        = "vm-elastics"
  hostname    = "vm-elastics"
  zone        = "ru-central1-b"
  platform_id = "standard-v2"
  metadata = {
    user-data = "${file("cloud-init.yaml")}"
  }
  resources {
    cores         = 4
    memory        = 8
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8iedutgsd1prssovep"
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
    cores         = 4
    memory        = 8
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8iedutgsd1prssovep"
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

#бкап машины bastion-host
resource "yandex_compute_snapshot" "bastion-host-snapshot" {
  name        = "bastion-host-snapshot-${formatdate("YYYYMMDD", timestamp())}"
  description = "Daily snapshot of vm-bastion-host"
  source_disk_id= "${yandex_compute_instance.bastion-host.boot_disk.0.disk_id}"

  labels = {
    "auto-delete" = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "yandex_compute_snapshot_schedule" "vm-bastion-host-snapshot-schedule" {
  name           = "bastion-host-snapshot-schedule"
  description    = "Schedule for daily snapshots of bastion-host with one-week retention"

  schedule_policy {
    expression = "0 0 * * *"
  }

  retention_period = "168h" // 7 days in hours

  snapshot_spec {
    description = "Snapshot created by schedule"
    labels = {
      snapshot-label = "vm-bastion-host-daily"
    }
  }

  disk_ids = [yandex_compute_instance.bastion-host.boot_disk.0.disk_id]
}


#бкап машины web-a
resource "yandex_compute_snapshot" "vm-web-a-snapshot" {
  name        = "vm-web-a-snapshot-${formatdate("YYYYMMDD", timestamp())}"
  description = "Daily snapshot of vm-web-a"
  source_disk_id= "${yandex_compute_instance.vm-web-a.boot_disk.0.disk_id}"

  labels = {
    "auto-delete" = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "yandex_compute_snapshot_schedule" "vm-web-a-snapshot-schedule" {
  name           = "vm-web-a-snapshot-schedule"
  description    = "Schedule for daily snapshots of vm-web-a with one-week retention"

  schedule_policy {
    expression = "0 0 * * *"
  }

  retention_period = "168h" // 7 days in hours

  snapshot_spec {
    description = "Snapshot created by schedule"
    labels = {
      snapshot-label = "vm-web-a"
    }
  }

  disk_ids = [yandex_compute_instance.vm-web-a.boot_disk.0.disk_id]
}

#бкап машины web-b
resource "yandex_compute_snapshot" "vm-web-b-snapshot" {
  name        = "vm-web-b-snapshot-${formatdate("YYYYMMDD", timestamp())}"
  description = "Daily snapshot of vm-web-b"
  source_disk_id= "${yandex_compute_instance.vm-web-b.boot_disk.0.disk_id}"

  labels = {
    "auto-delete" = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "yandex_compute_snapshot_schedule" "vm-web-b-snapshot-schedule" {
  name           = "vm-web-b-snapshot-schedule"
  description    = "Schedule for daily snapshots of vm-web-b with one-week retention"

  schedule_policy {
    expression = "0 0 * * *"
  }

  retention_period = "168h" // 7 days in hours

  snapshot_spec {
    description = "Snapshot created by schedule"
    labels = {
      snapshot-label = "vm-web-b"
    }
  }

  disk_ids = [yandex_compute_instance.vm-web-b.boot_disk.0.disk_id]
}

#бкап машины kibana
resource "yandex_compute_snapshot" "vm-kibana-snapshot" {
  name        = "vm-kibana-snapshot-${formatdate("YYYYMMDD", timestamp())}"
  description = "Daily snapshot of vm-elastics"
  source_disk_id= "${yandex_compute_instance.vm-kibana.boot_disk.0.disk_id}"

  labels = {
    "auto-delete" = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "yandex_compute_snapshot_schedule" "vm-kibana-snapshot-schedule" {
  name           = "vm-kibana-snapshot-schedule"
  description    = "Schedule for daily snapshots of vm-kibana with one-week retention"

  schedule_policy {
    expression = "0 0 * * *"
  }

  retention_period = "168h" // 7 days in hours

  snapshot_spec {
    description = "Snapshot created by schedule"
    labels = {
      snapshot-label = "vm-kibana-daily"
    }
  }

  disk_ids = [yandex_compute_instance.vm-kibana.boot_disk.0.disk_id]
}

#бкап машины zabbix
resource "yandex_compute_snapshot" "vm-zabbix-snapshot" {
  name        = "vm-zabbix-snapshot-${formatdate("YYYYMMDD", timestamp())}"
  description = "Daily snapshot of vm-elastics"
  source_disk_id= "${yandex_compute_instance.vm-zabbix.boot_disk.0.disk_id}"

  labels = {
    "auto-delete" = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "yandex_compute_snapshot_schedule" "vm-zabbix-snapshot-schedule" {
  name           = "vm-zabbix-snapshot-schedule"
  description    = "Schedule for daily snapshots of vm-zabbix with one-week retention"

  schedule_policy {
    expression = "0 0 * * *"
  }

  retention_period = "168h" // 7 days in hours

  snapshot_spec {
    description = "Snapshot created by schedule"
    labels = {
      snapshot-label = "vm-zabbix-daily"
    }
  }

  disk_ids = [yandex_compute_instance.vm-zabbix.boot_disk.0.disk_id]
}


#бкап машины elastics
resource "yandex_compute_snapshot" "vm-elastics-snapshot" {
  name        = "vm-elastics-snapshot-${formatdate("YYYYMMDD", timestamp())}"
  description = "Daily snapshot of vm-elastics"
  source_disk_id= "${yandex_compute_instance.vm-elastics.boot_disk.0.disk_id}"

  labels = {
    "auto-delete" = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "yandex_compute_snapshot_schedule" "vm-elastics-snapshot-schedule" {
  name           = "vm-elastics-snapshot-schedule"
  description    = "Schedule for daily snapshots of vm-elastics with one-week retention"

  schedule_policy {
    expression = "0 0 * * *"
  }

  retention_period = "168h" // 7 days in hours

  snapshot_spec {
    description = "Snapshot created by schedule"
    labels = {
      snapshot-label = "vm-elastics-daily"
    }
  }

  disk_ids = [yandex_compute_instance.vm-elastics.boot_disk.0.disk_id]
}