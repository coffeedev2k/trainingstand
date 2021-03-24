
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "working" {}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

############## routed subnet ##################
resource "aws_subnet" "routed" {
  count             = length(var.cidr_block_routed)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.working.names[count.index]
  cidr_block        = element(var.cidr_block_routed, count.index)
  tags = {
    Name = "${var.env}-routed-${count.index + 1}"
  }
}

resource "aws_route_table" "rt_routed" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.env}-route-rt_routed-subnets"
  }
}

resource "aws_route_table_association" "routed" {
  count          = length(aws_subnet.routed[*].id)
  route_table_id = aws_route_table.rt_routed.id
  subnet_id      = element(aws_subnet.routed[*].id, count.index)
}

############### natted subnet ######################################


resource "aws_subnet" "natted" {
  count             = length(var.cidr_block_natted)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.working.names[count.index]
  cidr_block        = element(var.cidr_block_natted, count.index)
  tags = {
    Name = "${var.env}-natted-${count.index + 1}"
  }
}


resource "aws_route_table" "rt_natted" {
  count  = length(aws_nat_gateway.gw[*].id)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw[*].id, count.index)
  }
  tags = {
    Name = "${var.env}-route-rt_natted-subnets"
  }
}

resource "aws_route_table_association" "natted" {
  count          = length(var.cidr_block_natted[*])
  route_table_id = element(aws_route_table.rt_natted[*].id, count.index)
  subnet_id      = element(aws_subnet.natted[*].id, count.index)
}
################ stuff subnet ##################

resource "aws_subnet" "stuff" {
  count             = length(var.cidr_block_stuff)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.working.names[count.index]
  cidr_block        = element(var.cidr_block_stuff, count.index)
  tags = {
    Name = "${var.env}-stuff-${count.index + 1}"
  }
}

resource "aws_route_table" "rt_stuff" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-route-stuff-subnets"
  }
}

resource "aws_route_table_association" "stuff" {
  count          = length(aws_subnet.stuff[*].id)
  route_table_id = aws_route_table.rt_stuff.id
  subnet_id      = element(aws_subnet.stuff[*].id, count.index)
}
#################### stuff-routed #####################
resource "aws_subnet" "stuff-routed" {
  count             = length(var.cidr_block_stuff-routed)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.working.names[count.index]
  cidr_block        = element(var.cidr_block_stuff-routed, count.index)
  tags = {
    Name = "${var.env}-stuff_routed-${count.index + 1}"
  }
}

resource "aws_route_table" "rt_stuff-routed" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.env}-route-stuff-routed-subnets"
  }
}

resource "aws_route_table_association" "stuff-routed" {
  count          = length(aws_subnet.stuff-routed[*].id)
  route_table_id = aws_route_table.rt_stuff-routed.id
  subnet_id      = element(aws_subnet.stuff-routed[*].id, count.index)
}

resource "aws_nat_gateway" "gw" {
  count         = length(aws_subnet.stuff-routed[*].id)
  allocation_id = element(aws_eip.eip_subnet_routed-stuff[*].id, count.index)
  subnet_id     = element(aws_subnet.stuff-routed[*].id, count.index)
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}
resource "aws_eip" "eip_subnet_routed-stuff" {
  count = length(aws_subnet.stuff-routed[*].id)
  vpc   = true
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}
########## LC + ASG ################################################################################################################################################################
########## LC + ASG WEBCLUSTER #####################################################################################################################################################
resource "aws_launch_configuration" "web_cluster" {
  name_prefix     = "${var.env}-web_cluster-LC-"
  image_id        = var.web_cluster_ami_id
  instance_type   = var.web_cluster_instance
  security_groups = [aws_security_group.web.id]
  user_data       = file("user_data.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul.id
  key_name = var.key_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  count                = length(aws_subnet.natted[*].id)
  name_prefix          = "${var.env}-ASG-${aws_launch_configuration.web_cluster.name}"
  launch_configuration = aws_launch_configuration.web_cluster.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [element(aws_subnet.natted[*].id, count.index)]
  //  load_balancers       = [element(aws_elb.web[*].name, count.index)]
  tags = [
    {
      key = "Name"
      value               = "${var.env}-web-instances"
      propagate_at_launch = true
    },
    {
      key = "target"
      value               = "data_plane"
      propagate_at_launch = true
    },
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "eip_nlb" {
  tags = {
    Name = "${var.env}-Nlb-eip"
  }
}

resource "aws_lb" "web" {
  name = "${var.env}-NLB"
  //  name_prefix        = "${var.env}-NLB-web"
  load_balancer_type = "network"
  subnets            = aws_subnet.routed[*].id
  //  enable_deletion_protection = true

  tags = {
    Name = "${var.env}-NLB"
  }
}

resource "aws_lb_target_group" "tg_web" {
  name_prefix = "tg"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    //  timeout             = 3
    //    target              = "HTTP:80/"
    interval = 10
  }
}


resource "aws_lb_target_group_attachment" "web" {
  count            = length(aws_instance.reverse_proxy[*].private_ip)
  target_group_arn = aws_lb_target_group.tg_web.arn
  target_id        = element(aws_instance.reverse_proxy[*].private_ip, count.index)
  port             = 80
}


resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_web.arn
  }
}

