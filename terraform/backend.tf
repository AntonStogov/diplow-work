terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "bucket-for-diplom-work"
    region = "ru-central1"
    key    = "for-state/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}