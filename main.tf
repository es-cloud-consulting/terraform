terraform {
  required_providers {
    aws = {
      source     = "hashicorp/aws"
      version    = "~> 3.27"
      access_key = "${var.AWS_ACCESS_KEY_ID}"
      secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
    }
  }

  required_version = ">= 1.0.4"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "app_server" {
  count                  = 2
  ami                    = "ami-047e03b8591f2d48a"
  instance_type          = "t2.micro"
  key_name               = "ec2-deployer-key-pair"
  vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
  tags = {
    Name = "First-Ec2-With-Terraform"
  }
  connection {
    type    = "ssh"
    host    = self.public_ip
    user    = "welsayedaly"
    timeout = "4m"
  }

}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-deployer-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPF+7PtG0oBFdYp2UFg1axGi9c/pzL57NJYdfJukcMfW5Nfv7Y1CzMk4MiNCL9VP04yt9VRz/2nzhYW2fRMlr4mkwYL8LJqTI0b5k42X/cO9q1CsBTC2z+tHriY1UtvsajCN51pXbe+AKgN5OYf84ixeCfs4lPNqs+nswn63uLrtGRbvxD7xoDuZcIhT8KRctMMeAKQbemCD97eC5pMkvuvslRFdmC2DXETvP46vd5Mo5edUB+8PqdTtM5vHpENPRYElueO6l1kZHO8HvBv4/veH+VlQkWW99PFjJjLWDbhpECb1S50+CFzH0GF+jkN91o4S6kch17ZJlPB1AGYcoL walidelsayedaly@me-2.local"
}