######################################### port 8080 ###################################################

resource "aws_lb_target_group" "tg_web8080" {
  name_prefix = "tg"
  port        = 8080
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
//  health_check {
//    healthy_threshold   = 2
//    unhealthy_threshold = 2
//    interval = 10
//    matcher = "200-499"
//  }
}


resource "aws_lb_target_group_attachment" "web8080" {
  count            = length(aws_instance.reverse_proxy[*].private_ip)
  target_group_arn = aws_lb_target_group.tg_web8080.arn
  target_id        = element(aws_instance.reverse_proxy[*].private_ip, count.index)
  port             = 8080
}


resource "aws_lb_listener" "web8080" {
  load_balancer_arn = aws_lb.web.arn
  port              = "8080"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_web8080.arn
  }
}
######################################### port 8081 ###################################################

resource "aws_lb_target_group" "tg_web8081" {
  name_prefix = "tg"
  port        = 8081
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "web8081" {
  count            = length(aws_instance.reverse_proxy[*].private_ip)
  target_group_arn = aws_lb_target_group.tg_web8081.arn
  target_id        = element(aws_instance.reverse_proxy[*].private_ip, count.index)
  port             = 8081
}


resource "aws_lb_listener" "web8081" {
  load_balancer_arn = aws_lb.web.arn
  port              = "8081"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_web8081.arn
  }
}

######################################### port 8082 ###################################################

resource "aws_lb_target_group" "tg_web8082" {
  name_prefix = "tg"
  port        = 8082
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}


resource "aws_lb_target_group_attachment" "web8082" {
  count            = length(aws_instance.reverse_proxy[*].private_ip)
  target_group_arn = aws_lb_target_group.tg_web8082.arn
  target_id        = element(aws_instance.reverse_proxy[*].private_ip, count.index)
  port             = 8082
}


resource "aws_lb_listener" "web8082" {
  load_balancer_arn = aws_lb.web.arn
  port              = "8082"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_web8082.arn
  }
}


########## LC + ASG MANAGECLUSTER #################################################################################################################################################
resource "aws_launch_configuration" "manage_cluster" {
  name_prefix     = "${var.env}-manage_cluster-LC-"
  image_id        = var.manage_cluster_ami_id
  instance_type   = var.manage_cluster_instance
  security_groups = [aws_security_group.web.id]
  user_data       = file("user_data.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul.id
  key_name = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_group" "manage_cluster" {
  name_prefix          = "${var.env}-ASG-${aws_launch_configuration.manage_cluster.name}"
  launch_configuration = aws_launch_configuration.manage_cluster.name
  min_size             = 3
  max_size             = 3
  health_check_type    = "EC2"
  vpc_zone_identifier  = aws_subnet.natted[*].id
  tags = [
    {
      key = "Name"
      value               = "${var.env}-manage-cluster-instances"
      propagate_at_launch = true
    },
    {
      key = "target"
      value               = "control_plane"
      propagate_at_launch = true
    },
  ]
  lifecycle {
    create_before_destroy = true
  }
}

########## LC + ASG DATACLUSTER #####################################
resource "aws_launch_configuration" "datacluster" {
  name_prefix     = "${var.env}-datacluster-LC-"
  image_id        = var.datacluster_ami_id
  instance_type   = var.datacluster_instance
  security_groups = [aws_security_group.web.id]
  user_data       = file("user_data.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul.id

  key_name = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_group" "datacluster" {
  count                = length(aws_subnet.stuff[*].id, )
  name_prefix          = "${var.env}-ASG-${aws_launch_configuration.datacluster.name}"
  launch_configuration = aws_launch_configuration.datacluster.name
  min_size             = 2
  max_size             = 2
  health_check_type    = "EC2"
  vpc_zone_identifier  = [element(aws_subnet.stuff[*].id, count.index)]

  tags = [
    {
      key = "Name"
      //    value               = "Instances-${aws_autoscaling_group.datacluster.name}"
      value               = "${var.env}-datacluster-instances"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}
