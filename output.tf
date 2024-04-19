output "alb_output" {
  value = aws_lb.apache_LB_2.dns_name
}

output "aws_instance_1_public_ip" {
  value = aws_instance.card_website_01.public_ip
}