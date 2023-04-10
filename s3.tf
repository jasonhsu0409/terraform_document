// Create S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "ecloudexample"
  acl    = "public-read"
  website {
    index_document = "index.html"
  }
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","PUT","POST", "DELETE","HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}
// Upload object to S3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = aws_s3_bucket.example.id
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
  acl    = "public-read"
}

