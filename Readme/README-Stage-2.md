<div align="center"> 

![](/images/logo.png) 

##  *Momo Store aka Пельменная №2 &trade;*
*Сделано пользователем *std-030-35* он же **Алексей Дёмин***

Адрес пельменной  - https://vm.momo-store.cloud-ip.biz/

---
![My Momo Store](/images/storemomo.png "My Momo Store")  

---


## *Второй этап*
</div>

**Требования**:
>
> 🔎 Kubernetes-кластер описан в виде кода, и код хранится в репозитории GitLab   
> 🔎 Конфигурация всех необходимых ресурсов описана согласно IaC    
> 🔎 Состояние Terraform'а хранится в S3  
> 🔎 Картинки, которые использует сайт, или другие небинарные файлы, необходимые для работы, хранятся в S3   
> 🔎 Секреты не хранятся в открытом виде  

---
  
<br>

**Выполненная работа:**

- Был создан новый каталог terraform в репозитории - https://gitlab.praktikum-services.ru/std-030-35/momo-store/-/tree/main/terraform/terraform_kubernetes_cluster

![](/images/ter-repos-kuber.png)  


---

<br>

- **main.tf**

```yaml
resource "yandex_kubernetes_cluster" "kuber-cluster" {
  name        = "momo-kubernetes-cluster"
  description = "Kubernetes for Momo Store"
  network_id  = yandex_vpc_network.momo-net.id

  master {
    public_ip = true
    version   = "1.29"
    zonal {
      zone      = yandex_vpc_subnet.momo-subnet-b.zone
      subnet_id = yandex_vpc_subnet.momo-subnet-b.id
    }
  }

  release_channel         = "STABLE"
  network_policy_provider = "CALICO"
  node_service_account_id = yandex_iam_service_account.docker-registry.id
  service_account_id      = yandex_iam_service_account.instances-editor.id
}

resource "yandex_kubernetes_node_group" "my_node_group" {
  cluster_id = yandex_kubernetes_cluster.kuber-cluster.id
  name       = "momo-node-group"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.momo-subnet-b.id}"]
    }

    resources {
      core_fraction = 20
      memory        = 2
      cores         = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    auto_scale {
      max     = 3
      min     = 2
      initial = 2
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-b"
    }
  }

  maintenance_policy {
    auto_upgrade = false
    auto_repair  = true
  }
}
``` 

---
<br>

- Добавлено хранение состояния terraform в S3 хранилище на базе **Minio**


```yaml
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "= 0.92.0"
    }
  }
  required_version = ">= 0.92.0"

  backend "s3" {
    endpoint = "http://std-030-78.praktikum-services.tech:9000/"

    bucket = "momo-kubernetes"
    region = "ru-central1-b"
    key    = "terraform-state/momo-kuber.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    force_path_style            = true
}

provider "yandex" {
  token     = var.IAM_TOKEN
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}
```
---

<br>

![](/images/s3.png)

---

- **network.tf**

```yaml
resource "yandex_vpc_network" "momo-net" {
  name = "momo-network"
}

resource "yandex_vpc_subnet" "momo-subnet-a" {
  name           = "momo-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.momo-net.id
  v4_cidr_blocks = ["10.200.0.0/16"]
}

resource "yandex_vpc_subnet" "momo-subnet-b" {
  name           = "momo-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.momo-net.id
  v4_cidr_blocks = ["10.201.0.0/16"]
}
```  

---

<br>

- В результате выполнения кода terrafrom получаем рабочий кластер:

![](/images/momo-kub-cluster.png)

![](/images/momo-kub-cluster-2.png)

![](/images/momo-kub-cluster-3.png)  

---

<br>

- Хранение картинок было перенесено в хранилище S3  
<br>

![alt text](/images/images-s3.png)  

---

<br>

Полезные ссылки:  
> - [ Загрузка состояний Terraform в Yandex Object Storage ](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage)
> - [ Начало работы с Managed Service for Kubernetes ](https://yandex.cloud/ru/docs/managed-kubernetes/quickstart?from=int-console-help-center-or-nav)
> - [ Пошаговые инструкции для Managed Service for Kubernetes](https://yandex.cloud/ru/docs/managed-kubernetes/operations/#node-group)
> - [ Взаимосвязь ресурсов в Managed Service for Kubernetes ](https://yandex.cloud/ru/docs/managed-kubernetes/concepts/?from=int-console-help-center-or-nav#node-group)
> - [ Бакет в Object Storage ](https://yandex.cloud/ru/docs/storage/concepts/bucket)
> - [ Справочник Terraform для Yandex Object Storage ](https://yandex.cloud/ru/docs/storage/tf-ref)
> - [ Release channels ](https://yandex.cloud/en/docs/managed-kubernetes/concepts/release-channels-and-updates)
> - [ yandex_kubernetes_node_group ](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_groups)
> - [ Terraform Yandex Cloud modules ](https://github.com/terraform-yc-modules)
> - [ Использование модулей Yandex Cloud в Terraform ](https://yandex.cloud/ru/docs/managed-kubernetes/tutorials/terraform-modules)
> - [ Создание нового Kubernetes-проекта в Yandex Cloud ](https://yandex.cloud/ru/docs/managed-kubernetes/tutorials/new-kubernetes-project)
> - [ Yandex Cloud DNS ](https://yandex.cloud/ru/docs/dns/)
> - [ Getting an IAM token for a Yandex account ](https://yandex.cloud/en/docs/iam/operations/iam-token/create)
> - [ yandex_kubernetes_cluster ](https://terraform-provider.yandexcloud.net/resources/kubernetes_cluster.html)
> - [ yandex_kubernetes_node_group ](https://terraform-provider.yandexcloud.net/resources/kubernetes_node_group.html)

<br>

---

<br>

- В результате мне удалось выполнить все поставленные на второй этап задачи. 👌💪 😎

>
> ✅ Kubernetes-кластер описан в виде кода, и код хранится в репозитории GitLab   
> ✅ Конфигурация всех необходимых ресурсов описана согласно IaC    
> ✅ Состояние Terraform'а хранится в S3  
> ✅ Картинки, которые использует сайт, или другие небинарные файлы, необходимые для работы, хранятся в S3   
> ✅ Секреты не хранятся в открытом виде.
