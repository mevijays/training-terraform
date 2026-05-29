# Module: aws-static-site

Stands up a private S3 bucket, a CloudFront distribution with Origin Access Control, a bucket policy that restricts S3 reads to that distribution, and seeds an `index.html`.

## Usage

```hcl
module "static_site" {
  source = "../../modules/aws-static-site"
  name   = "novapay-dev"
  tags   = local.common_tags
}

output "cloudfront_url" { value = module.static_site.cloudfront_url }
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — | Base name; bucket gets a 4-byte random suffix to satisfy global uniqueness |
| `tags` | map(string) | `{}` | Tags |

## Outputs

| Name | Description |
|---|---|
| `bucket_name` | S3 bucket name |
| `cloudfront_url` | `https://...cloudfront.net` URL for the distribution |
| `distribution_id` | CloudFront distribution ID |

## Notes

- Uses **Origin Access Control** (OAC, modern) rather than the legacy Origin Access Identity (OAI).
- The S3 bucket has `block_public_access = all` and `SSE-S3` encryption.
- For a custom domain, add an ACM cert in `us-east-1` and a Route 53 record pointing at the distribution.
- CloudFront distributions take ~10-15 min to fully propagate after `apply`.
