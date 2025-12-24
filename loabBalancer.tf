# Load Balancer
resource "aws_lb" "loadBalancer" {
    name = "oggy-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = data.aws_subnets.default.ids

    tags = {
        Name = "oggy-alb"
    }
}
resource "aws_security_group" "alb_sg" {
    name = "alb-sg"
    description = "allow inbount http from internet"
    vpc_id = data.aws_vpc.default.id
}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
    security_group_id = aws_security_group.alb_sg.id
    from_port = var.http
    to_port = var.http
    ip_protocol = "tcp"
    cidr_ipv4 = var.cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
    security_group_id = aws_security_group.alb_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = var.cidr_ipv4
}

# Target Group
resource "aws_lb_target_group" "tg" {
    name = "oggy-alb-tg"
    protocol = "HTTP"
    port = var.http
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
    tags = {
        Name = "oggy-alb-tg"
    }
}

resource "aws_security_group" "alb-tg-sg" {
    name = "alb-tg-sg"
    description = "allow traffic from and to alb"
    vpc_id = data.aws_vpc.default.id   
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_alb" {
    security_group_id = aws_security_group.alb-tg-sg.id
    from_port = var.http
    to_port = var.http
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.alb_sg.id
}
resource "aws_vpc_security_group_egress_rule" "allow_to_alb" {
    security_group_id = aws_security_group.alb-tg-sg.id
    ip_protocol = "-1"
    cidr_ipv4 = var.cidr_ipv4
}


# Listener
resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.loadBalancer.arn
    port = var.http
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
    }
}

# Attach EC2 instances to Target Group

resource "aws_lb_target_group_attachment" "registered_targets" {
    count = var.instance_count
    target_group_arn = aws_lb_target_group.tg.arn
    target_id = aws_instance.instances[count.index].id
    port = var.http
}