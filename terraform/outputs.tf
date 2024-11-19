output "ec2_public_ip" {
  description = "public ip of ec2 instance"
  value       = aws_instance.ec2_instance.public_ip
}
