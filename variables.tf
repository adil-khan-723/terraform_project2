variable "http" {
    description = "http port"
    type = number
    default = 80
}

variable "cidr_ipv4" {
    description = "cidr to allow inbound http from"
    type = string
    default = "0.0.0.0/0"
}

variable "instance_count" {
    description = "number of ec2 instances"
    default = 2
    type = number
}

variable "instance_type" {
    description = "Type of ec2 instance"
    default = "t2.micro"
    type = string
}

variable "key_name" {
    description = "Key pair name for EC2 instances"
    type = string
    default = "oggy-key"
}