variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  default     = "ami-077e1697513ccea8a" # 이 AMI는 예시이며, 실제 필요한 AMI로 변경하세요.
}

variable "desired_capacity" {
  description = "Desired number of instances"
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  default     = 3
}

variable "min_size" {
  description = "Minimum number of instances"
  default     = 1
}

variable "vpc_id" {
  type = string # VPC ID를 문자열 타입으로 입력 받음
}

variable "security_group_id" {
  type = string # VPC ID를 문자열 타입으로 입력 받음
}

variable "public_subnet_id_1" {
  type = string # VPC ID를 문자열 타입으로 입력 받음
}

variable "public_subnet_id_2" {
  type = string # VPC ID를 문자열 타입으로 입력 받음
}

variable "private_subnet_id" {
  type = string # VPC ID를 문자열 타입으로 입력 받음
}

variable "alb_target_group_arn" {
  type = string # VPC ID를 문자열 타입으로 입력 받음
}
