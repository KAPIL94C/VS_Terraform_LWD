output "efs_id" {
  description = "Id of the EFS file system."
  value       = aws_efs_file_system.efs.id
}

output "efs_dns_name" {
  description = "List of DNS mount points, one per subnet."
  value       = aws_efs_mount_target.efs_mount_target.*.dns_name
}

