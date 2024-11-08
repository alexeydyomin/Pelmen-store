<div align="center"> 

![](/images/terraform.png) 

##  *Создание своей собственной ВМ в Yandex Cloud*
*Сделано пользователем *std-030-35@praktikum-services.ru* он же **Алексей Дёмин***

</div>

**Требования**:

> 🔎 Создание своей собственной ВМ в Yandex Cloud используя Terraform   
> 🔎 Установка сервера Minio на ВМ в Yandex Cloud  

<br>


---

**Выполненная работа:**

- Был создан новый каталог terraform в репозитории - https://gitlab.praktikum-services.ru/std-030-35/momo-store/terraform

![My Momo Store](/images/ter-repos.png "My Momo Store")  
<br>
  
---
<br>
- Файл с провайдером provider.tf - тут была сложность, новые версии провайдера не корреткно работают с созданимем ВМ, были ошибки, пришлось откатиться на более старую версию.  

<br>

Ошибки при планировании были такими:  

```
student@fhm5gld0krvrcfvb53db:~/terraform-momo$ terraform plan
╷
│ Error: Provider produced invalid plan
│
│ Provider "registry.terraform.io/yandex-cloud/yandex" planned an invalid value for yandex_compute_instance.vm-1.network_acceleration_type: planned value cty.StringVal("standard") for a non-computed attribute.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
╷
│ Error: Provider produced invalid plan
│
│ Provider "registry.terraform.io/yandex-cloud/yandex" planned an invalid value for yandex_compute_instance.vm-1.network_interface[0].ipv4: planned value cty.True for a non-computed attribute.
│
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
``` 

<br>  

- **provider.tf**  

```yaml
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "= 0.92.0"
    }
  }
  required_version = ">= 0.92.0"
}

provider "yandex" {
  token     = var.IAM_TOKEN
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

```
<br>

- main.tf - Создается сеть, ВМ и ingress rules
```yaml
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
```

---

<br>

- Основная сложность была в действиях после создания ВМ. Очень хотелось в новой ВМ сразу поднимать Docker контейнеры для работы **Minio**

<br>

- Тут пришлось мучаться с тем, что после создания ВМ, SSH не сразу поднимается, и подключение становится доступно минуты через 2 - 3.  
Сначала провабол так:

```yaml
  # Добавляем ключ хоста в известные
  provisioner "local-exec" {
    command = "ssh-keyscan -H ${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address} >> ~/.ssh/known_hosts"
  }
  # Provisioner для копирования файлов на новый хост
  provisioner "file" {
    source      = "nginx.conf"
    destination = "/home/student/nginx.conf"

  }

  provisioner "file" {
    source      = "minio-compose.yml"
    destination = "/home/student/minio-compose.yml"
  }

  # Provisioner для запуска docker compose minio
  provisioner "remote-exec" {
    inline = [
      "docker compose -f /home/student/minio-compose.yml up -d"
    ]
  }
}
```  

<br> 

- Получал ошибки вида:

```bash
null_resource.vm-1 (local-exec): Executing: ["/bin/sh" "-c" "ssh-keyscan -H 51.250.99.83 >> ~/.ssh/known_hosts"]
null_resource.vm-1 (local-exec): write (51.250.99.83): Connection refused
null_resource.vm-1 (local-exec): write (51.250.99.83): Connection refused
null_resource.vm-1 (local-exec): write (51.250.99.83): Connection refused
null_resource.vm-1 (local-exec): write (51.250.99.83): Connection refused
null_resource.vm-1 (local-exec): write (51.250.99.83): Connection refused
╷
│ Error: local-exec provisioner error
```

- Потом стал смотреть в сторону ansible, и решение итогововое получилось таким:

```yaml
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
```

- Используя provisioner и передав в команду запуска playbook - sleep 180 &&  ANSIBLE_SSH_ARGS='-o StrictHostKeyChecking=no' получилось добиться ожидаемого результата, таймаута хватает чтоб ssh поднимался.

- В итоге вывод отработанной команды teerrafrom apply такой:

