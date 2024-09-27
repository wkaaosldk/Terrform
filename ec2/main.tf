# AWS 프로바이더 설정
provider "aws" {
  region = "us-west-2" # 리전 설정
}

# SSH 키페어 생성
resource "aws_key_pair" "dhk" {
  key_name   = "dhk"
  public_key = file("/home/wkaaosldk/.ssh/id_rsa.pub")  # 로컬 ssh 공개 키를 가져다 사용
}

#유저 데이터 생성
/*locals {
  user_data_script = <<-EOF
    #!/bin/bash
    # 업데이트 및 Apache 설치
    yum -y update
    yum install -y httpd

    # 기본 웹 페이지 생성
    echo "<html><h1>Hello, World This is my web server</h1></html>" > /var/www/html/index.html

    # Apache 서버 시작 및 부팅 시 자동 시작 설정
    systemctl start httpd
    systemctl enable httpd
    EOF
}
*/

# EC2 인스턴스 생성(public subnet)
resource "aws_instance" "public_instance" {
  ami           = "ami-077e1697513ccea8a"  # 사용할 AMI ID (지역에 맞는 AMI ID 사용)
  instance_type = "t2.micro"               # 인스턴스 타입
  subnet_id              = var.public_subnet_id_1  # 기존 서브넷 사용 
  key_name      = aws_key_pair.dhk.key_name
  associate_public_ip_address = true       # 퍼블릭 IP 할당

# 유저 데이터 설정
 # user_data              = local.user_data_script


  # 보안 그룹 설정
  vpc_security_group_ids = [var.security_group_id] # 보안 그룹 연결

  # 태그 설정
  tags = {
    Name = "MyEC2Instance"
  }
}

# EC2 인스턴스 생성(private subnet)
resource "aws_instance" "private_instance" {
  ami           = "ami-077e1697513ccea8a"  # 사용할 AMI ID (지역에 맞는 AMI ID 사용)
  instance_type = "t2.micro"               # 인스턴스 타입
  subnet_id              = var.private_subnet_id  # 기존 서브넷 사용 
  key_name      = aws_key_pair.dhk.key_name

  # 보안 그룹 설정
  vpc_security_group_ids = [var.security_group_id] # 보안 그룹 연결

  # 태그 설정
  tags = {
    Name = "MyEC2Instance"
  }
}

