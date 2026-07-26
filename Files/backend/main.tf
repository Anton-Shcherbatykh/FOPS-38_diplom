# Создание сервисного аккаунта для Terraform
resource "yandex_iam_service_account" "tf-sa" {
  name        = "tf-service-account"
  description = "Service account for managing infrastructure via Terraform"
  folder_id   = var.yc_folder_id
}

# Назначение минимально необходимых ролей
# Роль editor — для управления большинством ресурсов в каталоге
resource "yandex_resourcemanager_folder_iam_member" "tf-sa-editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.tf-sa.id}"
}

# Роль storage.uploader — для загрузки state-файлов в бакет
resource "yandex_resourcemanager_folder_iam_member" "tf-sa-storage-uploader" {
  folder_id = var.yc_folder_id
  role      = "storage.uploader"
  member    = "serviceAccount:${yandex_iam_service_account.tf-sa.id}"
}

# Создание статического ключа доступа для сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "tf-sa-key" {
  service_account_id = yandex_iam_service_account.tf-sa.id
}

# Создание бакета Object Storage для хранения Terraform State
resource "yandex_storage_bucket" "tf-state" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.tf-sa-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.tf-sa-key.secret_key

  # Настройка жизненного цикла (опционально)
  lifecycle_rule {
    enabled = true
    abort_incomplete_multipart_upload_days = 7
  }
}

# Вывод идентификатора сервисного аккаунта и ключей
output "service_account_id" {
  value = yandex_iam_service_account.tf-sa.id
}

output "access_key" {
  value     = yandex_iam_service_account_static_access_key.tf-sa-key.access_key
  sensitive = true
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.tf-sa-key.secret_key
  sensitive = true
}