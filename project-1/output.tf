output "elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = aws_lb.elb.dns_name
}
output "elb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = aws_lb.elb.zone_id
}