# Target Group
resource "aws_lb_target_group" "lb-targetgroup" {
  name        = var.target_group_name
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
  depends_on = [
    aws_ami_from_instance.ami
  ]
}

# AWS ApplicationLoad Balancer
resource "aws_lb" "elb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb-sg.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]

  tags = {
    Environment = "production"
  }
}

# HTTP Listener without SSL certficate
# This simply forward Load balancer requests to port 80 of instances in target group
resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.elb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb-targetgroup.id
    type             = "forward"
  }
  depends_on = [
    aws_lb_target_group.lb-targetgroup,
    aws_lb.elb
  ]
}

# # To redirect the https request to http use following configuration
# # To use this configuration an SSL certificate is required

# # HTTPS listener
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.test-elb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.ssl_certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.test-lb-targetgroup.arn
#   }
# }
# # HTTP Listener
# # redirect the request to https
# resource "aws_lb_listener" "http_listener" {
#   load_balancer_arn = aws_lb.test-elb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       host        = "#{host}"
#       path        = "/#{path}"
#       port        = "443"
#       protocol    = "HTTPS"
#       query       = "#{query}"
#       status_code = "HTTP_301"
#     }
#   }
# }


