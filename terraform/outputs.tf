output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "amazon-linux_instance_ips" {
  value = aws_instance.amazon-linux[*].private_ip
}

output "ubuntu_instance_ips" {
  value = aws_instance.ubuntu[*].private_ip
}

output "ansible_controller_ip" {
  value = aws_instance.ansible-controller.private_ip
}