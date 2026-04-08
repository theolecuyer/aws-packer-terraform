resource "aws_instance" "ansible-controller" {
    ami                    = var.ubuntu_ami_id
    instance_type          = "t3.micro"
    subnet_id              = module.vpc.private_subnets[0]
    vpc_security_group_ids = [module.private-sg.security_group_id]

    tags = {
        Name = "ansible-controller"
    }

    user_data = templatefile("scripts/controller.sh", {
      inventory = templatefile("scripts/inventory.tftpl", {
        ubuntu_ips = aws_instance.ubuntu[*].private_ip
        amazon_ips = aws_instance.amazon-linux[*].private_ip
      })
      ssh_private_key = file(var.ssh_private_key_path)
      playbook        = file("scripts/playbook.yml")
    })
}