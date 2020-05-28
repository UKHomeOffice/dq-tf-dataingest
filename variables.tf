variable "appsvpc_id" {
}

variable "opssubnet_cidr_block" {
}

variable "data_ingest_cidr_block" {
}

variable "data_ingest_rds_cidr_block" {
}

variable "peering_cidr_block" {
}

variable "az" {
}

variable "az2" {
}

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

variable "route_table_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "dq_lambda_subnet_cidr" {
  default = "10.1.42.0/24"
}

variable "dq_lambda_subnet_cidr_az2" {
  default = "10.1.43.0/24"
}

variable "rds_enhanced_monitoring_role" {
  description = "ARN of the RDS enhanced monitoring role"
}

