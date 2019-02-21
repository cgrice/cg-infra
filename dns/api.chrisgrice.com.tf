
# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "example" {
  name    = "api.chrisgrice.com"
  type    = "A"
  zone_id = "${aws_route53_zone.chrisgrice_com.id}"

  alias {
    evaluate_target_health = true
    name                   = "d1dgm2d63rt2ia.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
  }
}


