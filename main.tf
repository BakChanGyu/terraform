terraform {
  // 이 부분은 terraform cloud에서 설정한 workspace의 이름과 동일해야 함
  // 이 부분은 terraform login 후에 사용가능함
  cloud {
    organization = "og1"

    workspaces {
      name = "ws-1"
    }
  }

  // 자바의 import 와 비슷함
  // aws 라이브러리 불러옴
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
# 이녀석이 HCL이라는 언어에서 객체를 정의하는 방법이다.
provider "aws" {
  region = var.region
}

# 객체타입, 객체종류같은느낌.
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.prefix}-vpc-1"
  }
}

# vpc와 서브넷은 1:다 관계
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "igw_1" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "${var.prefix}-igw-1"
  }
}

# 목적지가 어디던 보낸다.
# 모든 서브넷은 라우팅 테이블이 연결되어있어야 함.
resource "aws_route_table" "rt_1" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0" # 이 녀석이 추상적일수록 우선순위가 낮다.
    gateway_id = aws_internet_gateway.igw_1.id
  }

  tags = {
    Name = "${var.prefix}-rt-1"
  }
}

resource "aws_route_table_association" "association_1" {
  subnet_id = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.rt_1.id
}

resource "aws_security_group" "sg_1" {
  ingress {
    from_port = 0
    protocol  = "all"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "all"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-s-1"
  }
}