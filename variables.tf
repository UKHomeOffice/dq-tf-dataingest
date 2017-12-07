variable "appsvpc_id" {}
variable "opssubnet_cidr_block" {}
variable "data_pipe_apps_cidr_block" {}
variable "data_ingest_cidr_block" {}
variable "az" {}
variable "name_prefix" {}

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
