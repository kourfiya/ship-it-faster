provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "blog" {
  bucket = "ship-it-faster"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket_policy" "blog_policy" {
  bucket = aws_s3_bucket.blog.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.blog.arn}/*"
    }]
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.blog.website_endpoint
    origin_id   = "ship-it-faster"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ship-it-faster"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "s3_website_url" {
  value = aws_s3_bucket.blog.website_endpoint
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

