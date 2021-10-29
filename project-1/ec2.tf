
# EC2 Instance
resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type
  key_name      = aws_key_pair.testkeypair.key_name

  subnet_id = aws_subnet.public-subnet-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  user_data = data.template_file.init.rendered
  tags = {
    Name = var.server_name
  }
  depends_on = [
    aws_db_instance.rds
  ]
}
