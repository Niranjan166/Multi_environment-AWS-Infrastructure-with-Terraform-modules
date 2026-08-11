output "db_endpoint" {
    description = "connection endpoint of the RDS instance"
    value = aws_db_instance.main.endpoint
}

output "db_port" {
    description = "connection port of the RDS instance"
    value = aws_db_instance.main.port
}

output "db_name" {
    description = "name of the database created in the RDS instance"
    value = aws_db_instance.main.db_name  
}

output "rds_security_group_id" {
    description = "security group id of the RDS instance"
    value = aws_security_group.rds.id
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.identifier
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}