data "aws_ami" "amazon-linux2" {
  owners = [ "amazon" ]
  most_recent = true
  filter {
    name = "name"
    values = [ "amzn2-ami-kernel-*" ]
  }
}

resource "aws_instance" "main_instance" {
  ami           = data.aws_ami.amazon-linux2.id
  instance_type = var.instancetype
  vpc_security_group_ids = [aws_security_group.MainEC2SG.id]
  iam_instance_profile = aws_iam_instance_profile.IAMinstanceprofile.id
  subnet_id = aws_subnet.PrivateSubnet.id
  user_data = filebase64("../ec2init.sh")
  depends_on = [aws_s3_object.rest-app, aws_s3_object.rest-app-req, aws_s3_object.rest-app-data, aws_s3_object.rest-app-load]
  tags = {
    Name = "restapp"
  }
}

resource "aws_lb" "mainALB" {
  name               = "mainALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.MainPublicSG.id]
  internal           = false
  ip_address_type    = "ipv4"
  subnets            = [aws_subnet.PublicSubnet1.id, aws_subnet.PublicSubnet2.id]
}

resource "aws_lb_listener" "front" {
  load_balancer_arn = aws_lb.mainALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mainALBTargetGroup.arn
  }
}

resource "aws_lb_target_group" "mainALBTargetGroup" {
  name             = "mainalbtargetgroup"
  port             = 80
  protocol         = "HTTP"
  vpc_id           = aws_vpc.Mainvpc.id
  target_type      = "instance"
  health_check {
    matcher             = "200"
    path                = "/health"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 120
  }
}

resource "aws_lb_target_group_attachment" "main_instance_attachment" {
  target_group_arn = aws_lb_target_group.mainALBTargetGroup.arn
  target_id        = aws_instance.main_instance.id
  port             = 80
}
