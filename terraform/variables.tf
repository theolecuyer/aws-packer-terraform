variable "ami_id" {
  type = string
  default = "ami-xxxxxxxxxxxx"
  description = "The AMI ID of the created image"
}

variable "my_ip" {
  type = string
  default = "0.0.0.0/32"
  description = "IP address for BastionSSH Access"
}

variable "grafana_admin_password" {
  type      = string
  default   = "admin"
  sensitive = true
  description = "Grafana admin password"
}