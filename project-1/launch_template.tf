# Create AMI
resource "aws_ami_from_instance" "ami" {
  name               = var.ami_name
  source_instance_id = aws_instance.server.id
  depends_on = [
    aws_instance.server
  ]
}

# Launch Template
resource "aws_launch_template" "launch-template" {
  name = var.launch_template_name

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 8
      delete_on_termination = true
    }
  }

  image_id = aws_ami_from_instance.ami.id

  instance_type = var.lt_instance_type

  key_name = var.key_name

  network_interfaces {
    delete_on_termination = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "From-ASG"
    }
  }
  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "From-ASG"
    }
  }
  depends_on = [
    aws_ami_from_instance.ami
  ]
}
