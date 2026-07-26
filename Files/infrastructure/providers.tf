terraform {
  required_version = "~>1.15.0"

  backend "s3" {
    bucket                  = "shcherbatykh-state-bucket"
    region                  = "ru-central1"
    key                     = "infrastructure/terraform.tfstate"
    encrypt                 = false
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
  }

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.158.0"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.zone
}