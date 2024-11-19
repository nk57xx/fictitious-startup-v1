# Get Custom AMI created by Packer

data "aws_ami" "custom_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.custom_ami_name}-${var.custom_ami_version}"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#Get Public Subnet Output from Network Workspace

data "tfe_outputs" "network" {
  organization = var.tf_organization
  workspace    = var.tf_network_workspace
}

#Create EC2 instance using custom AMI

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.custom_ami.id
  instance_type               = var.ec2_instance_type
  availability_zone           = var.az
  subnet_id                   = data.tfe_outputs.network.values.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.mvp_sg.id]
  tags = {
    Name = var.ec2_instance_name
  }
}

resource "aws_security_group" "mvp_sg" {
  name        = "mvp_sg"
  description = "Allow inbound traffic"
  vpc_id      = data.tfe_outputs.network.values.vpc
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
