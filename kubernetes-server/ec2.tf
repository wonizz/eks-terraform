resource "aws_security_group" "kubernetes-server-instance-sg" {
  name        = "kubernetes-server-instance-sg"
  description = "kubectl_instance_sg"
  vpc_id      = "vpc-c8d80ba1"

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "kubectl_server-SG"
  }
}

resource "aws_instance" "kubernetes-server" {
  instance_type          = "t2.micro"
  ami                    = "ami-091e0e1906e653417"
  key_name               = "KP_DEV_AP_AUTH"
  subnet_id              = "subnet-045fb8733552fbee1"
  vpc_security_group_ids = ["${aws_security_group.kubernetes-server-instance-sg.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }

  tags = {
    Name = "eks-cli"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.kubernetes-server.id}"
  vpc      = true

  tags = {
    Name = "server_eip"
  }
}
