output "data_lake_bucket_name" {
  description = "Name of the main data lake S3 bucket"
  value       = aws_s3_bucket.data_lake.bucket
}

output "data_lake_bucket_arn" {
  description = "ARN of the main data lake S3 bucket"
  value       = aws_s3_bucket.data_lake.arn
}

output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value = {
    spark_apps = aws_ecr_repository.spark_apps.repository_url
    data_jobs  = aws_ecr_repository.data_jobs.repository_url
    glue_jobs  = aws_ecr_repository.glue_jobs.repository_url
  }
}

output "glue_catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.data_lake_catalog.name
}

output "glue_job_names" {
  description = "Names of the Glue jobs"
  value = {
    data_processing = aws_glue_job.data_processing_job.name
    data_quality    = aws_glue_job.data_quality_job.name
  }
}

# ========================================
# ATHENA OUTPUTS
# ========================================

output "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  value       = aws_athena_workgroup.main.name
}

output "athena_workgroup_arn" {
  description = "ARN of the Athena workgroup"
  value       = aws_athena_workgroup.main.arn
}

output "athena_database_name" {
  description = "Name of the Athena database"
  value       = aws_athena_database.main.name
}

output "athena_database_id" {
  description = "ID of the Athena database"
  value       = aws_athena_database.main.id
}

output "athena_data_catalog_name" {
  description = "Name of the Glue data catalog"
  value       = aws_glue_catalog_database.athena_catalog.name
}

output "athena_results_bucket_name" {
  description = "Name of the S3 bucket for Athena results"
  value       = var.create_athena_results_bucket ? aws_s3_bucket.athena_results[0].bucket : var.athena_results_bucket
}

output "athena_results_bucket_arn" {
  description = "ARN of the S3 bucket for Athena results"
  value       = var.create_athena_results_bucket ? aws_s3_bucket.athena_results[0].arn : null
}

output "athena_role_arn" {
  description = "ARN of the IAM role for Athena"
  value       = aws_iam_role.athena_role.arn
}

output "athena_role_name" {
  description = "Name of the IAM role for Athena"
  value       = aws_iam_role.athena_role.name
}

output "athena_named_queries" {
  description = "Map of created named queries"
  value = {
    for k, v in aws_athena_named_query.sample_queries : k => {
      name = v.name
      id   = v.id
    }
  }
}

output "athena_query_commands" {
  description = "Sample Athena query commands"
  value = {
    connect_to_workgroup = "aws athena start-query-execution --work-group ${aws_athena_workgroup.main.name} --query-string 'SHOW TABLES;'"
    list_databases       = "aws athena start-query-execution --work-group ${aws_athena_workgroup.main.name} --query-string 'SHOW DATABASES;'"
    sample_query         = "aws athena start-query-execution --work-group ${aws_athena_workgroup.main.name} --query-string 'SELECT * FROM ${aws_athena_database.main.name}.information_schema.tables LIMIT 10;'"
  }
}

output "athena_console_url" {
  description = "URL to access Athena console"
  value       = "https://console.aws.amazon.com/athena/home?region=${data.aws_region.current.name}#workgroups"
}

output "athena_s3_query_results_path" {
  description = "S3 path for query results"
  value       = "s3://${var.create_athena_results_bucket ? aws_s3_bucket.athena_results[0].bucket : var.athena_results_bucket}/athena-results/"
}

output "athena_cloudwatch_log_group" {
  description = "CloudWatch log group for Athena queries"
  value       = var.enable_athena_query_logging ? aws_cloudwatch_log_group.athena_queries[0].name : null
}

# Data source for current region
data "aws_region" "current" {}
