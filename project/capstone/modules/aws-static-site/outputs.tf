output "bucket_name"     { value = aws_s3_bucket.site.id }
output "cloudfront_url"  { value = "https://${aws_cloudfront_distribution.site.domain_name}" }
output "distribution_id" { value = aws_cloudfront_distribution.site.id }
