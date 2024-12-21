//creating Ansible security_group
resource "aws_security_group" "ansible-sg" {
  name        = "ansible-sg allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  

  ingress {
    description = "ssh from vpc"
    from_port   = var.sshport
    to_port     = var.sshport
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }
  tags = {
    Name = "ansible-sg"
  }
}

resource "aws_security_group" "m-node-sg" {
  name        = "m-node-sg allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  

  ingress {
    description = "ssh "
    from_port   = var.sshport
    to_port     = var.sshport
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

ingress {
    description = "http"
    from_port   = var.httpport
    to_port     = var.httpport
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }
  tags = {
    Name = "ansible-sg"
  }
}

#creating RSA private-key 
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

//creating private key Locally
resource "local_file" "key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "set23-key"
  file_permission = "600"
}

//creating and register the public key in AWS
resource "aws_key_pair" "key" {
  key_name   = "set23-pub-key"
  public_key = tls_private_key.key.public_key_openssh
}

//creating ansible instance

resource "aws_instance" "ansible" {
  ami                         = var.ubuntu //ansible ubuntu ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.ansible-sg.id]
  associate_public_ip_address = true
  user_data                   = file("./userdata.sh")
  tags = {
    Name = "ansible"
  }
}


resource "aws_instance" "ubuntu" {
  ami                         = var.ubuntu //ansible ubuntu ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.m-node-sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "ubuntu"
  }
}

resource "aws_instance" "redhat" {
  ami                         = var.redhat // redhat ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.m-node-sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "redhat"
  }
}