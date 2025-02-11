terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
  profile = "default"
}

resource "aws_instance" "wordpress" {
  ami           = "ami-0a897ba00eaed7398"
  instance_type = "t2.micro"
  key_name      = "my-key-pair"

  tags = {
    Name = "WordPressInstance"
  }
}
