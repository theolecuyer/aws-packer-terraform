packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = "packer-docker-linux"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami = "ami-02dfbd4ff395f2a1b"
  ssh_username = "ec2-user"
}

build {
  name = "packer-docker-linux"
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
        "sudo yum update -y",
        "sudo yum install -y docker",
        "sudo systemctl enable docker",
    ]
  }
}
