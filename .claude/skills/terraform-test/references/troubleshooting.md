# Troubleshooting

Common issues and solutions when working with Terraform tests.

## Test Failures

### Assertion Failures

**Issue**: `Error: Test assertion failed`

**Solution**: Review error messages, check actual vs expected values, verify variable inputs. Use `-verbose` flag for detailed output.

```bash
terraform test -verbose
```

### Provider Authentication

**Issue**: Tests fail due to missing credentials

**Solution**: Configure provider credentials for testing, or use mock providers for unit tests (available since v1.7.0). For CI/CD, set credentials as environment variables or secrets.

### Resource Dependencies

**Issue**: Tests fail due to missing dependencies

**Solution**: Use sequential run blocks or create setup runs to establish required resources. Remember cleanup happens in reverse order.

### Long Test Execution

**Issue**: Tests take too long to run

**Solutions**:
- Use `command = plan` instead of `apply` where possible
- Leverage mock providers
- Use `parallel = true` for independent tests
- Organize slow integration tests separately
- Run unit tests on every PR, integration tests only on merge/nightly

### State Conflicts

**Issue**: Multiple tests interfere with each other

**Solutions**:
- Use different modules (automatic separate state)
- Use `state_key` attribute to control state file sharing
- Use mock providers for isolated testing

### Module Source Errors

**Issue**: Test fails with unsupported module source

**Solution**: Terraform test files only support **local** and **registry** modules. Convert Git or HTTP sources to local modules or use registry modules.

### Cannot Reference Run Block Output

**Issue**: `Cannot reference run block output`

**Solution**: Ensure run blocks are sequential (not parallel) and use correct syntax: `run.<block_name>.<output_name>`. Parallel run blocks cannot reference each other's outputs.

## Cleanup and Destruction

Resources created with `command = apply` are destroyed in **reverse run block order** after test completion.

For resources with dependencies (e.g., S3 bucket with objects), the reverse order ensures proper cleanup:
1. Objects destroyed first (later run block)
2. Bucket destroyed second (earlier run block)

**Disable cleanup for debugging:**

```bash
terraform test -no-cleanup
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Terraform Tests
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  terraform-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0
      - run: terraform fmt -check -recursive
      - run: terraform init
      - run: terraform validate
      - run: terraform test -verbose
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### GitLab CI

```yaml
terraform-test:
  image: hashicorp/terraform:1.9
  stage: test
  before_script:
    - terraform init
  script:
    - terraform fmt -check -recursive
    - terraform validate
    - terraform test -verbose
  only:
    - merge_requests
    - main
```

## Version Requirements

Key version milestones:
- **Terraform 1.6.0**: Terraform test introduced
- **Terraform 1.7.0**: Mock providers added
- **Terraform 1.9.0**: `state_key` and `parallel` attributes added

Always check user's Terraform version when features from newer versions are requested.
