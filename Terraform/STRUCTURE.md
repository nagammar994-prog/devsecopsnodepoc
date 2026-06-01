# DevSecOps Terraform Structure

## Directory Layout

```
Terraform/
├── dev/                          # Dev environment root module
│   ├── backend.tf               # Terraform backend configuration
│   ├── main.tf                  # Module calls and orchestration
│   └── variable.tf              # Input variables and defaults
│
└── modules/                      # Reusable modules
    ├── vpc/
    │   ├── main.tf              # VPC, subnets, NAT resources
    │   └── variable.tf          # VPC input variables
    │
    ├── security_groups/
    │   ├── main.tf              # Security group rules
    │   └── variable.tf          # Security group variables
    │
    ├── alb/
    │   ├── main.tf              # Application Load Balancer
    │   └── variable.tf          # ALB variables
    │
    ├── ecr/
    │   ├── main.tf              # ECR registry
    │   └── variable.tf          # ECR variables
    │
    ├── ecs/
    │   ├── main.tf              # ECS cluster
    │   └── variable.tf          # ECS variables
    │
    ├── cloudwatch/
    │   ├── main.tf              # CloudWatch logs
    │   └── variable.tf          # CloudWatch variables
    │
    ├── iam/
    │   ├── main.tf              # IAM roles & policies
    │   └── variable.tf          # IAM variables
    │
    ├── codebuild/
    │   ├── main.tf              # CodeBuild projects
    │   └── variable.tf          # CodeBuild variables
    │
    └── codepipeline/
        ├── main.tf              # CodePipeline configuration
        └── variable.tf          # CodePipeline variables
```

## Key Features

### Dev Environment (Root Module)
- **backend.tf**: S3 + DynamoDB backend for state management
- **main.tf**: Orchestrates all modules with proper dependency flow
- **variable.tf**: Centralized input variables and defaults

### Module Variables Structure
Each module has **variable.tf** with:
- Variable names only
- Type declarations
- Sensible defaults where applicable

### Module Outputs
Each module exports relevant resource IDs/ARNs for inter-module communication

## Usage

### Initialize Terraform
```bash
cd Terraform/dev
terraform init
```

### Plan Infrastructure
```bash
terraform plan
```

### Apply Configuration
```bash
terraform apply
```

### Module Dependencies
Flow: VPC → Security Groups → ALB, ECS, CloudWatch
Flow: IAM → CodeBuild, CodePipeline
All: Orchestrated in dev/main.tf

## Variables Reference

### Global
- aws_region, environment, project_name, common_tags

### VPC
- vpc_cidr_block, enable_dns_hostnames, enable_dns_support
- public_subnet_cidrs, private_subnet_cidrs

### Security
- alb_security_group_name, ecs_security_group_name
- alb_ingress_port, alb_ingress_cidr_blocks, ecs_ingress_port

### Compute
- ecs_cluster_name, alb_name, ecr_repository_name

### CI/CD
- pipeline_name, github_repository_id, github_branch
- codestar_connection_arn, artifact_bucket_name

### Build & Security
- security_build_name, zap_build_name
- compute_type, docker_image

## Backend Configuration
- **Bucket**: devsecops-terraform-state
- **Key**: dev/terraform.tfstate
- **Region**: us-east-1
- **Encryption**: Enabled
- **Lock Table**: terraform-locks (DynamoDB)

### Create Backend Resources (First Time)
```bash
aws s3api create-bucket --bucket devsecops-terraform-state --region us-east-1
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

## Next Steps
1. Fill in module/*/main.tf with actual resource definitions
2. Set values in dev/variable.tf or pass overrides with -var
3. Create S3 bucket and DynamoDB table for state
4. Run terraform init, plan, and apply
