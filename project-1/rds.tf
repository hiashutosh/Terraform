# RDS Subnet Group
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  tags = {
    Name = var.db_subnet_group_name
  }
  depends_on = [
    aws_security_group.rds-sg
  ]
}

# RDS Instnace
resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.rds_instance_class
  name                   = var.rds_database_name
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  max_allocated_storage  = 20
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  depends_on = [
    aws_security_group.rds-sg
  ]
}
