packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = "packer-docker-node-exporter"
  instance_type = "t3.micro"
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
        "curl -sL https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz -o /tmp/node_exporter.tar.gz",
        "tar -xzf /tmp/node_exporter.tar.gz -C /tmp",
        "sudo mv /tmp/node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/",
        "sudo useradd -rs /bin/false node_exporter",
        "sudo bash -c 'cat > /etc/systemd/system/node_exporter.service << EOF\n[Unit]\nDescription=Node Exporter\nAfter=network.target\n\n[Service]\nUser=node_exporter\nExecStart=/usr/local/bin/node_exporter\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\nEOF'",
        "sudo systemctl daemon-reload",
        "sudo systemctl enable node_exporter",
    ]
  }
}
