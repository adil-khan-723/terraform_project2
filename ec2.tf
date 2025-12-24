resource "aws_instance" "instances" {
  ami                    = data.aws_ami.ami.id
  count                  = var.instance_count
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[count.index]
  vpc_security_group_ids = [aws_security_group.alb-tg-sg.id]
  key_name = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install nginx -y

    echo "<h1>Hello from Instance ${count.index + 1}</h1>" > /var/www/html/index.html

    systemctl enable nginx
    systemctl restart nginx
  EOF

    tags = {
        Name = "oggy-instance-${count.index + 1}"
    }

    lifecycle {
      create_before_destroy = true
    }
}
