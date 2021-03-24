
resource "aws_security_group" "web" {
  name        = "WebServer Security Group"
  description = "SecurityGroup for webservers 22, 80 and 443 open"
  vpc_id      = aws_vpc.main.id


  dynamic "ingress" {
    for_each = ["22", "80", "443", "2049", "4646", "4647", "4648", "5432", "8080", "8081", "8082", "8111","8200", "8300", "8400", "8301", "8302", "8500", "8501", "8600"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  dynamic "ingress" {
    for_each = ["22", "80", "443", "8200", "8300", "8400", "8301", "8302", "8500", "8501", "8600", "4646", "4647", "4648"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test"
  }
}
