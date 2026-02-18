---
name: tf-implementation-patterns
description: Common Terraform resource authoring patterns for AWS infrastructure. VPC, IAM, compute, storage, database, and module design patterns using raw resources with secure defaults. Use when implementing AWS resources in Terraform modules or looking for resource authoring patterns.
---

# Terraform Implementation Patterns

Reference patterns for implementing AWS infrastructure resources within Terraform modules. All patterns enforce security-first defaults and standard module structure.

## Workflow

1. **Identify**: Determine infrastructure type needed (VPC, IAM, compute, storage, database)
2. **Research**: Query AWS documentation and provider docs for resource behavior and best practices
3. **Select**: Choose pattern from Context section matching the use case
4. **Adapt**: Customize resource configuration for specific requirements
5. **Wire**: Connect resources via references and outputs
6. **Test**: Write `.tftest.hcl` tests, run `terraform fmt` and `terraform validate`

## Output

- **Location**: Module files (`main.tf`, `variables.tf`, `outputs.tf`, `locals.tf`)
- **Format**: HCL with native Terraform resources and data sources
- **Validation**: `terraform fmt` after every file change, `terraform validate` after every phase, `terraform test` after implementation

## Constraints

Follow `terraform-style-guide` skill and constitution sections 3.2-3.5 for formatting, variable, and module structure rules.

## Examples

**Good variable definition**:
```hcl
variable "create" {
  description = "Controls whether resources are created by this module"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to use for all resources created by this module"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 64
    error_message = "Name must be between 1 and 64 characters."
  }
}
```

**Bad variable definition**:
```hcl
variable "name" {}
```
Missing description, type, and validation.

**Good output with conditional resource**:
```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this[0].id, null)
}
```

## Context

### AWS VPC Pattern

```hcl
resource "aws_vpc" "this" {
  count = var.create ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_subnet" "public" {
  for_each = var.create ? toset(var.public_subnet_cidrs) : []

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, index(var.public_subnet_cidrs, each.value))

  tags = merge(var.tags, {
    Name = "${var.name}-public-${element(var.availability_zones, index(var.public_subnet_cidrs, each.value))}"
    Tier = "public"
  })
}

resource "aws_flow_log" "this" {
  count = var.create && var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.this[0].id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn

  tags = var.tags
}
```

| Consideration | Requirement |
|---------------|-------------|
| Availability | Multi-AZ (2-3 zones) |
| Subnets | Public/private/data tiers |
| Egress | NAT Gateway for private subnets (optional, toggleable) |
| Logging | VPC Flow Logs enabled by default |

### AWS IAM Pattern

```hcl
data "aws_iam_policy_document" "assume_role" {
  count = var.create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.trusted_services
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  description        = var.description

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create ? toset(var.policy_arns) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
```

| Consideration | Requirement |
|---------------|-------------|
| Resources | Specific ARNs, never `*` |
| EC2 | Use instance profiles |
| Services | Service-linked roles where available |
| Credentials | No static credentials ever |

### AWS Storage Pattern

```hcl
resource "aws_s3_bucket" "this" {
  count = var.create ? 1 : 0

  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.create && var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create ? 1 : 0

  bucket                  = aws_s3_bucket.this[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### Dynamic Block Pattern

```hcl
resource "aws_security_group" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  tags = var.tags
}
```
