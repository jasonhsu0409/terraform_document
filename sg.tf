// Create bastion sg
resource "aws_security_group" "bastion" {
  name_prefix = "example-bastion"
  vpc_id = aws_vpc.example.id
  // Set inbound rules
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  // Set outbound rules
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.cidr_all]
  }
  tags = {
    Name = "bastion"
  }
}


// Create web sg
resource "aws_security_group" "web" {
  name_prefix = "jason-web"
  vpc_id = aws_vpc.example.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.cidr_all]
  }

  tags = {
    Name = "example-web"
  }
}

// Create rds sg
resource "aws_security_group" "rds" {
  name_prefix = "jason-rds"
   vpc_id = aws_vpc.example.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.cidr_all]
  }
}

// Create alb sg
resource "aws_security_group" "alb" {
  name_prefix = "jason-alb"
  vpc_id = aws_vpc.example.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.cidr_all]
  }
  tags = {
    Name = "example-alb"
  }
}

// Create efs sg
resource "aws_security_group" "efs" {
  name_prefix = "example-efs"
  vpc_id = aws_vpc.example.id
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    security_groups = [aws_security_group.web.id]
  }
}
