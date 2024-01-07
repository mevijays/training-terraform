output "my_instance_public_ip" {
  value = "This is my ec2 public ip: - ${aws_instance.main.public_ip}"
}