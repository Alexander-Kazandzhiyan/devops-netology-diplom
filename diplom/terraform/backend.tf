terraform {
  backend "s3" {
    bucket = "diplom-akazand-backend-tfstate"
    key = "main-infra/terraform.tfstate"
    region = "us-east-1"
    }
}
