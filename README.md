# Terraform and Ansible Automated Infrastructure Setup

## Overview

This project uses Terraform to create the following infrastructure on AWS:
- Jenkins Master (Apache + Jenkins)
- Jenkins Slave (JDK + Jenkins)
- Web Server (Docker + WildFly)

Ansible is used to configure the software on the EC2 instances.

## Prerequisites

- Terraform installed
- Ansible installed
- AWS CLI configured with appropriate permissions
- An SSH key pair for accessing the EC2 instances


