
# AWS ELB Security Group
resource "aws_security_group" "elb-sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = var.elb_sg_name
  description = "security group for load balancer"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.elb_sg_name
  }

  depends_on = [
    aws_vpc.vpc
  ]
}

# EC2 Security Group
resource "aws_security_group" "ec2-sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = var.ec2_sg_name
  description = "security group for instance"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb-sg.id]
  }

  tags = {
    Name = "myinstance"
  }

  depends_on = [
    aws_security_group.elb-sg
  ]
}

# AWS RDS security Group
resource "aws_security_group" "rds-sg" {
  name        = var.rds_sg_name
  description = "Terraform example RDS MySQL server"
  vpc_id      = aws_vpc.vpc.id
  # Keep the instance private by only allowing traffic from the EC2 Security Group.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ec2-sg.id}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.rds_sg_name
  }

  depends_on = [
    aws_security_group.ec2-sg
  ]
}

