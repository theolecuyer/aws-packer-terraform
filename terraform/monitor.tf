module "monitoring-sg" {
    source  = "terraform-aws-modules/security-group/aws"
    version = "5.3.1"

    name = "monitoring-sg"
    description = "Security group for monitoring instances"
    vpc_id = module.vpc.vpc_id

    ingress_with_source_security_group_id = [
        {
            from_port                = 22
            to_port                  = 22
            protocol                 = "tcp"
            source_security_group_id = module.bastion-sg.security_group_id
        }
    ]

    egress_rules = ["all-all"]
}

resource "aws_instance" "monitoring-instance" {
    ami                    = var.ami_id
    instance_type          = "t3.micro"
    subnet_id              = module.vpc.private_subnets[0]
    vpc_security_group_ids = [module.monitoring-sg.security_group_id]

    user_data = templatefile("${path.module}/user_data.sh.tpl", {
      all_targets            = concat(aws_instance.private[*].private_ip, [aws_instance.bastion.private_ip, "localhost"])
      grafana_admin_password = var.grafana_admin_password
    })

    tags = {
        Name = "monitoring"
    }
}