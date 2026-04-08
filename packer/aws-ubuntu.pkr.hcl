packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = "packer-docker-ubuntu"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami = "ami-04680790a315cd58d"
  ssh_username = "ubuntu"
}

build {
  name = "packer-docker-ubuntu"
  sources = [
    "source.amazon-ebs.amazon-linux"
  ]

  provisioner "file" {
    source      = "/Users/tlecuyer/.ssh/tf-packer.pub"
    destination = "/tmp/tf-packer.pub"
  }

  provisioner "shell" {
    inline = [
        "cat /tmp/tf-packer.pub >> ~/.ssh/authorized_keys",
        "chmod 600 ~/.ssh/authorized_keys",
        "sudo apt-get update -y",
        "sudo apt-get install -y docker.io",
        "sudo systemctl enable docker",
    ]
  }
}
