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
    # skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    # skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }

  # backend "s3" {
  #   endpoint                    = "http://localhost:9000"
  #   bucket                      = "terraform-state"
  #   key                         = "prod/terraform.tfstate"
  #   region                      = "us-east-1"
  #   access_key                  = "minio-access-key"
  #   secret_key                  = "minio-secret-key"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   force_path_style            = true
  # }
}



provider "yandex" {
  token     = var.IAM_TOKEN
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}
