# terraform-service-account
resource "yandex_iam_service_account" "terraform_sa" {
  folder_id = var.yc_folder_id
  name      = "terraform-service-account"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_storage_admin" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "storage_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
}

# backend-service-account
resource "yandex_iam_service_account" "backend_sa" {
  folder_id = var.yc_folder_id
  name      = "backend-service-account"
}

resource "yandex_resourcemanager_folder_iam_member" "backend_storage_editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.backend_sa.id}"
}

# alb-service-account
resource "yandex_iam_service_account" "alb_sa" {
  folder_id = var.yc_folder_id
  name      = "alb-service-account"
}

resource "yandex_resourcemanager_folder_iam_member" "alb_admin" {
  folder_id = var.yc_folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.alb_sa.id}"
}

# monitoring-service-account
resource "yandex_iam_service_account" "monitoring_sa" {
  folder_id = var.yc_folder_id
  name        = "monitoring-service-account"
}

resource "yandex_resourcemanager_folder_iam_member" "monitoring_roles" {
  folder_id = var.yc_folder_id
  role   = "monitoring.editor"
  member = "serviceAccount:${yandex_iam_service_account.monitoring_sa.id}"
}
