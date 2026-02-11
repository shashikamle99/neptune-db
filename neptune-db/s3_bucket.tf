resource "aws_s3_bucket" "kb_data" {
  bucket = "my-bedrock-kb-data-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_ownership_controls" "kb_data" {
  bucket = aws_s3_bucket.kb_data.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "kb_data" {
  depends_on = [aws_s3_bucket_ownership_controls.kb_data]
  bucket     = aws_s3_bucket.kb_data.id
  acl        = "private"
}

# Upload your documents here: aws s3 cp docs/ s3://${aws_s3_bucket.kb_data.bucket}/data/