```yaml
null_resource.vm-1 (local-exec): Executing: ["/bin/sh" "-c" "sleep 180 &&  ANSIBLE_SSH_ARGS='-o StrictHostKeyChecking=no' ansible-playbook -i \"$(terraform output -raw instance_public_ip),\" -u student --private-key ~/.ssh/id_rsa setup-docker-compose.yml"]
yandex_dns_recordset.my_dns_record: Creation complete after 0s [id=dns1m1hetkee27u0siou/vm1.std030-35.momo./A]
null_resource.vm-1: Still creating... [10s elapsed]
null_resource.vm-1: Still creating... [20s elapsed]
null_resource.vm-1: Still creating... [30s elapsed]
null_resource.vm-1: Still creating... [40s elapsed]
null_resource.vm-1: Still creating... [50s elapsed]
null_resource.vm-1: Still creating... [1m0s elapsed]
null_resource.vm-1: Still creating... [1m10s elapsed]
null_resource.vm-1: Still creating... [1m20s elapsed]
null_resource.vm-1: Still creating... [1m30s elapsed]
null_resource.vm-1: Still creating... [1m40s elapsed]
null_resource.vm-1: Still creating... [1m50s elapsed]
null_resource.vm-1: Still creating... [2m0s elapsed]
null_resource.vm-1: Still creating... [2m10s elapsed]
null_resource.vm-1: Still creating... [2m20s elapsed]
null_resource.vm-1: Still creating... [2m30s elapsed]
null_resource.vm-1: Still creating... [2m40s elapsed]
null_resource.vm-1: Still creating... [2m50s elapsed]
null_resource.vm-1: Still creating... [3m0s elapsed]

null_resource.vm-1 (local-exec): PLAY [Setup and run Docker Compose on remote host] *****************************

null_resource.vm-1 (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.vm-1 (local-exec): ok: [51.250.111.72]

null_resource.vm-1 (local-exec): TASK [Create a directory for Minio Compose files] ******************************
null_resource.vm-1 (local-exec): changed: [51.250.111.72]

null_resource.vm-1 (local-exec): TASK [Copy minio-compose.yml to the remote machine] ****************************
null_resource.vm-1: Still creating... [3m10s elapsed]
null_resource.vm-1 (local-exec): changed: [51.250.111.72]

null_resource.vm-1 (local-exec): TASK [Copy nginx.conf to the remote machine] ***********************************
null_resource.vm-1 (local-exec): changed: [51.250.111.72]

null_resource.vm-1 (local-exec): TASK [Change ownership of the files] *******************************************
null_resource.vm-1: Still creating... [3m20s elapsed]
null_resource.vm-1 (local-exec): ok: [51.250.111.72]

null_resource.vm-1 (local-exec): TASK [Run Docker Compose] ******************************************************
null_resource.vm-1: Still creating... [3m30s elapsed]
null_resource.vm-1 (local-exec): changed: [51.250.111.72]

null_resource.vm-1 (local-exec): PLAY RECAP *********************************************************************
null_resource.vm-1 (local-exec): 51.250.111.72              : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

null_resource.vm-1: Creation complete after 3m37s [id=8429391895767647497]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

instance_dns_name = "vm1.std030-35.momo."
instance_public_ip = "51.250.111.72"
minio_url = "http://51.250.111.72:9001"
```
---

<br>  

<div align="center"> 

*Мучения заняли весь день, пришлось изучать много документации, не все было очевидно и сразу понятно, особенно мучался вот с этими ПОСТ действиями, но результат обрадовал, есть код который создает ВМ и поднимает из **docker compose minio**.*  
<br>

В основном вечером мое лицо было таким  
😡😡😡😈😈😈
</div>

---  

<br>  

- Ну и конфиги compose файла для minio (да, я ничего не параметизировал, не до этого было):  
```yaml
services:
  minio:
    image:  quay.io/minio/minio
    container_name: minio
    command: server /data --console-address ":9001"
    volumes:
      - /home/student/minio/data:/data
    expose:
      - "9000"
      - "9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    restart: always
  
  nginx:
    image: nginx:1.19.2-alpine
    container_name: nginx
    hostname: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "9000:9000"
      - "9001:9001"
    depends_on:
      - minio  
    restart: always  
```  
<br>  

- Ну и конфиг ansible

```yaml
---
- name: Setup and run Docker Compose on remote host
  hosts: all
  become: true
  tasks:
    # - name: Wait for SSH to be available
    #   wait_for:
    #     host: "{{ inventory_hostname }}"
    #     port: 22
    #     state: started
    #     timeout: 300 # Ожидаем 5 минут

    - name: Create a directory for Minio Compose files
      file:
        path: "/home/student/minio"
        state: directory
        owner: student
        group: student
        mode: "0755"

    - name: Copy minio-compose.yml to the remote machine
      copy:
        src: "minio-compose.yml"
        dest: "/home/student/minio/minio-compose.yml"
        owner: student
        group: student
        mode: "0644"

    - name: Copy nginx.conf to the remote machine
      copy:
        src: "nginx.conf"
        dest: "/home/student/minio/nginx.conf"
        owner: student
        group: student
        mode: "0644"

    - name: Change ownership of the files
      file:
        path: "/home/student/minio/minio-compose.yml"
        owner: student
        group: student

    - name: Run Docker Compose
      command:
        cmd: "docker compose -f /home/student/minio/minio-compose.yml up -d"
        chdir: "/home/student/minio"

```  
<br> <br> 
---
- Результаты:  
<div align="center">  

![](/images/momo-vm.png)
<br> 

![](/images/momo-network.png)
 
![](/images/minio.png)

---
<br> <br>


![alt text](/images/eralash.png) 
