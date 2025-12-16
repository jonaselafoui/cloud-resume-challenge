resource "aws_route53_zone" "jonas_ma_zone" {
  name = "jonas.ma."
}

resource "aws_route53_record" "jonas_ma_record" {
  zone_id = aws_route53_zone.jonas_ma_zone.zone_id
  name    = "jonas.ma."
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}