output "di_connectivity_tester_web_ip" {
  value = "${var.di_connectivity_tester_web_ip}"
}

output "di_connectivity_tester_db_ip" {
  value = "${var.di_connectivity_tester_db_ip}"
}

output "iam_roles" {
  value = ["${aws_iam_role.data_ingest_iam_role.name}"]
}
