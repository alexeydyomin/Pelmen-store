variable "IAM_TOKEN" {
  type = string
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}


variable "is_preemptible" {
  description = "default is_preemptible"
  type        = bool
  default     = false
}

variable "cores" {
  description = "default cores number"
  type        = number
  default     = 2
}

variable "memory" {
  description = "default memory number"
  type        = number
  default     = 4
}

variable "zone" {
  description = "zone"
  type        = string
  default     = "ru-central1-b"
}

variable "platform_id" {
  description = "platform_id"
  type        = string
  default     = "standard-v1"
}

variable "image_id" {
  description = "image_id"
  type        = string
  default     = "fd885unga0d8prsl1acs"
}

variable "size" {
  description = "Size of the disk in GB"
  type        = number
  default     = 20
}
