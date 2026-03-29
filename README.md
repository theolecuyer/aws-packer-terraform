# aws-packer-terraform

IAC project using Packer and Terraform to build a custom AWS AMI and provision a VPC, subnets, bastion host, and private EC2 instances.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Building the AMI with Packer](#part-1-building-the-ami-with-packer)

> **Note:** Follow the sections in order to run this project successfully.

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) installed
- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- AWS CLI configured with valid credentials
- An SSH key pair (see below)

### Generating an SSH Key

```bash
ssh-keygen -t rsa -C "your_email@example.com" -f ~/.ssh/tf-packer
```

## Part 1: Building the AMI with Packer

### What the AMI includes

- Amazon Linux 2023
- Docker (enabled on boot)
- SSH public key baked in for key-based access

### How to build

#### Note, insert the location of your tf-packer.pub key on your machine in the source provisioner of `aws-amazonlinux.pkr.hcl`

```bash
cd packer/
packer init .
packer build aws-amazonlinux.pkr.hcl
```

### Upon running the build command, you should see the build status complete and return your new private ami id.

![Packer build output](screenshots/packer-build.png)

### Verify in the AWS Console that you have successfully created the image

![Packer AMI](screenshots/packer-ami.png)

## Part 2: Provisioning Infrastructure with Terraform
