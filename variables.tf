variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
variable "data_ingest_cidr_block" {}
variable "data_ingest_rds_cidr_block" {}
variable "peering_cidr_block" {}
variable "az" {}
variable "az2" {}
variable "logging_bucket_id" {}
variable "archive_bucket" {}
variable "archive_bucket_name" {}
variable "apps_buckets_kms_key" {}

variable "dq_database_cidr_block_secondary" {
  type = "list"
}

variable "naming_suffix" {
  default     = false
  description = "Naming suffix for tags, value passed from dq-tf-apps"
}

variable "route_table_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "di_connectivity_tester_db_ip" {
  description = "Mock EC2 database instance."
  default     = "10.1.6.11"
}

variable "di_connectivity_tester_web_ip" {
  description = "Mock EC2 web instance."
  default     = "10.1.6.21"
}

variable "key_name" {
  default     = "test_instance"
  description = "Key name for login."
}

variable "key_name_linux" {
  default     = "test_instance"
  description = "Key name for login."
}

variable "dp_web_private_ip" {
  default     = "10.1.6.100"
  description = "Web server address"
}

variable "dp_web_linux_private_ip" {
  default     = "10.1.6.200"
  description = "Web server address"
}
