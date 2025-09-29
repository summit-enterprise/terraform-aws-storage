# ========================================
# IAM ROLES AND POLICIES
# ========================================

# ========================================
# GLUE SERVICE ROLE
# ========================================

resource "aws_iam_role" "glue_service_role" {
  name = "${var.environment}-glue-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.environment}-glue-service-role"
    Purpose     = "Glue Service Role"
    Service     = "Glue"
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_role_policy" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "${var.environment}-glue-s3-access"
  role = aws_iam_role.glue_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.data_lake.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.data_lake.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.glue_scripts.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.glue_scripts.bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ========================================
# GLUE SCRIPT BUCKET CONFIGURATION
# ========================================

# Note: The glue_scripts bucket is defined in s3.tf
# This file only contains IAM roles and policies
