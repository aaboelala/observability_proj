terraform {
  backend "s3" {
    bucket = "arnold-trent-terraform-state-bucket"
    region = "us-east-1" # تأكد تطابق region مع الـ bucket
    key    = "terraform-state/observe-app/eks.tfstate"
  }
}
