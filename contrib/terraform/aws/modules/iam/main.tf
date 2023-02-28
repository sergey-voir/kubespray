#Add AWS Roles for Kubernetes

resource "aws_iam_role" "kube_control_plane" {
  name = "kubernetes-${var.aws_cluster_name}-master"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
      }
  ]
}
EOF
}

resource "aws_iam_role" "kube-worker" {
  name = "kubernetes-${var.aws_cluster_name}-node"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
      }
  ]
}
EOF
}

#Add AWS Policies for Kubernetes

resource "aws_iam_role_policy" "kube_control_plane" {
  name = "kubernetes-${var.aws_cluster_name}-master"
  role = aws_iam_role.kube_control_plane.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["route53:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::kubernetes-*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kube-worker" {
  name = "kubernetes-${var.aws_cluster_name}-node"
  role = aws_iam_role.kube-worker.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:*",
          "Resource": [
            "arn:aws:s3:::kubernetes-*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": "iam:CreateServiceLinkedRole",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "elasticloadbalancing:*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:GetCoipPoolUsage",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:CreateSecurityGroup",
            "ec2:DeleteSecurityGroup",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:Describe*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:AttachVolume",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ec2:DetachVolume",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": ["route53:*"],
          "Resource": ["*"]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:DescribeImageScanFindings",
            "ecr:DescribeImages",
            "ecr:DescribeRepositories",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetLifecyclePolicy",
            "ecr:GetLifecyclePolicyPreview",
            "ecr:GetRepositoryPolicy",
            "ecr:InitiateLayerUpload",
            "ecr:ListImages",
            "ecr:ListTagsForResource",
            "ecr:PutImage",
            "ecr:UploadLayerPart",
            "ecr:GetAuthorizationToken"
          ],
          "Resource": "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue",
            "secretsmanager:UpdateSecret"
          ],
          "Resource" : [
            "arn:aws:secretsmanager:us-east-1:*:secret:pypi-*"
          ]
        },
        {
          "Action" : [
            "s3:GetObject",
            "s3:PutObject",
            "s3:GetObjectAcl",
            "s3:PutObjectAcl",
            "s3:ListBucket",
            "s3:GetBucketAcl",
            "s3:PutBucketAcl",
            "s3:GetBucketLocation",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion"
          ],
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:s3:::wanna-pypi",
            "arn:aws:s3:::wanna-pypi/*"
          ]
        }
      ]
}
EOF
}

#Create AWS Instance Profiles

resource "aws_iam_instance_profile" "kube_control_plane" {
  name = "kube_${var.aws_cluster_name}_master_profile"
  role = aws_iam_role.kube_control_plane.name
}

resource "aws_iam_instance_profile" "kube-worker" {
  name = "kube_${var.aws_cluster_name}_node_profile"
  role = aws_iam_role.kube-worker.name
}
