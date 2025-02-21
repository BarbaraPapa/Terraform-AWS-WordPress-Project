# Terraform-AWS-WordPress-Project
Scalable, Fault-Tolerant and Highly Available WordPress Website on AWS using Free Tier
---
## Introduction

This project uses **Terraform** to deploy a scalable and fault-tolerant architecture on **AWS**, designed to host a **WordPress** site. The infrastructure includes **EC2, RDS, ALB, S3**, and an **Auto Scaling** system.

- Read the [Project Documentation](./docs/documentation.md)


## Project Structure
![Screenshot 2025-02-10 133610](https://github.com/user-attachments/assets/3c1bf274-f419-4a1c-8d57-80820681c81e)


The project is organized as follows:

- **VPC and Subnets:** Isolated network with public and private subnets
- **ALB (Application Load Balancer):** Distributes traffic among EC2 instances
- **Auto Scaling Group:** Ensures application availability
- **EC2 with WordPress:** Instances configured with a setup script
- **RDS (MySQL):** Relational database for WordPress
- **S3 Bucket:** Storage for WordPress media files

## Prerequisites

Make sure you have:

- An active **AWS account**
- **AWS CLI** installed and configured
- **Terraform** installed ([Download Terraform](https://developer.hashicorp.com/terraform/downloads))
- An **SSH key** to access EC2 instances

## Setup and Deployment

1. **Clone the repository**
    
    ```sh
    git clone https://github.com/your-username/terraform-aws-wordpress.git
    cd terraform-aws-wordpress
    ```
    
2. **Initialize Terraform**
    
    ```sh
    terraform init
    ```
    
3. **Plan the Deployment**
    
    ```sh
    terraform plan
    ```
    
4. **Apply the Configuration**
    
    ```sh
    terraform apply 
    ```
    
5. **Retrieve the WordPress Site IP**
    
    ```sh
    terraform output
    ```
    
## Infrastructure Removal

To destroy the created infrastructure:

```sh
terraform destroy 
```

## Security Considerations

- **Avoid exposing AWS credentials** in configuration files.
- **Restrict SSH access** to specific IP addresses.
- **Use IAM Roles** instead of static access keys.

---
## Improvements

![Screenshot 2025-02-18 105454](https://github.com/user-attachments/assets/bb8f7b28-020b-4732-93c2-91fd4bc5cbf6)

### This project has been enhanced by incorporating the following AWS services using the **AWS console**  ( Read the [Project Documentation](./docs/documentation.md) for more details ) :

- **Amazon RDS** (MySQL Multi-AZ): Provides a managed, highly available database.

- **Amazon CloudFront**: Caches static content for better performance.

- **Route 53**: Handles domain name resolution.

- **CloudWatch**: Monitors and logs system performance.

---

## License

This project is licensed under the **MIT** license.


