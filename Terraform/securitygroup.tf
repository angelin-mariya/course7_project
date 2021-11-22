# Allow self ip to ssh to ‘bastion’ instance and allow all egress.
resource "aws_security_group" "Bastion_host_SG" {
    name        = "Bastion_host_SG"
    description = "Allow Web inbound traffic"
    vpc_id      = aws_vpc.prod-vpc.id
    
    ingress {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      #cidr_blocks = ["0.0.0.0/0"]
      cidr_blocks = [format("%s/%s",data.external.whatismyip.result["internet_ip"],32)]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "Bastion_host_SG"
    }
}

#Allow all incoming traffic from within VPC(bastion Host SG) and all egress.
resource "aws_security_group" "private_sg" {
  name = "Private_sg"
  description = "Security Group for Private instance"
  vpc_id      = aws_vpc.prod-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = [aws_vpc.prod-vpc.cidr_block]
    security_groups = ["${aws_security_group.Bastion_host_SG.id}"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"

    security_groups = ["${aws_security_group.Public_Web_SG.id}"]
  }
  
  
}
#Allow incoming to port 80 from self IP and all egress.
resource "aws_security_group" "Public_Web_SG" {
  name = "Public_Web_SG"
  description = "Security Group for Private instance"
  vpc_id      = aws_vpc.prod-vpc.id
  
    ingress {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [format("%s/%s",data.external.whatismyip.result["internet_ip"],32)]

    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

