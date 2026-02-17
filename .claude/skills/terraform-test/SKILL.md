---
name: terraform-test
description: Comprehensive guide for writing and running Terraform tests. Use when creating test files (.tftest.hcl), writing test scenarios with run blocks, validating infrastructure behavior, mocking providers, and troubleshooting test execution.
---

# Terraform Test

Terraform's built-in testing framework enables module authors to validate that configuration updates don't introduce breaking changes. Tests execute against temporary resources, protecting existing infrastructure and state files.

## Core Concepts

| Concept           | Description                                                                       |
| ----------------- | --------------------------------------------------------------------------------- |
| **Test File**     | `.tftest.hcl` or `.tftest.json` file containing test configuration and run blocks |
| **Test Block**    | Optional block for test-wide settings like parallel execution (since v1.6.0)      |
| **Run Block**     | Defines a single test scenario with variables, providers, and assertions          |
| **Assert Block**  | Condition that must evaluate to true for the test to pass                         |
| **Mock Provider** | Simulates provider behavior without real infrastructure (since v1.7.0)            |
| **Plan Mode**     | `command = plan` - validates logic without creating resources (unit test)         |
| **Apply Mode**    | `command = apply` (default) - creates real infrastructure (integration test)      |

## File Structure

```
my-module/
├── main.tf
├── variables.tf
├── outputs.tf
└── tests/
    ├── defaults_unit_test.tftest.hcl
    ├── validation_unit_test.tftest.hcl
    └── full_stack_integration_test.tftest.hcl
```

A test file contains:

- **Zero to one** `test` block (settings)
- **One to many** `run` blocks (test executions)
- **Zero to one** `variables` block (input values)
- **Zero to many** `provider` blocks
- **Zero to many** `mock_provider` blocks (since v1.7.0)

## Test Block

```hcl
test {
  parallel = true  # Enable parallel execution for all run blocks (default: false)
}
```

## Run Block

Each run block executes a command against your configuration. Run blocks execute **sequentially by default**.

```hcl
run "test_name" {
  command = plan  # or apply (default)

  variables {
    key = "value"
  }

  assert {
    condition     = aws_instance.example.instance_type == "t2.micro"
    error_message = "Instance type should be t2.micro"
  }
}
```

**Run Block Attributes:**

| Attribute         | Description                                                     |
| ----------------- | --------------------------------------------------------------- |
| `command`         | `apply` (default) or `plan`                                     |
| `plan_options`    | Configure plan behavior: `mode`, `refresh`, `replace`, `target` |
| `variables`       | Override test-level variable values                             |
| `module`          | Reference alternate modules (`source`, `version`)               |
| `providers`       | Customize provider availability                                 |
| `assert`          | Validation conditions (multiple allowed)                        |
| `expect_failures` | Specify expected validation failures                            |
| `state_key`       | Manage state file isolation (since v1.9.0)                      |
| `parallel`        | Enable parallel execution (since v1.9.0)                        |

## Variables

Variables defined in test files have the **highest precedence**, overriding environment variables, `.tfvars` files, and `-var` flags.

- File-level `variables {}` block applies to all run blocks
- Run-level `variables {}` overrides file-level values
- Run blocks can reference prior run outputs: `run.<block_name>.<output>`

## Assert Block

```hcl
assert {
  condition     = <expression>
  error_message = "failure description"
}
```

Multiple assertions per run block are allowed. All must pass.

## Expect Failures

Test that validation rules correctly reject invalid input. The test **passes** if the specified checkable objects fail.

```hcl
run "test_invalid_input" {
  command = plan
  variables { instance_count = -1 }
  expect_failures = [var.instance_count]
}
```

Checkable objects: input variables, output values, check blocks, resources, data sources.

## Module Block

Test specific modules rather than root configuration.

**Supported sources:** local paths (`./modules/vpc`), public registry (`terraform-aws-modules/vpc/aws`), private registry (`app.terraform.io/org/module/provider`).

