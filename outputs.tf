output "di_connectivity_tester_web_ip" {
  value = "${var.di_connectivity_tester_web_ip}"
}

output "di_connectivity_tester_db_ip" {
  value = "${var.di_connectivity_tester_db_ip}"
}

output "data_ingest_iam_role" {
  value = "${aws_iam_role.data_ingest_iam_role.name}"
}
