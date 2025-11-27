terraform {
    backend "s3" {
        bucket         = "ahmed-terraform-state-bucket"
        key            = "eks/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "terraform-lock-table"
        encrypt        = true
    }
}