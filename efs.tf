
resource "aws_efs_file_system" "example" {
  encrypted = true
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  tags = {
    Name = "example-efs"
  }
}

resource "aws_efs_mount_target" "example1" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id = aws_subnet.private[0].id # Replace with the subnet ID in the first AZ
 security_groups = [ aws_security_group.efs.id ] # Replace with the security group ID
}

resource "aws_efs_mount_target" "example2" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id = aws_subnet.private[1].id  # Replace with the subnet ID in the second AZ
  security_groups = [ aws_security_group.efs.id ] # Replace with the security group ID
}

