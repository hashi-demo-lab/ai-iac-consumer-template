# Assertion Patterns

Detailed examples of assert and expect_failures patterns for Terraform tests.

## Assert Block Syntax

```hcl
assert {
  condition     = <expression>
  error_message = "failure description"
}
```

## Resource Attribute Assertions

```hcl
run "test_resource_configuration" {
  command = plan

  assert {
    condition     = aws_s3_bucket.example.bucket == "my-test-bucket"
    error_message = "Bucket name should match expected value"
  }

  assert {
    condition     = aws_s3_bucket.example.versioning[0].enabled == true
    error_message = "Bucket versioning should be enabled"
  }

  assert {
    condition     = length(aws_s3_bucket.example.tags) > 0
    error_message = "Bucket should have at least one tag"
  }
}
```

## Output Validation

```hcl
run "test_outputs" {
  command = plan

  assert {
    condition     = output.vpc_id != ""
    error_message = "VPC ID output should not be empty"
  }

  assert {
    condition     = length(output.subnet_ids) == 3
    error_message = "Should create exactly 3 subnets"
  }
}
```

## Testing Module Outputs

```hcl
run "test_module_outputs" {
  command = plan

  assert {
    condition     = output.vpc_id != null
    error_message = "VPC ID output must be defined"
  }

  assert {
    condition     = can(regex("^vpc-", output.vpc_id))
    error_message = "VPC ID should start with 'vpc-'"
  }

  assert {
    condition     = length(output.subnet_ids) >= 2
    error_message = "Should output at least 2 subnet IDs"
  }
}
```

## Referencing Prior Run Block Outputs

```hcl
run "create_vpc" {
  command = apply
}

run "validate_vpc_output" {
  command = plan

  assert {
    condition     = run.create_vpc.vpc_id != ""
    error_message = "VPC from previous run should have an ID"
  }
}
```

## Complex Conditions

```hcl
run "test_complex_validation" {
  command = plan

  assert {
    condition = alltrue([
      for subnet in aws_subnet.private :
      can(regex("^10\\.0\\.", subnet.cidr_block))
    ])
    error_message = "All private subnets should use 10.0.0.0/8 CIDR range"
  }

  assert {
    condition = alltrue([
      for instance in aws_instance.workers :
      contains(["t2.micro", "t2.small", "t3.micro"], instance.instance_type)
    ])
    error_message = "Worker instances should use approved instance types"
  }
}
```

## Testing Tags

```hcl
run "test_resource_tags" {
  command = plan

  variables {
    common_tags = {
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }

  assert {
    condition     = aws_instance.example.tags["Environment"] == "production"
    error_message = "Environment tag should be set correctly"
  }

  assert {
    condition     = aws_instance.example.tags["ManagedBy"] == "Terraform"
    error_message = "ManagedBy tag should be set correctly"
  }
}
```

## Testing Data Sources

```hcl
run "test_data_source_lookup" {
  command = plan

  assert {
    condition     = data.aws_ami.ubuntu.id != ""
    error_message = "Should find a valid Ubuntu AMI"
  }

  assert {
    condition     = can(regex("^ami-", data.aws_ami.ubuntu.id))
    error_message = "AMI ID should be in correct format"
  }
}
```

## Expect Failures - Validation Rules

Test that certain conditions intentionally fail. The test passes if the specified checkable objects report an issue.

Checkable objects include: input variables, output values, check blocks, and managed resources or data sources.

```hcl
run "test_invalid_input_rejected" {
  command = plan

  variables {
    instance_count = -1
  }

  expect_failures = [
    var.instance_count
  ]
}
```

## Expect Failures - Custom Conditions

```hcl
run "test_custom_condition_failure" {
  command = plan

  variables {
    instance_type = "t2.nano"  # Invalid type
  }

  expect_failures = [
    var.instance_type
  ]
}
```

## Testing Validation Rules (Both Valid and Invalid)

```hcl
# In variables.tf
# variable "environment" {
#   type = string
#   validation {
#     condition     = contains(["dev", "staging", "prod"], var.environment)
#     error_message = "Environment must be dev, staging, or prod"
#   }
# }

run "test_valid_environment" {
  command = plan

  variables {
    environment = "staging"
  }

  assert {
    condition     = var.environment == "staging"
    error_message = "Valid environment should be accepted"
  }
}

run "test_invalid_environment" {
  command = plan

  variables {
    environment = "invalid"
  }

  expect_failures = [
    var.environment
  ]
}
```

## Tag Propagation with for_each

```hcl
run "test_tag_inheritance" {
  command = plan

  variables {
    common_tags = {
      Environment = "test"
      ManagedBy   = "Terraform"
      Project     = "Testing"
    }
  }

  assert {
    condition = alltrue([
      for key in keys(var.common_tags) :
      contains(keys(aws_instance.example.tags), key)
    ])
    error_message = "All common tags should be present on instance"
  }
}
```

## Testing for_each with Complex Conditions

```hcl
run "test_multiple_subnets" {
  command = plan

  variables {
    subnet_cidrs = {
      "public-a"  = "10.0.1.0/24"
      "public-b"  = "10.0.2.0/24"
      "private-a" = "10.0.10.0/24"
      "private-b" = "10.0.11.0/24"
    }
  }

  assert {
    condition     = length(keys(aws_subnet.subnets)) == 4
    error_message = "Should create 4 subnets from for_each map"
  }

  assert {
    condition = alltrue([
      for name, subnet in aws_subnet.subnets :
      can(regex("^public-", name)) ? subnet.map_public_ip_on_launch == true : true
    ])
    error_message = "Public subnets should map public IPs on launch"
  }
}
```
