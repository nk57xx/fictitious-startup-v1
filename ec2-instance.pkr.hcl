packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
  required_plugins {
    amazon-ami-management = {
      version = ">= 1.6.1"
      source  = "github.com/wata727/amazon-ami-management"
    }
  }
}

variable version {}
variable vpc_id {}
variable subnet_id {}

locals {
  ami_name = "cloudtalents-fictitious-startup"
  source_ami_name = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server*"
  source_ami_owner = ["099720109477"]
  ssh_username = "ubuntu"
  region = "eu-west-1"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${local.ami_name}-${var.version}"
  instance_type = "t2.micro"
  region        = local.region

  source_ami_filter {
    filters = {
      name                = local.source_ami_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = local.ssh_username
  vpc_id       = var.vpc_id
  subnet_id    = var.subnet_id
  associate_public_ip_address = true
}

build {
  name = "custom_ami_cloudtalents"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source = "./"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = [
    "echo creating directory",
    "sudo mkdir /opt/app",
    "echo move files into directory",
    "sudo mv /tmp/* /opt/app",
    "sudo chmod +x /opt/app/setup.sh"
    ]
  }

  provisioner "shell" {
    script = "setup.sh"
  }

  post-processor "amazon-ami-management" {
    regions = ["eu-west-1"]
    identifier = local.ami_name
    keep_releases = 2
  }
}