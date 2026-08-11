# db subnet group
# RDS can only be launched inside subnets that belong to this subnet group.
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  description   = "Subnet group for RDS instance"
  subnet_ids = var.private_subnet_ids  

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

# security groups for RDS

resource "aws_security_group" "rds" {
  name     =  "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow MySQL traffic from EC2 only"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-sg"
 })
}

/* db parameter group -- we are not using db parameter because in this 
project its not required, and without it aws automatically assings a 
default parameter group to rds
Default parameter grp has std MYSQL settings which work fine 
for most projects */

# rds instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-rds-instance"
  
  allocated_storage = var.allocated_storage
  max_allocated_storage = var.allocated_storage * 2
  storage_type = "gp3"
  storage_encrypted = true

  engine = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  db_name = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible = false

  multi_az = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window = "03:00-04:00"

  maintenance_window = "Mon:04:00-Mon:05:00"
  auto_minor_version_upgrade = true

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-instance"
 }) 
}