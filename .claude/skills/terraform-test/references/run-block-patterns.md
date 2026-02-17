# Run Block Patterns

Detailed examples of run block configurations for Terraform tests.

## Basic Integration Test (Apply Mode - Default)

```hcl
run "test_instance_creation" {
  command = apply

  assert {
    condition     = aws_instance.example.id != ""
    error_message = "Instance should be created with a valid ID"
  }

  assert {
    condition     = output.instance_public_ip != ""
    error_message = "Instance should have a public IP"
  }
}
```

## Unit Test (Plan Mode)

```hcl
run "test_default_configuration" {
  command = plan

  assert {
    condition     = aws_instance.example.instance_type == "t2.micro"
    error_message = "Instance type should be t2.micro by default"
  }

  assert {
    condition     = aws_instance.example.tags["Environment"] == "test"
    error_message = "Environment tag should be 'test'"
  }
}
```

## Plan Options

```hcl
run "test_refresh_only" {
  command = plan

  plan_options {
    mode    = refresh-only  # "normal" (default) or "refresh-only"
    refresh = true
    replace = [aws_instance.example]
    target  = [aws_instance.example]
  }

  assert {
    condition     = aws_instance.example.instance_type == "t2.micro"
    error_message = "Instance type should be t2.micro"
  }
}
```

## Variables - File Level and Run Block Override

```hcl
# File-level variables applied to all run blocks
variables {
  instance_type = "t2.small"
  environment   = "test"
}

run "test_with_override_variables" {
  command = plan

  # Override file-level variables
  variables {
    instance_type = "t3.large"
  }

  assert {
    condition     = var.instance_type == "t3.large"
    error_message = "Instance type should be overridden to t3.large"
  }
}
```

## Variables Referencing Prior Run Blocks

```hcl
run "setup_vpc" {
  command = apply
}

run "test_with_vpc_output" {
  command = plan

  variables {
    vpc_id = run.setup_vpc.vpc_id
  }

  assert {
    condition     = var.vpc_id == run.setup_vpc.vpc_id
    error_message = "VPC ID should match setup_vpc output"
  }
}
```

## Module Block - Local Modules

```hcl
run "test_vpc_module" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  variables {
    cidr_block = "10.0.0.0/16"
    name       = "test-vpc"
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should match input variable"
  }
}
```

## Module Block - Registry Modules

```hcl
run "test_registry_module" {
  command = plan

  module {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.0.0"
  }

  variables {
    name = "test-vpc"
    cidr = "10.0.0.0/16"
  }

  assert {
    condition     = output.vpc_id != ""
    error_message = "VPC should be created"
  }
}
```

## Provider Configuration

```hcl
provider "aws" {
  alias  = "primary"
  region = "us-west-2"
}

provider "aws" {
  alias  = "secondary"
  region = "us-east-1"
}

run "test_with_specific_provider" {
  command = plan

  providers = {
    aws = provider.aws.secondary
  }

  assert {
    condition     = aws_instance.example.availability_zone == "us-east-1a"
    error_message = "Instance should be in us-east-1 region"
  }
}
```

## Parallel Execution

Run blocks execute sequentially by default. Use `parallel = true` for independent tests with different state files.

```hcl
run "test_module_a" {
  command  = plan
  parallel = true

  module {
    source = "./modules/module-a"
  }

  assert {
    condition     = output.result != ""
    error_message = "Module A should produce output"
  }
}

run "test_module_b" {
  command  = plan
  parallel = true

  module {
    source = "./modules/module-b"
  }

  assert {
    condition     = output.result != ""
    error_message = "Module B should produce output"
  }
}

# Synchronization point - waits for parallel runs above
run "test_integration" {
  command = plan

  assert {
    condition     = output.combined != ""
    error_message = "Integration should work"
  }
}
```

## State Key Management

```hcl
run "create_vpc" {
  command = apply

  module {
    source = "./modules/vpc"
  }

  state_key = "shared_state"
}

run "create_subnet" {
  command = apply

  module {
    source = "./modules/subnet"
  }

  state_key = "shared_state"  # Shares state with create_vpc
}
```

## Sequential Tests with Dependencies

```hcl
run "setup_vpc" {
  variables {
    vpc_cidr = "10.0.0.0/16"
  }

  assert {
    condition     = output.vpc_id != ""
    error_message = "VPC should be created"
  }
}

run "test_subnet_in_vpc" {
  command = plan

  variables {
    vpc_id = run.setup_vpc.vpc_id
  }

  assert {
    condition     = aws_subnet.example.vpc_id == run.setup_vpc.vpc_id
    error_message = "Subnet should be created in the VPC from setup_vpc"
  }
}
```

## Testing Conditional Resources

```hcl
run "test_conditional_resource_created" {
  command = plan

  variables {
    create_nat_gateway = true
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 1
    error_message = "NAT gateway should be created when enabled"
  }
}

run "test_conditional_resource_not_created" {
  command = plan

  variables {
    create_nat_gateway = false
  }

  assert {
    condition     = length(aws_nat_gateway.main) == 0
    error_message = "NAT gateway should not be created when disabled"
  }
}
```

## Testing Resource Counts

```hcl
run "test_resource_count" {
  command = plan

  variables {
    instance_count = 3
  }

  assert {
    condition     = length(aws_instance.workers) == 3
    error_message = "Should create exactly 3 worker instances"
  }
}
```

## Integration Test - Full Stack

```hcl
run "integration_test_full_stack" {
  # command defaults to apply

  variables {
    environment = "integration-test"
    vpc_cidr    = "10.100.0.0/16"
  }

  assert {
    condition     = aws_vpc.main.id != ""
    error_message = "VPC should be created"
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Should create 2 private subnets"
  }

  assert {
    condition     = aws_instance.bastion.public_ip != ""
    error_message = "Bastion instance should have a public IP"
  }
}
```
