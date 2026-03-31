module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "packer-terraform-vpc"
  cidr = "10.0.0.0/16"
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "bastion-sg" {
    source  = "terraform-aws-modules/security-group/aws"
    version = "5.3.1"

    name = "bastion-sg"
    description = "Security group for bastion host"
    vpc_id = module.vpc.vpc_id

    ingress_with_cidr_blocks = [
        {
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = var.my_ip
        }
    ]

    ingress_with_source_security_group_id = [
        {
            from_port                = 9100
            to_port                  = 9100
            protocol                 = "tcp"
            source_security_group_id = module.monitoring-sg.security_group_id
        }
    ]

    egress_rules = ["all-all"]
}

module "private-sg" {
    source  = "terraform-aws-modules/security-group/aws"
    version = "5.3.1"

    name = "private-sg"
    description = "Security group for private instances"
    vpc_id = module.vpc.vpc_id

    ingress_with_source_security_group_id = [
        {
            from_port                = 22
            to_port                  = 22
            protocol                 = "tcp"
            source_security_group_id = module.bastion-sg.security_group_id
        },
        {
            from_port                = 9100
            to_port                  = 9100
            protocol                 = "tcp"
            source_security_group_id = module.monitoring-sg.security_group_id
        }
    ]

    egress_rules = ["all-all"]
}

resource "aws_instance" "bastion" {
    ami                    = var.ami_id
    instance_type          = "t3.micro"
    subnet_id              = module.vpc.public_subnets[0]
    vpc_security_group_ids = [module.bastion-sg.security_group_id]
    associate_public_ip_address = true

    tags = {
        Name = "bastion"
    }
}

resource "aws_instance" "private" {
    count                  = 6
    ami                    = var.ami_id
    instance_type          = "t3.micro"
    subnet_id              = module.vpc.private_subnets[count.index % 3]
    vpc_security_group_ids = [module.private-sg.security_group_id]

    tags = {
        Name = "private-${count.index + 1}"
    }
}