### NOTE ###
#! This code is written for testing purposes only
# Avoid exposing AWS credentials in configuration files.
# Restrict SSH access to specific IPs only.
# Use IAM Roles instead of static access keys.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Variables
variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "my-key-pair" #! Just for testing
}

variable "db_name" {
  default = "wordpress"
}

variable "db_user" {
  default = "admin" #! Just for testing
}

variable "db_password" {
  default = "admin1234"  #! Just for testing
  sensitive   = true
}

variable "db_allocated_storage" {
  default = 20
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "WP-VPC"
  }
}

# Pubblic Subnet WP EC2 
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

    tags = {
    Name = "WP-Pubblic1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"

    tags = {
    Name = "WP-Pubblic2"
  }
}

# Private Subnet for RDS
resource "aws_subnet" "private_subnet_db1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"

    tags = {
    Name = "WP-Privat-DB1"
  }
}

resource "aws_subnet" "private_subnet_db2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"

    tags = {
    Name = "WP-Privat-DB2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

    tags = {
    Name = "WP-IGW"
  }
}

# Pubblic Route Table 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Groups
resource "aws_security_group" "alb_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "WP-ALB-SG"
  }
}

resource "aws_security_group" "ec2_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #! Just for testing
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "WP-EC2-SG"
  }
}

resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "WP-RDS-SG"
  }
}

# Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "MyWordPressALB"
  internal           = false
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  load_balancer_type = "application"
  idle_timeout       = 60 

  tags = {
    Name = "WP-ALB"
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "MyTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/" 
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}


# RDS Database
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "mydbsubnetgroup"
  subnet_ids = [aws_subnet.private_subnet_db1.id, aws_subnet.private_subnet_db2.id]
}

resource "aws_db_instance" "my_rds_instance" {
  allocated_storage    = var.db_allocated_storage
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  instance_class      = "db.t3.micro"
  engine              = "mysql"
  db_name             = var.db_name
  username            = var.db_user
  password            = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  publicly_accessible   = false

  skip_final_snapshot = true # no final snapshot is created  #! Just for testing
  # to keep a final snapshot, use this line instead
  # final_snapshot_identifier = "final-snapshot-rds"

  tags = {
    Name = "WP-RDS-instance"
  }
}


# Null resource to update user-data.sh with DB endpoint
resource "null_resource" "update_user_data" {
  depends_on = [aws_db_instance.my_rds_instance, aws_launch_template.my_launch_template]

  provisioner "local-exec" {
    command = "sed -i 's/localhost/${aws_db_instance.my_rds_instance.endpoint}/' ${path.module}/user-data.sh"
  }
}


# Launch Template for EC2 Instances
resource "aws_launch_template" "my_launch_template" {
  name = "MyLaunchTemplate"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_security_group.id]
  }

  instance_type = var.instance_type
  key_name      = var.key_name
  image_id      = "ami-0a897ba00eaed7398" # Amazon Linux (us-west-2) 

  user_data = filebase64("${path.module}/user-data.sh")
}


# Auto Scaling Group
resource "aws_autoscaling_group" "my_autoscaling_group" {
  vpc_zone_identifier = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  min_size         = 1
  max_size         = 3
  desired_capacity = 2
  target_group_arns = [aws_lb_target_group.my_target_group.arn]
}

# S3 bucket
resource "aws_s3_bucket" "media_s3_bucket" {
  bucket = "wp-media-files-bucket-kuboski2025" #! Just for testing
}



# Outputs
output "rds_endpoint" {
  value = aws_db_instance.my_rds_instance.endpoint
}

output "website_url" {
  value = "http://${aws_lb.my_alb.dns_name}"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.media_s3_bucket.bucket
}

