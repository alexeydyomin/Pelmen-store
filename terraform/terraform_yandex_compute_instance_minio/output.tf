# Вывод публичного IP
output "instance_public_ip" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

# Вывод DNS имени
output "instance_dns_name" {
  value = "vm1.std030-35.momo."
}
