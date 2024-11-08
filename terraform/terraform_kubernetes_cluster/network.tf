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




