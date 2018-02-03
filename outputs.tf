output "di_connectivity_tester_web_ip" {
  value = "${var.di_connectivity_tester_web_ip}"
}

output "di_connectivity_tester_db_ip" {
  value = "${var.di_connectivity_tester_db_ip}"
}

output "iam_roles" {
  value = ["${aws_iam_role.data_ingest_iam_role.name}"]
}

output "data_ingest_landing_user_arn" {
  value = "${aws_iam_user.data_ingest_landing.arn}"
}

output "win_instance_id" {
  value = "${aws_instance.di_web.id}"
}
