# terraform-aws-storage

A Terraform module for AWS storage infrastructure including S3, ECR, Glue, and Athena.

## 🏗️ **Architecture**

This module creates:
- **S3 Data Lake** - Scalable object storage with versioning and encryption
- **ECR Repositories** - Container image storage for Spark, data jobs, and Glue jobs
- **AWS Glue** - ETL services with data catalog and crawlers
- **AWS Athena** - Serverless data warehouse querying

## 📋 **Usage**

### **Basic Usage**

```hcl
module "storage" {
  source = "summit-enterprise/storage/aws"
  version = "1.0.0"
  
  environment = "dev"
  vpc_id      = "vpc-12345678"
  tags        = {
    Environment = "dev"
    Project     = "data-engineering"
    ManagedBy   = "terraform"
  }
}
```

### **Advanced Usage with Athena**

```hcl
module "storage" {
  source = "summit-enterprise/storage/aws"
  version = "1.0.0"
  
  environment = "prod"
  vpc_id      = "vpc-12345678"
  tags        = {
    Environment = "prod"
    Project     = "data-engineering"
    ManagedBy   = "terraform"
    CostCenter  = "analytics"
  }
  
  # Athena configuration
  data_lake_bucket_name           = "prod-data-lake-abc123"
  athena_results_bucket          = "prod-athena-results-xyz789"
  create_athena_results_bucket   = true
  athena_engine_version          = "Athena engine version 3"
  enable_athena_query_logging    = true
  athena_log_group_name          = "/aws/athena/prod-data-warehouse"
  athena_log_retention_days      = 30
  create_athena_sample_queries   = true
  athena_sample_queries = {
    "sales_analysis" = {
      description = "Get sales summary by month"
      query       = "SELECT DATE_TRUNC('month', order_date) as month, SUM(amount) as total_sales FROM sales GROUP BY 1 ORDER BY 1;"
    }
    "top_customers" = {
      description = "Get top 10 customers by revenue"
      query       = "SELECT customer_id, SUM(amount) as total_revenue FROM sales GROUP BY 1 ORDER BY 2 DESC LIMIT 10;"
    }
  }
}
```

## 📊 **Resources Created**

### **S3 Resources**
- `aws_s3_bucket.data_lake` - Main data lake bucket
- `aws_s3_bucket_versioning.data_lake` - Versioning configuration
- `aws_s3_bucket_server_side_encryption_configuration.data_lake` - Encryption
- `aws_s3_bucket.athena_results` - Athena query results bucket (optional)

### **ECR Resources**
- `aws_ecr_repository.spark_apps` - Spark applications repository
- `aws_ecr_repository.data_jobs` - Data processing jobs repository
- `aws_ecr_repository.glue_jobs` - Glue ETL jobs repository

### **Glue Resources**
- `aws_glue_catalog_database.data_lake_catalog` - Data catalog database
- `aws_glue_crawler.raw_data_crawler` - Raw data crawler
- `aws_glue_crawler.processed_data_crawler` - Processed data crawler
- `aws_glue_job.data_processing_job` - Data processing ETL job
- `aws_glue_job.data_quality_job` - Data quality validation job

### **Athena Resources**
- `aws_athena_workgroup.main` - Athena workgroup
- `aws_athena_database.main` - Athena database
- `aws_glue_catalog_database.athena_catalog` - Athena data catalog
- `aws_iam_role.athena_role` - IAM role for Athena
- `aws_cloudwatch_log_group.athena_queries` - Query logging (optional)
- `aws_athena_named_query.sample_queries` - Sample named queries (optional)

## 🔧 **Inputs**

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| tags | Common tags to apply to all resources | `map(string)` | `{}` | no |
| data_lake_bucket_name | Name of the S3 bucket containing the data lake | `string` | `null` | no |
| athena_results_bucket | S3 bucket for Athena query results | `string` | `null` | no |
| create_athena_results_bucket | Whether to create a new S3 bucket for Athena results | `bool` | `true` | no |
| athena_engine_version | Athena engine version | `string` | `"Athena engine version 3"` | no |
| enable_athena_query_logging | Enable query logging to CloudWatch | `bool` | `true` | no |
| athena_log_group_name | CloudWatch log group name for Athena queries | `string` | `null` | no |
| athena_log_retention_days | CloudWatch log retention in days | `number` | `14` | no |
| create_athena_sample_queries | Whether to create sample named queries | `bool` | `true` | no |
| athena_sample_queries | Map of sample named queries to create | `map(object)` | See variables.tf | no |

