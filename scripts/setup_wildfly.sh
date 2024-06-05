#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y apache2 openjdk-11-jdk wget

# Install WildFly
wget https://download.jboss.org/wildfly/23.0.2.Final/wildfly-23.0.2.Final.zip
unzip wildfly-23.0.2.Final.zip
sudo mv wildfly-23.0.2.Final /opt/wildfly
sudo /opt/wildfly/bin/add-user.sh -u admin -p admin -g admin

# Start WildFly
sudo /opt/wildfly/bin/standalone.sh &

# Enable and start Apache
sudo systemctl enable apache2
sudo systemctl start apache2