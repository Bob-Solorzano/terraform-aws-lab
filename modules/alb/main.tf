# Load Balancer Target Group
resource "aws_lb_target_group" "this" {
  name     = "${var.environment}-${var.alb_name}-tg"
  port     = var.lb_port
  protocol = var.lb_protocol
  vpc_id   = var.vpc_id
}

# Load Balancer Resource
resource "aws_lb" "this" {
  name               = "${var.environment}-${var.alb_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "${var.environment}"
  }
}

#Load Balancer Listener
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}