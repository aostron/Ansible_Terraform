#!/bin/bash

# Generate self-signed certificate
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    -keyout /etc/ssl/private/www.example.com.key \
    -out /etc/ssl/certs/www.example.com.cert

# Update and install necessary packages
sudo apt-get update -y
sudo apt-get install -y apache2 openjdk-11-jdk wget

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -y
sudo apt-get install -y jenkins

# Enable and start services
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable jenkins
sudo systemctl start jenkins
