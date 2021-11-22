# create ec2 public 
resource "aws_instance" "Bastion-server" {
  ami               = "ami-083654bd07b5da81d"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  associate_public_ip_address = true
  key_name          = "newKeypair"
  subnet_id       = aws_subnet.public-subnet-1.id
  security_groups = [aws_security_group.Bastion_host_SG.id]
  tags = {
    Name = "Bastion-server"
  }
}

output "Bastion_ip_addr" {
  value = aws_instance.Bastion-server.public_ip
}

# create ec2 private for Jenkins
resource "aws_instance" "Jenkins-private" {
  ami               = "ami-083654bd07b5da81d"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  associate_public_ip_address = false
  key_name          = "newKeypair"
  subnet_id       = aws_subnet.private-subnet-1.id
  security_groups = [aws_security_group.private_sg.id]

  tags = {
    Name = "Jenkins-private"
  }
}
output "Jenkins_instance_ip" {
  value = aws_instance.Jenkins-private.private_ip
}
# create ec2 private for App
resource "aws_instance" "App-private" {
  ami               = "ami-083654bd07b5da81d"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  associate_public_ip_address = false
  key_name          = "newKeypair"
  subnet_id       = aws_subnet.private-subnet-1.id
  security_groups = [aws_security_group.private_sg.id]

  tags = {
    Name = "App-private"
  }
}
output "App_instance_ip" {
  value = aws_instance.App-private.private_ip
}