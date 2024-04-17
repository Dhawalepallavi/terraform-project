terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# create aws ec2 instance_1
resource "aws_instance" "card_website_01" {
  ami           = "ami-066016d0d26e8ae60"
  instance_type = "t2.micro"
  key_name = aws_key_pair.demo_key_pair_1.id
  subnet_id = aws_subnet.public_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data = filebase64("userdata.sh")

  tags = {
    Name = "card_website_01"
    owner= "Pallavi Shete"
  }
}

# create aws ec2 instance_2
resource "aws_instance" "card_website_02" {
  ami           = "ami-066016d0d26e8ae60"
  instance_type = "t2.micro"
  key_name = aws_key_pair.demo_key_pair_1.id
  subnet_id = aws_subnet.public_subnet_1c.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data = filebase64("userdata.sh")

  tags = {
    Name = "card_website_02"
    owner= "Pallavi Shete"
  }
}


# create aws key pair
resource "aws_key_pair" "demo_key_pair_1" {
  key_name   = "demo_key_pair_1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiG1IQDstFUaBX8uqtUiClwAj4eguyVgHtEp5V+qlz3SNlPitCz4UMDtaTKHf3Bqk9yAGNWUhXXTJSryNHO55EDVZh/cCGpidZeR1hQR8kCYWNYYNGR46I1LHGpj7rZKb203XZ6CkiBTRxXBXZ1vzbwCn+KatoGC2t6KCqgLXRXQnLT1CplodxCiCIVOUDdv2hHrFPgUO6H0k9LqhRoVSSDkiR37FRW6NwpO4s8Uf2trWfzQXMzuuIlsCsJUnWWVN/T+X9K1DJ/7dlcAzs44Xja6ZM1fvjMqxrhINBFv4MS8Fm43dLzOc5AGBIY1ezjLqShaAK0nwnJuCu2OxZcaMjzrCc6r+bLhcjaVMkZH150Grge1v9lcvmYh9COxpXSHPYOJcISaTkFnfQoeaGwz0bren1e4OETcaEtU6IilPUZYUUPbvSbboZrVpZORGIdt61mKsjvbzsuM1IQ2AD03KP2o/ouGyplUWG6GXmnSaDMyvjAEPiemY4G011fTh+/B8= hp@DESKTOP-BCJC7SG"
  }

# create aws vpc
resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform_vpc"
  }
}



# create aws subnets in availability 1a
resource "aws_subnet" "public_subnet_1a" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet_1a"
  }
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "private_subnet_1b"
  }
}

# create aws subnets in availability 1b
resource "aws_subnet" "public_subnet_1c" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public_subnet_1c"
  }
}

resource "aws_subnet" "private_subnet_1d" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private_subnet_1d"
  }
}

#  create security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "allow ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  tags = {
    Name = "allow_traffic_for_card_instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# create internet gateway
resource "aws_internet_gateway" "demo_IGW" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "demo_IGW"
  }
}

# create public route table
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_IGW.id
  }
  tags = {
    Name = "public_RT"
  }
}

# provide public Route table association
resource "aws_route_table_association" "RT_association_1" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_RT.id
}

# provide public Route table association
resource "aws_route_table_association" "RT_association_2" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public_RT.id
}

# create private route table
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "private_RT"
  }
}

# provite private Route table association
resource "aws_route_table_association" "RT_association_3" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.private_RT.id
}

resource "aws_route_table_association" "RT_association_4" {
  subnet_id      = aws_subnet.private_subnet_1d.id
  route_table_id = aws_route_table.private_RT.id
}

# create target group
resource "aws_lb_target_group" "demo_TG" {
  name     = "targetgroup1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terraform_vpc.id
}

# attchement of instances to target
resource "aws_lb_target_group_attachment" "apache_target_group_attach_1" {
  target_group_arn = aws_lb_target_group.demo_TG.arn
  target_id        = aws_instance.card_website_01.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "apache_target_group_attach_2" {
  target_group_arn = aws_lb_target_group.demo_TG.arn
  target_id        = aws_instance.card_website_02.id
  port             = 80
}

# create lisener
resource "aws_lb_listener" "lb_lisener" {
  load_balancer_arn = aws_lb.apache_LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo_TG.arn
  }
}

# create application load balancer
resource "aws_lb" "apache_LB" {
  name               = "apache-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh.id]
  subnets            = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]

  tags = {
    Environment = "production"
  }
}

# create launched template
resource "aws_launch_template" "demo_LT" {
  name = "demo-launched-template"
  image_id = "ami-066016d0d26e8ae60"
  instance_type = "t2.micro"
  key_name = aws_key_pair.demo_key_pair_1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  network_interfaces {
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "demo_card_instance_by_LT"
    }
  }
  user_data = filebase64("userdata.sh")
}
