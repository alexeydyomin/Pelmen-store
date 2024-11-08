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

