variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
variable "data_ingest_cidr_block" {}
variable "data_ingest_rds_cidr_block" {}
variable "peering_cidr_block" {}
variable "az" {}
variable "az2" {}
variable "logging_bucket_id" {}

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
  default     = "instance"
  description = "Key name for login."
}

variable "dp_web_private_ip" {
  default     = "10.1.6.100"
  description = "Web server address"
}
