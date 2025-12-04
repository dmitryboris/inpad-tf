variable "yc_token" {
  type        = string
  description = "Yandex.Cloud OAuth token"
}

variable "ssh_public_key" {
  type = string
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex.Cloud Cloud ID"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex.Cloud Folder ID"
}

variable "yc_zone" {
  type        = string
  description = "Yandex.Cloud zone"
  default     = "ru-central1-a"
}

variable "pg_user" {
  type        = string
  description = "Postgres user"
}

variable "pg_password" {
  type        = string
  description = "Postgres password"
}

variable "pg_db" {
  type        = string
  description = "Postgres database name"
}

variable "pg_port" {
  type        = number
  description = "Postgres port"
  default     = 45432
}

variable "rabbit_user" {
  type        = string
  description = "RabbitMQ username"
}

variable "rabbit_password" {
  type        = string
  description = "RabbitMQ password"
}

variable "rabbit_port" {
  type        = number
  description = "RabbitMQ port"
  default     = 5672
}

variable "certificate_id" {
  type        = string
  description = "Certificate id"
}

variable "ip_address" {
  type        = string
  description = "IP address for ALB"
}