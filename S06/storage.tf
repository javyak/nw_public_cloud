# S3 Bucket to store the images of the IoT portal webpage

resource "aws_s3_bucket" "web_bucket" {
  bucket = "iotportal.javyak.local.lan"
  acl = "public-read"
}

resource "aws_s3_bucket_object" "web_image" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key = "image.jpg"
  source = var.web_server_image
  acl = "public-read"
}
