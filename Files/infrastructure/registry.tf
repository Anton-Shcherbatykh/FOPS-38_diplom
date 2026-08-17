# --- Сервисные аккаунты для работы с Container Registry ---

# Сервисный аккаунт для узлов Kubernetes (скачивание образов)
resource "yandex_iam_service_account" "k8s_node_sa" {
  name        = "k8s-node-sa"
  description = "Service account for Kubernetes nodes to pull images from Container Registry"
  folder_id   = var.yc_folder_id
}

# Назначение роли puller для узлов
resource "yandex_resourcemanager_folder_iam_member" "k8s_node_sa_puller" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_node_sa.id}"
}

# Сервисный аккаунт для CI/CD (загрузка образов)
resource "yandex_iam_service_account" "ci_sa" {
  name        = "ci-sa"
  description = "Service account for CI/CD to push images to Container Registry"
  folder_id   = var.yc_folder_id
}

# Назначение роли pusher для CI
resource "yandex_resourcemanager_folder_iam_member" "ci_sa_pusher" {
  folder_id = var.yc_folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.ci_sa.id}"
}

# --- Container Registry ---
resource "yandex_container_registry" "test_registry" {
  name      = "test-registry"
  folder_id = var.yc_folder_id
}

# --- Выходные переменные для дальнейшего использования ---
output "registry_id" {
  description = "ID of the created Container Registry"
  value       = yandex_container_registry.test_registry.id
}

output "k8s_node_sa_id" {
  description = "ID of the service account for Kubernetes nodes"
  value       = yandex_iam_service_account.k8s_node_sa.id
}

output "ci_sa_id" {
  description = "ID of the service account for CI/CD"
  value       = yandex_iam_service_account.ci_sa.id
}