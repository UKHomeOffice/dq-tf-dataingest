output "di_subnet_id" {
  value = "${aws_subnet.data_ingest.id}"
}

output "di_db_sg" {
  value = "${aws_security_group.di_db.id}"
}

output "di_web_sg" {
  value = "${aws_security_group.di_web.id}"
}
