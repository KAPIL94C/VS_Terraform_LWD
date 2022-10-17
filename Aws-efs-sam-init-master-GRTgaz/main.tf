data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.environment}-efs-sg"
  description = "controls access to efs"

  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Http for vpc"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_efs_file_system" "efs" {
  creation_token                  = var.creation_token
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mib

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "" ? [] : [1]
    content {
      transition_to_ia = var.transition_to_ia
    }
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(var.subnet_ids, count.index)
  ip_address      = var.mount_target_ip_address
  security_groups = [aws_security_group.efs_sg.id]
}
