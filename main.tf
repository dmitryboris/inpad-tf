data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Bastion host
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet_api.id
    nat        = true
    ip_address = "10.0.1.30"
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# 2 ВМ для API
resource "yandex_compute_instance" "api" {
  count       = 2
  name        = "api-${count.index + 1}"
  hostname    = "api-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_api.id
    ip_address         = "10.0.1.${10 + count.index}" # 10.0.1.10 и 10.0.1.11
    nat                = false
    security_group_ids = [yandex_vpc_security_group.api_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      packages:
        - docker.io
      runcmd:
        - systemctl enable --now docker
    EOF
  }

  service_account_id = yandex_iam_service_account.backend_sa.id
}

# ВМ для Worker
resource "yandex_compute_instance" "worker" {
  name        = "worker"
  hostname    = "worker"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_api.id
    ip_address         = "10.0.1.20"
    nat                = false
    security_group_ids = [yandex_vpc_security_group.api_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      packages:
        - docker.io
      runcmd:
        - systemctl enable --now docker
    EOF
  }

  service_account_id = yandex_iam_service_account.backend_sa.id
}

# ВМ для RabbitMQ
resource "yandex_compute_instance" "rabbitmq" {
  name        = "rabbitmq"
  hostname    = "rabbitmq"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id    = yandex_vpc_subnet.subnet_db.id
    ip_address   = "10.0.2.10"
    nat          = false
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      packages:
        - docker.io
      runcmd:
        - systemctl enable --now docker
        - docker run -d --name rabbitmq --restart always -p ${var.rabbit_port}:5672 -p 15672:15672 -e RABBITMQ_DEFAULT_USER=${var.rabbit_user} -e RABBITMQ_DEFAULT_PASS=${var.rabbit_password} -v /var/lib/rabbitmq:/var/lib/rabbitmq rabbitmq:3-management
    EOF
  }
}

# ВМ для Postgres
resource "yandex_compute_instance" "postgres" {
  name        = "postgres"
  hostname    = "postgres"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id    = yandex_vpc_subnet.subnet_db.id
    ip_address   = "10.0.2.20"
    nat          = false
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      packages:
        - docker.io
      runcmd:
        - systemctl enable --now docker
        - docker run -d --name postgres --restart always -e POSTGRES_USER=${var.pg_user} -e POSTGRES_PASSWORD=${var.pg_password} -e POSTGRES_DB=${var.pg_db} -v /var/lib/postgresql/data:/var/lib/postgresql/data -p ${var.pg_port}:5432 postgres:15
    EOF
  }
}

# Бакет
resource "yandex_storage_bucket" "frontend" {
  bucket        = "inpad-${var.yc_folder_id}"
  max_size      = 1073741824
  access_key    = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key    = yandex_iam_service_account_static_access_key.storage_key.secret_key
  acl           = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}