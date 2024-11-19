variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "custom_ami_version" {
  description = "Custom AMI version"
}

variable "custom_ami_name" {
  description = "Custom AMI name"
  type        = string
  default     = "cloudtalents-fictitious-startup"
}

variable "tf_organization" {
  description = "Terraform organization"
  type        = string
  default     = "nk57xx"
}

variable "tf_network_workspace" {
  description = "Terraform network workspace"
  type        = string
  default     = "Network"
}

variable "ec2_instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "cloudtalents-fictitious-startup"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "az" {
  description = "Availability zone"
  type        = string
  default     = "eu-west-1c"
}
