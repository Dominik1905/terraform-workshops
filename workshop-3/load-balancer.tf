# Der Load Balancer bekommt eine eigene Security Group in unserer VPC.
resource "aws_security_group" "alb" {
  name_prefix = "tf-w3-alb-"
  description = "Public HTTP access to the load balancer"
  vpc_id      = aws_vpc.main.id
}

# Browser aus dem Internet dürfen den Load Balancer über HTTP aufrufen.
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Der Load Balancer erreicht die Webserver für Anfragen und Health Checks.
resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Der öffentliche ALB ist über beide Subnetze erreichbar.
resource "aws_lb" "web" {
  name               = "tf-w3-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  # Die Internetroute muss für beide Subnetze gelten.
  depends_on = [aws_route.internet, aws_route_table_association.public]
}

# Die Zielgruppe verwendet HTTP auf Port 80 und prüft die Startseite.
resource "aws_lb_target_group" "web" {
  name        = "tf-w3-web"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Beide EC2-Instanzen werden als Ziele eingetragen.
resource "aws_lb_target_group_attachment" "web" {
  count            = 2
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# Der Listener nimmt Browseranfragen an und leitet sie an die Zielgruppe weiter.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
