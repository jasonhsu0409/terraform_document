
/*
// Create rds subnet
resource "aws_db_subnet_group" "example" {
  name        = "example-rds"
  subnet_ids = [aws_subnet.private[2].id,aws_subnet.private[3].id]
}
// Create rds
resource "aws_db_instance" "example" {
  identifier            = "examplerds6689"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t2.micro"
  db_name               = "examplerds6689"
  username              = var.rds_username
  password              = var.rds_password
  db_subnet_group_name  = aws_db_subnet_group.example.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  // avoid deletion error
  skip_final_snapshot = true
}

*/