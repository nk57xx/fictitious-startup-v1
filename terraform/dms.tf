resource "aws_dms_replication_instance" "aws_dms_replication_instance" {
  count                       = 0
  allocated_storage           = 10
  apply_immediately           = true
  multi_az                    = false
  replication_instance_class  = var.replication_instance_class
  replication_instance_id     = var.replication_instance_name
  replication_subnet_group_id = aws_dms_replication_subnet_group.aws_dms_replication_subnet_group.id
  vpc_security_group_ids      = [aws_security_group.dms_sec_group.id]
  depends_on                  = [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole]


  tags = {
    Name = var.replication_instance_name
  }
}

resource "aws_iam_role" "dms-vpc-role" {
  name = "dms-vpc-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dms.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  role       = aws_iam_role.dms-vpc-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_dms_replication_subnet_group" "aws_dms_replication_subnet_group" {
  replication_subnet_group_description = "DMS subnet group"
  replication_subnet_group_id          = "dms-subnet-group"
  subnet_ids                           = data.tfe_outputs.network.values.private_subnets[*]
  depends_on                           = [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole]
}

resource "aws_security_group" "dms_sec_group" {
  name        = "dms_sec_group"
  description = "Allow DMS inbound traffic"
  vpc_id      = data.tfe_outputs.network.values.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_dms_endpoint" "aws_dms_endpoint_source" {
  count         = 0
  database_name = "mvp"
  endpoint_id   = "ec2"
  endpoint_type = "source"
  engine_name   = "postgres"
  username      = var.db_username
  password      = var.db_password
  port          = 5432
  server_name   = aws_instance.ec2_instance.private_ip
  ssl_mode      = "none"
}

resource "aws_dms_endpoint" "aws_dms_endpoint_target" {
  count         = 0
  database_name = "mvp"
  endpoint_id   = "rds"
  endpoint_type = "target"
  engine_name   = "postgres"
  username      = var.db_username
  password      = var.db_password
  port          = 5432
  server_name   = aws_db_instance.rds_postgres.address
  ssl_mode      = "none"
}

resource "aws_dms_replication_task" "aws_dms_replication_task" {
  count                    = 0
  migration_type           = "full-load"
  replication_instance_arn = aws_dms_replication_instance.aws_dms_replication_instance[count.index].replication_instance_arn
  #replication_instance_arn = aws_dms_replication_instance.aws_dms_replication_instance.replication_instance_arn
  replication_task_id = "database-replication"
  source_endpoint_arn = aws_dms_endpoint.aws_dms_endpoint_source[0].endpoint_arn
  #source_endpoint_arn = aws_dms_endpoint.aws_dms_endpoint_source.endpoint_ar
  target_endpoint_arn = aws_dms_endpoint.aws_dms_endpoint_target[0].endpoint_arn
  #target_endpoint_arn = aws_dms_endpoint.aws_dms_endpoint_target.endpoint_arn
  table_mappings = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
}
