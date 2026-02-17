# Mock Provider Patterns

Detailed examples of provider and data source mocking for Terraform tests (requires Terraform 1.7.0+).

## Basic Mock Provider

```hcl
mock_provider "aws" {
  mock_resource "aws_instance" {
    defaults = {
      id            = "i-1234567890abcdef0"
      instance_type = "t2.micro"
      ami           = "ami-12345678"
    }
  }

  mock_data "aws_ami" {
    defaults = {
      id = "ami-12345678"
    }
  }
}

run "test_with_mocks" {
  command = plan

  assert {
    condition     = aws_instance.example.id == "i-1234567890abcdef0"
    error_message = "Mock instance ID should match"
  }
}
```

## Advanced Mock with Alias

```hcl
mock_provider "aws" {
  alias = "mocked"

  mock_resource "aws_s3_bucket" {
    defaults = {
      id     = "test-bucket-12345"
      bucket = "test-bucket"
      arn    = "arn:aws:s3:::test-bucket"
    }
  }

  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-west-2a", "us-west-2b", "us-west-2c"]
    }
  }
}

run "test_with_mock_provider" {
  command = plan

  providers = {
    aws = provider.aws.mocked
  }

  assert {
    condition     = length(data.aws_availability_zones.available.names) == 3
    error_message = "Should return 3 availability zones"
  }
}
```

## Comprehensive Mock Provider Example

A full mock provider covering multiple resource types and data sources.

```hcl
mock_provider "aws" {
  # EC2 instances
  mock_resource "aws_instance" {
    defaults = {
      id                          = "i-1234567890abcdef0"
      arn                         = "arn:aws:ec2:us-west-2:123456789012:instance/i-1234567890abcdef0"
      instance_type               = "t2.micro"
      ami                         = "ami-12345678"
      availability_zone           = "us-west-2a"
      subnet_id                   = "subnet-12345678"
      vpc_security_group_ids      = ["sg-12345678"]
      associate_public_ip_address = true
      public_ip                   = "203.0.113.1"
      private_ip                  = "10.0.1.100"
      tags                        = {}
    }
  }

  # VPC resources
  mock_resource "aws_vpc" {
    defaults = {
      id                       = "vpc-12345678"
      arn                      = "arn:aws:ec2:us-west-2:123456789012:vpc/vpc-12345678"
      cidr_block              = "10.0.0.0/16"
      enable_dns_hostnames    = true
      enable_dns_support      = true
      instance_tenancy        = "default"
      tags                    = {}
    }
  }

  # Subnet resources
  mock_resource "aws_subnet" {
    defaults = {
      id                      = "subnet-12345678"
      arn                     = "arn:aws:ec2:us-west-2:123456789012:subnet/subnet-12345678"
      vpc_id                  = "vpc-12345678"
      cidr_block             = "10.0.1.0/24"
      availability_zone       = "us-west-2a"
      map_public_ip_on_launch = false
      tags                    = {}
    }
  }

  # S3 bucket resources
  mock_resource "aws_s3_bucket" {
    defaults = {
      id                  = "test-bucket-12345"
      arn                 = "arn:aws:s3:::test-bucket-12345"
      bucket              = "test-bucket-12345"
      bucket_domain_name  = "test-bucket-12345.s3.amazonaws.com"
      region              = "us-west-2"
      tags                = {}
    }
  }

  # Data sources
  mock_data "aws_ami" {
    defaults = {
      id                  = "ami-0c55b159cbfafe1f0"
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210430"
      architecture        = "x86_64"
      root_device_type    = "ebs"
      virtualization_type = "hvm"
      owners              = ["099720109477"]
    }
  }

  mock_data "aws_availability_zones" {
    defaults = {
      names    = ["us-west-2a", "us-west-2b", "us-west-2c"]
      zone_ids = ["usw2-az1", "usw2-az2", "usw2-az3"]
    }
  }

  mock_data "aws_vpc" {
    defaults = {
      id                   = "vpc-12345678"
      cidr_block          = "10.0.0.0/16"
      enable_dns_hostnames = true
      enable_dns_support   = true
    }
  }
}
```

