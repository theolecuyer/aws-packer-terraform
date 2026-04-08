variable "linux_ami_id" {
  type = string
  default = "ami-xxxxxxxxxxxx"
  description = "The AMI ID of the created image"
}

variable "ubuntu_ami_id" {
  type = string
  default = "ami-xxxxxxxxxxxx"
  description = "The AMI ID of the created image"
}

variable "my_ip" {
  type = string
  default = "0.0.0.0/32"
  description = "IP address for BastionSSH Access"
}

variable "ssh_private_key_path" {
  type        = string
  default     = "~/.ssh/tf-packer"
  description = "Path to the SSH private key used by the Ansible controller"
}