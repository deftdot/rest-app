resource "aws_s3_bucket" "rest-app-bucket-01" {
  bucket = "rest-app-bucket-01"
}

resource "aws_s3_bucket_ownership_controls" "acl-own" {
  bucket = aws_s3_bucket.rest-app-bucket-01.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "rest-app-bucket-01-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.acl-own]

  bucket = aws_s3_bucket.rest-app-bucket-01.id
  acl    = "private"
}

resource "aws_s3_object" "rest-app" {
  bucket = aws_s3_bucket.rest-app-bucket-01.bucket
  key    = "main.py"
  source = "../main.py"
  acl    = "private"
}

resource "aws_s3_object" "rest-app-req" {
  bucket = aws_s3_bucket.rest-app-bucket-01.bucket
  key    = "requirements.txt"
  source = "../requirements.txt"
  acl    = "private"
}

resource "aws_s3_object" "rest-app-data" {
  bucket = aws_s3_bucket.rest-app-bucket-01.bucket
  key    = "restlist.json"
  source = "../restlist.json"
  acl    = "private"
}

resource "aws_s3_object" "rest-app-load" {
  bucket = aws_s3_bucket.rest-app-bucket-01.bucket
  key    = "db_load.py"
  source = "../db_load.py"
  acl    = "private"
}
