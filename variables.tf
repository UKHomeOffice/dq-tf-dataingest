variable "logging_bucket_id" {
}

variable "archive_bucket" {
}

variable "archive_bucket_name" {
}

variable "apps_buckets_kms_key" {
}

variable "environment" {
}

variable "naming_suffix" {
  default     = false
  description = "Naming suffix for tags, value passed from dq-tf-apps"
}
