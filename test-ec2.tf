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
  region  = "us-west-2"
  profile = "default"
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}


resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "MainSubnet"
  }
}


resource "aws_instance" "wordpress" {
  ami           = "ami-0a897ba00eaed7398"
  instance_type = "t2.micro"
  key_name      = "my-key-pair"
  subnet_id     = aws_subnet.main_subnet.id

  tags = {
    Name = "WordPressInstance"
  }
}

