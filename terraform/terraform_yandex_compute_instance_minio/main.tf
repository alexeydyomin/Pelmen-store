# Определяем сеть
resource "yandex_vpc_network" "momo-net" {
  name = "my-network"

}

# Определяем подсеть
resource "yandex_vpc_subnet" "momo_subnet" {
  name           = "my-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.momo-net.id
  v4_cidr_blocks = ["10.0.0.0/24"]

}

# Создаем виртуальную машину
resource "yandex_compute_instance" "vm-1" {
  name        = "momo-std-030-35"
  zone        = var.zone
  platform_id = var.platform_id

  scheduling_policy {
    preemptible = var.is_preemptible
  }

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.size
    }
  }

  # Подключение к сети
  network_interface {
    subnet_id = yandex_vpc_subnet.momo_subnet.id

    # Настройка публичного IP
    nat = true

    # Назначение security_group
    security_group_ids = [yandex_vpc_security_group.test-sg.id]
  }

  metadata = {
    ssh-keys  = "student:${file("~/.ssh/id_rsa.pub")}"
    user-data = <<-EOF
      #!/bin/bash
      sudo apt update -y
      curl -sSL https://get.docker.com | sh
      sudo usermod -aG docker $(whoami)
      echo "student ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/student
      sudo chmod 440 /etc/sudoers.d/student
    EOF
  }
}

# Создание DNS зоны
resource "yandex_dns_zone" "my_dns_zone" {
  name             = "my-dns-zone"
  description      = "DNS зона для моего проекта"
  zone             = "std030-35.momo."
  private_networks = [yandex_vpc_network.momo-net.id]
}

# Создание A записи для публичного IP
resource "yandex_dns_recordset" "my_dns_record" {
  zone_id = yandex_dns_zone.my_dns_zone.id
  name    = "vm1.std030-35.momo."
  type    = "A"
  ttl     = 60
  data    = [yandex_compute_instance.vm-1.network_interface.0.nat_ip_address]
}


resource "yandex_vpc_security_group" "test-sg" {
  name        = "Momo_security_group"
  description = "Momo security group"
  network_id  = yandex_vpc_network.momo-net.id

  labels = {
    my-label = "my-label-value"
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]

  }
}


# Вывод публичного IP
output "instance_public_ip" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

# Вывод адреса Minio с портом
output "minio_url" {
  value       = "http://${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}:9001"
  description = "URL для подключения к Minio"
}

# Вывод DNS имени
output "instance_dns_name" {
  value = "vm1.std030-35.momo."
}


resource "null_resource" "vm-1" {
  depends_on = [yandex_compute_instance.vm-1]
  connection {
    user        = "student"
    private_key = file("~/.ssh/id_rsa")
    host        = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address

  }
  provisioner "local-exec" {
    command = "sleep 180 &&  ANSIBLE_SSH_ARGS='-o StrictHostKeyChecking=no' ansible-playbook -i \"$(terraform output -raw instance_public_ip),\" -u student --private-key ~/.ssh/id_rsa setup-docker-compose.yml"
  }

}
#   # Добавляем ключ хоста в известные
#   provisioner "local-exec" {
#     command = "ssh-keyscan -H ${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address} >> ~/.ssh/known_hosts"
#   }
#   # Provisioner для копирования файлов на новый хост
#   provisioner "file" {
#     source      = "nginx.conf"
#     destination = "/home/student/nginx.conf"

#   }

#   provisioner "file" {
#     source      = "minio-compose.yml"
#     destination = "/home/student/minio-compose.yml"
#   }

#   # Provisioner для запуска docker compose minio
#   provisioner "remote-exec" {
#     inline = [
#       "docker compose -f /home/student/minio-compose.yml up -d"
#     ]
#   }
# }


