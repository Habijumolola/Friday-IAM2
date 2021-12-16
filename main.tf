resource "aws_s3_bucket" "tyler-s3" {

    bucket = "tyler-s3"
    acl = "private"

    tags = {
        name= "mybucket"

    }
     server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "aws_kms_key" "kms-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}


resource "aws_iam_role_policy" "s3policy" {
  name = "iam-role"
  role = aws_iam_role.rd-wr.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "s3readandwrite",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
)
}

resource "aws_iam_role" "rd-wr" {
  name = "mys3role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "s3-instance" {
  name = "ec2_s3_instance_Profile"
  role = aws_iam_role.rd-wr.name

}

resource "aws_instance" "ec2-s3-instance" {
  ami                         = "ami-002068ed284fb165b"
  instance_type               = "t2.micro"
  key_name                    = "Shade-EC2-Key"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.s3-instance.id

  user_data = <<EOF
		#! /bin/bash
        sudo chown ec2-user /var/*
        aws s3 cp /var/log s3://anyitfbucket --recursive --exclude "*" --include "*.log"
	EOF
  
}
