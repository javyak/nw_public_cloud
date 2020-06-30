# Application Load Balancer

resource "aws_lb" "iot-web-alb" {
  name               = "iot-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb.id]
  subnets            = [aws_subnet.public1.id,aws_subnet.public2.id]
}


resource "aws_lb_target_group" "iot-http-tg" {
  name     = "iot-http-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.iot_service.id
}

resource "aws_lb_target_group" "iot-ssl-tg" {
  name     = "iot-ssl-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.iot_service.id
}

resource "aws_lb_target_group_attachment" "iot-http-att1" {
  target_group_arn = aws_lb_target_group.iot-http-tg.arn
  target_id        = aws_instance.web_server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "iot-ssl-att1" {
  target_group_arn = aws_lb_target_group.iot-ssl-tg.arn
  target_id        = aws_instance.web_server1.id
  port             = 443
}

resource "aws_lb_target_group_attachment" "iot-http-att2" {
  target_group_arn = aws_lb_target_group.iot-http-tg.arn
  target_id        = aws_instance.web_server2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "iot-ssl-att2" {
  target_group_arn = aws_lb_target_group.iot-ssl-tg.arn
  target_id        = aws_instance.web_server2.id
  port             = 443
}

resource "aws_lb_listener" "iot-web-listener-80" {
  load_balancer_arn = aws_lb.iot-web-alb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.iot-http-tg.arn
  }
}

resource "aws_lb_listener" "iot-web-listener-443" {
  load_balancer_arn = aws_lb.iot-web-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_certificate_arn
# Certificated alreeady created and uploaded to AWS ACM
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.iot-ssl-tg.arn
  }
}