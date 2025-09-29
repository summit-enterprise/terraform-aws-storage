variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ========================================
# ATHENA VARIABLES
# ========================================

variable "data_lake_bucket_name" {
  description = "Name of the S3 bucket containing the data lake"
  type        = string
  default     = null
}

variable "athena_results_bucket" {
  description = "S3 bucket for Athena query results"
  type        = string
  default     = null
}

variable "create_athena_results_bucket" {
  description = "Whether to create a new S3 bucket for Athena results"
  type        = bool
  default     = true
}

variable "athena_engine_version" {
  description = "Athena engine version"
  type        = string
  default     = "Athena engine version 3"
}

variable "enable_athena_query_logging" {
  description = "Enable query logging to CloudWatch"
  type        = bool
  default     = true
}

variable "athena_log_group_name" {
  description = "CloudWatch log group name for Athena queries"
  type        = string
  default     = null
}

variable "athena_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "create_athena_sample_queries" {
  description = "Whether to create sample named queries"
  type        = bool
  default     = true
}

variable "athena_sample_queries" {
  description = "Map of sample named queries to create"
  type        = map(object({
    description = string
    query       = string
  }))
  default = {
    "list_tables" = {
      description = "List all tables in the database"
      query       = "SHOW TABLES;"
    }
    "sample_data_query" = {
      description = "Sample query to test data access"
      query       = "SELECT * FROM information_schema.tables LIMIT 10;"
    }
  }
}