**Not supported:** Git repositories, HTTP URLs, S3/GCS sources.

```hcl
run "test_vpc_module" {
  command = plan
  module {
    source  = "./modules/vpc"
  }
  variables { cidr_block = "10.0.0.0/16" }
  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should match input"
  }
}
```

## Mock Providers

Simulate provider behavior without creating real infrastructure (requires Terraform 1.7.0+). Mocks only work with `command = plan`.

```hcl
mock_provider "aws" {
  mock_resource "aws_instance" {
    defaults = {
      id            = "i-1234567890abcdef0"
      instance_type = "t2.micro"
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

## Parallel Execution

Requirements for `parallel = true`:

- No inter-run output references
- Different state files (via different modules or `state_key`)
- A non-parallel run block after parallel ones creates a synchronization point

## State Key Management

By default, main configuration shares state across run blocks; alternate modules get separate state. Use `state_key` to explicitly control sharing.

```hcl
run "step_a" {
  command   = apply
  module    { source = "./modules/a" }
  state_key = "shared"
}
run "step_b" {
  command   = apply
  module    { source = "./modules/b" }
  state_key = "shared"  # Shares state with step_a
}
```

## Cleanup

Resources are destroyed in **reverse run block order** after test completion. Use `terraform test -no-cleanup` for debugging.

## Test Execution

```bash
terraform test                                    # Run all tests
terraform test tests/defaults.tftest.hcl          # Run specific file
terraform test -verbose                           # Verbose output
terraform test -test-directory=integration-tests  # Specific directory
terraform test -filter=test_vpc_configuration     # Filter by name
terraform test -no-cleanup                        # Skip cleanup (debug)
```

## Best Practices

1. **Naming**: Use `*_unit_test.tftest.hcl` for plan-mode tests, `*_integration_test.tftest.hcl` for apply-mode
2. **Start with plan mode**: Fast, free, no real resources
3. **Use mocks** for isolated unit testing (v1.7.0+)
4. **Clear error messages**: Write messages that help diagnose failures
5. **Test isolation**: Keep run blocks independent when possible
6. **Variable coverage**: Test different combinations to validate all code paths
7. **Negative testing**: Use `expect_failures` for invalid inputs
8. **CI/CD**: Run unit tests on every PR; integration tests on merge/nightly
9. **Parallel execution**: Use for independent tests with different state files

## Version Requirements

| Version | Feature                               |
| ------- | ------------------------------------- |
| 1.6.0   | Terraform test introduced             |
| 1.7.0   | Mock providers added                  |
| 1.9.0   | `state_key` and `parallel` attributes |

## Example: Complete Unit Test File

```hcl
# tests/vpc_module_unit_test.tftest.hcl
variables {
  environment = "test"
  aws_region  = "us-west-2"
}

run "test_defaults" {
  command = plan
  variables {
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "test-vpc"
  }
  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should match input"
  }
  assert {
    condition     = aws_vpc.main.tags["Name"] == "test-vpc"
    error_message = "VPC name tag should match input"
  }
}

run "test_subnets" {
  command = plan
  variables {
    vpc_cidr        = "10.0.0.0/16"
    vpc_name        = "test-vpc"
    public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
  }
  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Should create 2 public subnets"
  }
  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Should create 2 private subnets"
  }
}

run "test_invalid_cidr" {
  command = plan
  variables {
    vpc_cidr = "invalid"
    vpc_name = "test-vpc"
  }
  expect_failures = [var.vpc_cidr]
}
```

## References

For detailed examples and patterns, see:

- [Run Block Patterns](references/run-block-patterns.md) - Detailed run block configurations
- [Assertion Patterns](references/assertion-patterns.md) - Assert and expect_failures examples
- [Mock Patterns](references/mock-patterns.md) - Provider and data source mocking
- [Troubleshooting](references/troubleshooting.md) - Common issues, CI/CD integration

External documentation:

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Terraform Test Command Reference](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Testing Best Practices](https://developer.hashicorp.com/terraform/language/tests/best-practices)