## 📤 **Outputs**

| Name | Description |
|------|-------------|
| data_lake_bucket_name | Name of the main data lake S3 bucket |
| data_lake_bucket_arn | ARN of the main data lake S3 bucket |
| ecr_repository_urls | URLs of the ECR repositories |
| glue_catalog_database_name | Name of the Glue catalog database |
| glue_job_names | Names of the Glue jobs |
| athena_workgroup_name | Name of the Athena workgroup |
| athena_database_name | Name of the Athena database |
| athena_results_bucket_name | Name of the S3 bucket for Athena results |
| athena_console_url | URL to access Athena console |
| athena_query_commands | Sample Athena query commands |

## 🚀 **Quick Start**

### **1. Deploy the Module**
```bash
terraform init
terraform plan
terraform apply
```

### **2. Access Athena Console**
```bash
# Get Athena console URL
terraform output athena_console_url

# Or access directly
open https://console.aws.amazon.com/athena/home?region=us-east-2#workgroups
```

### **3. Run Sample Queries**
```bash
# Get query commands
terraform output athena_query_commands

# Run a sample query
aws athena start-query-execution \
  --work-group $(terraform output -raw athena_workgroup_name) \
  --query-string "SHOW TABLES;"
```

## 💰 **Cost Optimization**

### **S3 Cost Optimization**
- **Lifecycle Policies** - Automatic transition to cheaper storage classes
- **Versioning** - Controlled version management
- **Encryption** - SSE-S3 (cheaper than KMS)

### **Athena Cost Optimization**
- **Result Caching** - Enabled by default
- **Bytes Scanned Limit** - Configurable per workgroup
- **Encryption** - Uses SSE-S3 (cheaper than KMS)

### **Glue Cost Optimization**
- **On-demand Jobs** - No scheduled jobs by default
- **DPU Limits** - Configurable capacity limits
- **Timeout Settings** - Prevent runaway jobs

## 🔐 **Security Features**

### **S3 Security**
- **Encryption at Rest** - AES-256 encryption
- **Versioning** - Data protection and recovery
- **Public Access Block** - Prevent accidental public access

### **Athena Security**
- **IAM Roles** - Least privilege access
- **S3 Encryption** - All data encrypted
- **CloudWatch Logging** - Audit trail for queries

### **Glue Security**
- **IAM Roles** - Service-specific permissions
- **VPC Integration** - Network isolation
- **Encryption** - All data encrypted in transit and at rest

## 🔗 **Integration Examples**

### **With ECS Tasks**
```hcl
resource "aws_ecs_task_definition" "data_processor" {
  # ... configuration
  container_definitions = jsonencode([{
    environment = [
      {
        name  = "S3_BUCKET"
        value = module.storage.data_lake_bucket_name
      },
      {
        name  = "ATHENA_DATABASE"
        value = module.storage.athena_database_name
      }
    ]
  }])
}
```

### **With Lambda Functions**
```hcl
resource "aws_lambda_function" "s3_processor" {
  # ... configuration
  environment {
    variables = {
      S3_BUCKET        = module.storage.data_lake_bucket_name
      ATHENA_WORKGROUP = module.storage.athena_workgroup_name
    }
  }
}
```

## 📚 **Documentation**

- **S3 Data Lake Guide** - Complete S3 setup and usage
- **Athena Data Warehouse Guide** - Querying and analytics
- **Glue ETL Guide** - Data processing workflows
- **ECR Container Guide** - Image management

## 🔧 **Troubleshooting**

### **Common Issues**

#### **Permission Denied**
```bash
# Check IAM role permissions
aws iam get-role --role-name dev-athena-role

# Check S3 bucket permissions
aws s3api get-bucket-policy --bucket your-bucket-name
```

#### **Athena Query Fails**
```bash
# Check workgroup configuration
aws athena get-work-group --work-group dev-data-warehouse

# Check database exists
aws athena get-database --catalog-name AwsDataCatalog --database-name dev_data_warehouse
```

## 📞 **Support**

For issues and questions:
- **GitHub Issues** - Create an issue in the repository
- **Documentation** - Check AWS service documentation
- **Community** - AWS re:Post or Stack Overflow

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| random | ~> 3.1 |

## License

MIT
