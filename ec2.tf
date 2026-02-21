# key pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "terra-key-ansible"
  public_key = file("terra-key-ansible.pub")
}


# vpc & security groups

resource "aws_default_vpc" "default" {
  # can leave empty
}

resource "aws_security_group" "my_sg" {
  name        = "automate-sg"
  description = "terraform generated sg"
  vpc_id      = aws_default_vpc.default.id #interpolation 

  # inbound rules / ingress
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh open"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "https"
  }
  tags = {
    Name = "automate-sg"
  }


  # outbound rules / egress

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
# ec2 instance

resource "aws_instance" "terra-ec2" {
  #count = 2
  for_each = tomap({
    "ni3-master" = "ami-019715e0d74f695be" #ubuntu
    "ni3-1"  = "ami-019715e0d74f695be",#ubuntu
    "ni3-2"  = "ami-0ffef61f6dc37ae89",#redhat
    "ni3-3"  = "ami-0ffef61f6dc37ae89" #redhat
    
  }) # meta argument
  depends_on      = [aws_security_group.my_sg]
  key_name        = aws_key_pair.ec2_key.key_name
  security_groups = [aws_security_group.my_sg.name]
  instance_type   = "t2.micro"
  ami             = each.value
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  tags = {
    Name = each.key
    Environment = var.env
  }
}   
