resource "aws_db_instance" "rds_postgres" {
  db_name             = "mvp"
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = var.rds_instance_class
  username            = var.db_username
  password            = var.db_password
  allocated_storage   = 10
  skip_final_snapshot = true
  multi_az            = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  parameter_group_name = aws_db_parameter_group.rds_pg.name

  tags = {
    Name = var.rds_instance_name
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "mvp-rds_subnet_group"
  subnet_ids = data.tfe_outputs.network.values.private_subnets[*]
  tags = {
    Name = "RDS Subnet Group - ${var.rds_instance_name}"
  }
}

resource "aws_db_parameter_group" "rds_pg" {
  name   = "mvp-rds-pg"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "mvp-rds-sg"
  description = "Allow traffic to RDS from EC2 and DMS"
  vpc_id      = data.tfe_outputs.network.values.vpc

  ingress {
    description     = "EC2 and DMS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.mvp_sg.id, aws_security_group.dms_sec_group.id]
  }
}
