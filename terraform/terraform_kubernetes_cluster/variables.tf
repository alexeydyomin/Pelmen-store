variable "IAM_TOKEN" {
  type = string
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  description = "zone"
  type        = string
  default     = "ru-central1-b"
}
