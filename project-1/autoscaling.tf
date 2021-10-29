# AutoScaling Group
resource "aws_autoscaling_group" "autoscaling" {
  name                = var.autoscaling_name
  vpc_zone_identifier = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.lb-targetgroup.arn]

  min_size                  = 1
  desired_capacity          = 1
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  tag {
    key                 = "Name"
    value               = var.project_name
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  depends_on = [
    aws_launch_template.launch-template,
    aws_lb.elb
  ]
}

# Autoscaling Scaling policy
resource "aws_autoscaling_policy" "cpu-policy" {
  name                   = var.cpu_policy_name
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
