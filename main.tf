terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Name        = "dhk"
      environments = "dhk-test"
    }
  }

# 특정 키값의 tag의 변경 사항을 무시한다. 
  ignore_tags {
    key_prefixes = ["temporary", "example",]
    keys         = ["CostCenter", "Project"]
  }
}

module "vpc" {
  source = "./vpc"
}

module "igw" {
  source = "./igw"
  vpc_id = module.vpc.vpc_id
}

module "route" {
  source = "./route"
  vpc_id = module.vpc.vpc_id
  igw_id = module.igw.igw_id
}

module "subnet" {
  source = "./subnet"
  vpc_id = module.vpc.vpc_id
  public_route_id = module.route.public_route_id
}

module "security_group" {
  source = "./sg"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./ec2"
  vpc_id = module.vpc.vpc_id
  security_group_id = module.security_group.security_group_id
  public_subnet_id_1 = module.subnet.public_subnet_id_1
  public_subnet_id_2 = module.subnet.public_subnet_id_2
  private_subnet_id = module.subnet.private_subnet_id
  #depends_on = [ module.security_group] # 명시적으로 종속성 구성
}

module "asg"{
  source = "./asg"
  vpc_id = module.vpc.vpc_id
  security_group_id = module.security_group.security_group_id
  public_subnet_id_1 = module.subnet.public_subnet_id_1
  public_subnet_id_2 = module.subnet.public_subnet_id_2
  private_subnet_id = module.subnet.private_subnet_id
  alb_target_group_arn = module.ELB.alb_target_group_arn
  key_name = module.ec2.key_name
}

module "ELB"{
  source = "./ELB"
  vpc_id = module.vpc.vpc_id
  public_subnet_id_1 = module.subnet.public_subnet_id_1
  public_subnet_id_2 = module.subnet.public_subnet_id_2
  security_group_id = module.security_group.security_group_id

}


