terraform {
  backend "remote" {
    organization = "kuboski2025"

    workspaces {
      name = "AWS-WordPress-Project"
    }
  }
}


provider "aws" {
  region = "us-west-2"  
}

resource "aws_instance" "wordpress" {
  ami           = "ami-0a897ba00eaed7398" 
  instance_type = "t2.micro"
  key_name      = "my-key-pair"  

  tags = {
    Name = "WordPressInstance"
  }
}
