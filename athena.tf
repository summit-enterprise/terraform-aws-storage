# ========================================
# ATHENA DATA WAREHOUSE
# ========================================

# ========================================
# ATHENA WORKGROUP
# ========================================

resource "aws_athena_workgroup" "main" {
  name = "${var.environment}-data-warehouse"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.athena_results_bucket}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    engine_version {
      selected_engine_version = var.athena_engine_version
    }
  }

  tags = merge(var.tags, {
    Name        = "${var.environment}-data-warehouse"
    Purpose     = "Data Warehouse Querying"
    Service     = "Athena"
  })
}

# ========================================
# ATHENA DATABASE
# ========================================

resource "aws_athena_database" "main" {
  name   = "${var.environment}_data_warehouse"
  bucket = var.athena_results_bucket

  encryption_configuration {
    encryption_option = "SSE_S3"
  }
}

# ========================================
# ATHENA DATA CATALOG
# ========================================

resource "aws_glue_catalog_database" "athena_catalog" {
  name = "${var.environment}_athena_catalog"

  description = "Data catalog for Athena queries in ${var.environment}"

  tags = merge(var.tags, {
    Name        = "${var.environment}-athena-catalog"
    Purpose     = "Athena Data Catalog"
    Service     = "Athena"
  })
}

# ========================================
# S3 BUCKET FOR ATHENA RESULTS
# ========================================

resource "aws_s3_bucket" "athena_results" {
  count  = var.create_athena_results_bucket ? 1 : 0
  bucket = "${var.environment}-athena-results-${random_string.athena_bucket_suffix[0].result}"

  tags = merge(var.tags, {
    Name        = "${var.environment}-athena-results"
    Purpose     = "Athena Query Results"
    Service     = "Athena"
  })
}

resource "random_string" "athena_bucket_suffix" {
  count   = var.create_athena_results_bucket ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "athena_results" {
  count  = var.create_athena_results_bucket ? 1 : 0
  bucket = aws_s3_bucket.athena_results[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results" {
  count  = var.create_athena_results_bucket ? 1 : 0
  bucket = aws_s3_bucket.athena_results[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  count  = var.create_athena_results_bucket ? 1 : 0
  bucket = aws_s3_bucket.athena_results[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ========================================
# IAM ROLE FOR ATHENA
# ========================================

resource "aws_iam_role" "athena_role" {
  name = "${var.environment}-athena-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.environment}-athena-role"
    Purpose     = "Athena Service Role"
    Service     = "Athena"
  })
}

resource "aws_iam_role_policy" "athena_policy" {
  name = "${var.environment}-athena-policy"
  role = aws_iam_role.athena_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.athena_results_bucket}",
          "arn:aws:s3:::${var.athena_results_bucket}/*",
          "arn:aws:s3:::${var.data_lake_bucket_name}",
          "arn:aws:s3:::${var.data_lake_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetPartitions",
          "glue:GetPartition",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:GetDatabases",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:GetPartitions"
        ]
        Resource = "*"
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
# CLOUDWATCH LOGGING
# ========================================

resource "aws_cloudwatch_log_group" "athena_queries" {
  count = var.enable_athena_query_logging ? 1 : 0

  name              = var.athena_log_group_name != null ? var.athena_log_group_name : "/aws/athena/${var.environment}-data-warehouse"
  retention_in_days = var.athena_log_retention_days

  tags = merge(var.tags, {
    Name        = "${var.environment}-athena-queries"
    Purpose     = "Athena Query Logging"
    Service     = "Athena"
  })
}

# ========================================
# ATHENA NAMED QUERIES (OPTIONAL)
# ========================================

resource "aws_athena_named_query" "sample_queries" {
  for_each = var.create_athena_sample_queries ? var.athena_sample_queries : {}

  name        = each.key
  workgroup   = aws_athena_workgroup.main.id
  database    = aws_athena_database.main.name
  description = each.value.description
  query       = each.value.query

  tags = merge(var.tags, {
    Name        = "${var.environment}-${each.key}"
    Purpose     = "Athena Named Query"
    Service     = "Athena"
  })
}
