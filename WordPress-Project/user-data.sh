#!/bin/bash

sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

sudo wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo rpm -ivh mysql80-community-release-el7-3.noarch.rpm
sudo yum install -y mysql-community-client

sudo yum install -y php php-mysqlnd php-fpm php-mbstring

cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/wordpress/" wp-config.php # Just for testing, use variables instead of hardcoding
sudo sed -i "s/username_here/admin/" wp-config.php # Just for testing, use variables instead of hardcoding
sudo sed -i "s/password_here/admin1234/" wp-config.php # Just for testing, use variables instead of hardcoding
sudo sed -i "s/terraform-20250217123154656100000006.cryioayygccy.us-west-2.rds.amazonaws.com:3306/$1/" wp-config.php  

sudo systemctl restart httpd








