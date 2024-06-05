provider "aws" {
  region = "eu-north-1"
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "webserver-test" {
  name        = "WebServer Security Group 3"
  description = "My First SecurityGroup"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name  = "Web"
    Owner = "Oleksandr"
  }
}

resource "aws_instance" "jenkins_master" {
  ami                    = "ami-0fe8bec493a81c7da" # Ubuntu 22
  instance_type          = "t3.small"
  key_name               = "AdminE2C_key"
  vpc_security_group_ids = [aws_security_group.webserver-test.id]
  tags = {
    Name  = "Jenkins Master"
    Owner = "Oleksandr"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami                    = "ami-0fe8bec493a81c7da" # Ubuntu 22
  instance_type          = "t3.micro"
  key_name               = "AdminE2C_key"
  vpc_security_group_ids = [aws_security_group.webserver-test.id]
  tags = {
    Name  = "Jenkins Slave"
    Owner = "Oleksandr"
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0fe8bec493a81c7da" # Ubuntu 22
  instance_type          = "t3.micro"
  key_name               = "AdminE2C_key"
  vpc_security_group_ids = [aws_security_group.webserver-test.id]
  tags = {
    Name  = "Web Server"
    Owner = "Oleksandr"
  }
}

resource "local_file" "inventory" {
  content = <<EOF
[jenkins_master]
${aws_instance.jenkins_master.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/oleksandr-ostron/PrivatKeys/AdminE2C_key.pem

[jenkins_slave]
${aws_instance.jenkins_slave.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/oleksandr-ostron/PrivatKeys/AdminE2C_key.pem

[web_server]
${aws_instance.web_server.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/oleksandr-ostron/PrivatKeys/AdminE2C_key.pem
EOF

  filename = "${path.module}/../ansible/hosts.ini"
}

resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.jenkins_master, aws_instance.jenkins_slave, aws_instance.web_server]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "null_resource" "provision_jenkins_master" {
  depends_on = [null_resource.wait_for_ssh, local_file.inventory]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.inventory.filename} ${path.module}/../ansible/setup_apache_jenkins.yml --private-key /home/oleksandr-ostron/PrivatKeys/AdminE2C_key.pem"
  }
}

resource "null_resource" "provision_jenkins_slave" {
  depends_on = [null_resource.wait_for_ssh, local_file.inventory]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.inventory.filename} ${path.module}/../ansible/setup_jenkins_slave.yml --private-key /home/oleksandr-ostron/PrivatKeys/AdminE2C_key.pem"
  }
}

resource "null_resource" "provision_web_server" {
  depends_on = [null_resource.wait_for_ssh, local_file.inventory]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.inventory.filename} ${path.module}/../ansible/setup_wildfly.yml --private-key /home/oleksandr-ostron/PrivatKeys/AdminE2C_key.pem"
  }
}

output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_slave_ip" {
  value = aws_instance.jenkins_slave.public_ip
}

output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}
