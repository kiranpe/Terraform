resource "aws_security_group" "sec_grp" {
  name        = "k8s_secgrp"
  description = "k8s cluster sec grp"

  dynamic "ingress" {
    for_each = var.ports

    content {
      description = "k8s sec grp"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "k8s sec grp"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "k8s sec grp"
    from_port   = 3000
    to_port     = 11000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8ssecgrp"
  }
}
