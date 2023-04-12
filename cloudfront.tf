// Create cloudfront
resource "aws_cloudfront_distribution" "example" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "My CloudFront Distribution"

  viewer_certificate {
    cloudfront_default_certificate = true
  }
   restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  // Set alb as origin
  origin {
    domain_name = aws_lb.example.dns_name
    origin_id   = "my-origin-id"
    custom_origin_config {
      http_port                 = 80
      https_port                = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols      = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET", "OPTIONS"]
    cached_methods  = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "my-origin-id"
    forwarded_values {
      query_string = false
      headers      = ["*"]
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                 = 0
    default_ttl             = 3600
    max_ttl                 = 86400
    compress                = true
  }
}