## Testing with Mocks - Common Patterns

### Validate Resource Configuration

```hcl
run "test_instance_with_mocks" {
  command = plan

  variables {
    instance_type = "t2.micro"
    ami_id        = "ami-12345678"
  }

  assert {
    condition     = aws_instance.example.instance_type == "t2.micro"
    error_message = "Instance type should match input variable"
  }

  assert {
    condition     = aws_instance.example.id == "i-1234567890abcdef0"
    error_message = "Mock should return consistent instance ID"
  }
}
```

### Validate Data Source Behavior

```hcl
run "test_data_source_with_mocks" {
  command = plan

  assert {
    condition     = data.aws_ami.ubuntu.id == "ami-0c55b159cbfafe1f0"
    error_message = "Mock data source should return predictable AMI ID"
  }

  assert {
    condition     = length(data.aws_availability_zones.available.names) == 3
    error_message = "Should return 3 mocked availability zones"
  }
}
```

### Validate for_each Logic

```hcl
run "test_multiple_subnets_with_mocks" {
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
      for subnet in aws_subnet.subnets :
      subnet.vpc_id == "vpc-12345678"
    ])
    error_message = "All subnets should belong to mocked VPC"
  }
}
```

### Validate Outputs

```hcl
run "test_outputs_with_mocks" {
  command = plan

  assert {
    condition     = output.vpc_id == "vpc-12345678"
    error_message = "VPC ID output should match mocked value"
  }

  assert {
    condition     = output.instance_public_ip == "203.0.113.1"
    error_message = "Instance public IP should match mock"
  }
}
```

### Validate Conditional Logic

```hcl
run "test_conditional_resources_with_mocks" {
  command = plan

  variables {
    create_bastion     = true
    create_nat_gateway = false
  }

  assert {
    condition     = length(aws_instance.bastion) == 1
    error_message = "Bastion should be created when enabled"
  }

  assert {
    condition     = length(aws_nat_gateway.nat) == 0
    error_message = "NAT gateway should not be created when disabled"
  }
}
```

### Sequential Mock Tests with State Sharing

```hcl
run "setup_vpc_with_mocks" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "test-vpc"
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should match input"
  }
}

run "test_subnet_references_vpc_with_mocks" {
  command = plan

  variables {
    vpc_id      = run.setup_vpc_with_mocks.vpc_id
    subnet_cidr = "10.0.1.0/24"
  }

  assert {
    condition     = aws_subnet.example.vpc_id == run.setup_vpc_with_mocks.vpc_id
    error_message = "Subnet should reference VPC from previous run"
  }
}
```

## Benefits of Mock Testing

1. **No Cloud Costs**: Runs entirely locally without creating infrastructure
2. **No Credentials Needed**: Perfect for CI/CD environments without cloud access
3. **Fast Execution**: Tests complete in seconds, not minutes
4. **Predictable Results**: Data sources return consistent values
5. **Isolated Testing**: No dependencies on existing cloud resources
6. **Safe Experimentation**: Test destructive operations without risk

## Limitations of Mock Testing

1. **Plan Mode Only**: Mocks don't work with `command = apply`
2. **Not Real Behavior**: Mocks may not reflect actual provider API behavior
3. **Computed Values**: Mock defaults may not match real computed attributes
4. **Provider Updates**: Mocks need manual updates when provider schemas change
5. **Resource Interactions**: Can't test real resource dependencies or timing issues

## When to Use Mock Tests

- Testing Terraform logic and conditionals
- Validating variable transformations
- Testing for_each and count expressions
- Checking output calculations
- Local development without cloud access
- Fast CI/CD feedback loops

## When NOT to Use Mock Tests

- Validating actual provider behavior
- Testing real resource creation side effects
- Verifying API-level interactions
- End-to-end integration testing
