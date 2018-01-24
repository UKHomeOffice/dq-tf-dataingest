variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
variable "data_ingest_cidr_block" {}
variable "peering_cidr_block" {}
variable "az" {}
variable "data_landing_bucket" {}
variable "s3_bucket_name" {}
variable "s3_bucket_acl" {}
variable "region" {}

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
