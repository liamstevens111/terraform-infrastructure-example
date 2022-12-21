resource "aws_s3_bucket" "main" {
  bucket = "${var.namespace}-${var.bucket_name}"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.namespace}-${var.bucket_name}"
  }
}

resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}
