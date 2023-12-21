resource "aws_iam_role" "iam_instance_role" {
    name =  "iam_instance_role"
    assume_role_policy = jsonencode ({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "sts:AssumeRole"
            ],
            Principal: {
                Service: [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
    })
}

resource "aws_iam_policy" "s3_read_list_policy" {
  name        = "s3_read_list_policy"
  description = "Policy to allow read and list access to a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::rest-app-bucket-01",
          "arn:aws:s3:::rest-app-bucket-01/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ssm_parameter_store_access_policy" {
  name        = "ssm_parameter_store_access_policy"
  description = "Policy to allow access to SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory",
          "ssm:DescribeParameters",
        ],
        Effect = "Allow",
        Resource = [
          "*",
        ]
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "s3_read_list_attach" {
  role = aws_iam_role.iam_instance_role.name
  policy_arn = aws_iam_policy.s3_read_list_policy.arn
}

resource "aws_iam_role_policy_attachment" "dynamodb_role_attach" {
    role = aws_iam_role.iam_instance_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


resource "aws_iam_role_policy_attachment" "parameterstore_access_attach" {
  role = aws_iam_role.iam_instance_role.name
  policy_arn = aws_iam_policy.ssm_parameter_store_access_policy.arn
}

resource "aws_iam_instance_profile" "IAMinstanceprofile" {
    name = "IAMinstanceprofile"
    role =  aws_iam_role.iam_instance_role.name  
}







