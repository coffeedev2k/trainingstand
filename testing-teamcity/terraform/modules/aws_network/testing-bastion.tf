#testing part
data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "my_webserver" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.routed[0].id
  user_data              = file("user_data.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul.id
  key_name = var.key_name

  tags = {
    Name = "${var.env}-my_webserver"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "eip_subnet_routed" {
  instance = aws_instance.my_webserver.id
  vpc      = true
}



resource "aws_instance" "reverse_proxy" {
  count                  = length(aws_subnet.natted[*].id)
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = element(aws_subnet.natted[*].id, count.index)
  user_data              = file("user_data.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul.id
  key_name = var.key_name

  tags = {
    Name = "${var.env}-reverse_proxy"
  }

  lifecycle {
    create_before_destroy = true
  }
}
