# # Route53 zone
# resource "aws_route53_zone" "public-zone" {
#   name = var.domain_name
# }

# # Route53 Record
# resource "aws_route53_record" "server1-record" {
#   zone_id = aws_route53_zone.public-zone.zone_id
#   name    = var.subdomaine_name
#   type    = "A"
#   alias {
#     name                   = aws_lb.test-elb.dns_name
#     zone_id                = aws_lb.test-elb.zone_id
#     evaluate_target_health = true
#   }
# }
