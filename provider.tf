// Specify the provider aws
provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    version = ">=4" 
    region = "us-east-1"
    default_tags {
    tags = {
     project = "task-2"
     terraform = true
    }
  }
}


