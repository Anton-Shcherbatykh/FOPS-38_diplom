output "k8s_master_ip" {
  description = "Публичный IP мастер-узла"
  value       = yandex_compute_instance.k8s_node[0].network_interface.0.nat_ip_address
}

output "k8s_nodes_ips" {
  description = "Публичные IP всех узлов"
  value       = yandex_compute_instance.k8s_node[*].network_interface.0.nat_ip_address
}

output "k8s_workers_ips" {
  description = "Публичные IP воркеров"
  value       = slice(yandex_compute_instance.k8s_node[*].network_interface.0.nat_ip_address, 1, 3)
}

output "k8s_private_ips" {
  description = "Внутренние IP всех узлов"
  value       = yandex_compute_instance.k8s_node[*].network_interface.0.ip_address
}