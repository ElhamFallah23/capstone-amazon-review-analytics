
terraform {
  backend "s3" {
    bucket         = "capstone-terraform-state-bucket-dev"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "capstone-tf-locks-dev"
    encrypt        = true
  }
}

