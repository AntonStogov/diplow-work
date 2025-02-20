 # Создание сервисного аккаунта
 resource "yandex_iam_service_account" "sa" {
   name       = var.account_name
 }

# Назначаем роль editor
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id   = var.folder_id
  role        = "storage.editor"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Создаем статический ключ доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
 service_account_id = yandex_iam_service_account.sa.id
 }

# Используем ключ доступа для создания бакета
resource "yandex_storage_bucket" "sa-bucket" {
  bucket     = "bucket-for-diplom-work"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  anonymous_access_flags {
    read = false
    list = false
  }

  force_destroy = true

provisioner "local-exec" {
  command = "echo export AWS_ACCESS_KEY_ID=${yandex_iam_service_account_static_access_key.sa-static-key.access_key} > ~/diplom-work/terraform/backend.tfvars"
}

provisioner "local-exec" {
  command = "echo export AWS_SECRET_ACCESS_KEY=${yandex_iam_service_account_static_access_key.sa-static-key.secret_key} >> ~/diplom-work/terraform/backend.tfvars"
}
}