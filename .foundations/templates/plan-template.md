<!-- Placeholder convention: [BRACKETS] = human-authored content (instructions, descriptions).
     {{DOUBLE_BRACES}} = machine-filled values (timestamps, scores, IDs). -->

# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/tf-plan` command.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!-- Replace with actual technical details. -->

**Terraform Version**: [e.g., >= 1.5.0 or NEEDS CLARIFICATION]
**Provider(s)**: [e.g., hashicorp/aws >= X.0 (determine minimum from research), hashicorp/random >= 3.0 or NEEDS CLARIFICATION — use `>=` per constitution]
**AWS Services**: [e.g., VPC, EC2, IAM, S3 or NEEDS CLARIFICATION]
**Testing**: `terraform test` (native HCL-based tests in `tests/` directory)
**Target Platform**: [e.g., AWS commercial regions, AWS GovCloud, or NEEDS CLARIFICATION]
**Module Type**: [root module / child module / wrapper module]
**Performance Goals**: [e.g., Plan completes in < 30s, supports up to 50 subnets or NEEDS CLARIFICATION]
**Constraints**: [e.g., No external provisioners, no local-exec, must be registry-compatible or NEEDS CLARIFICATION]
**Scale/Scope**: [e.g., Manages ~15 resources, supports multi-AZ deployments or NEEDS CLARIFICATION]

## Resource Inventory

<!-- Replace with actual technical details. -->

### Resources Created

| Resource Type | Logical Name | Purpose | Conditional |
|---------------|-------------|---------|-------------|
| `{{RESOURCE_TYPE}}` | `{{LOGICAL_NAME}}` | [Resource purpose] | {{CONDITIONAL}} |

### Data Sources

| Data Source | Purpose |
|-------------|---------|
| `{{DATA_SOURCE}}` | [Data source purpose] |

### Submodules (if applicable)

| Submodule | Path | Purpose |
|-----------|------|---------|
| [submodule_name] | `modules/[name]/` | [Purpose] |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

List ONLY exceptions or failures. If all pass, write: "All constitution checks pass. No exceptions."

<!-- Do NOT duplicate variable/output tables from contracts. Per-phase variables: list NAMES only. -->

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/tf-plan workflow output)
├── research-*.md        # Per-topic research files (/tf-plan workflow)
├── contracts/data-model.md  # Phase 1 output (/tf-plan workflow)
├── quickstart.md        # Phase 1 output (/tf-plan workflow)
├── contracts/           # Phase 1 output (/tf-plan workflow)
└── tasks.md             # Phase 2 output (/tf-plan task generation phase - NOT created by /tf-plan)
```

### Source Code (Terraform Module Layout)

```text
.                          # Root module
├── main.tf                # Primary resource definitions
├── variables.tf           # Input variable declarations
├── outputs.tf             # Output value declarations
├── versions.tf            # Terraform and provider version constraints
├── locals.tf              # Local value computations (if needed)
├── data.tf                # Data source definitions (if needed)
├── README.md              # Module documentation (inputs, outputs, examples)
│
├── modules/               # Nested submodules (if needed)
│   └── [submodule]/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── examples/              # Example configurations for consumers
│   ├── basic/             # Minimal viable configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   └── complete/          # Full-featured configuration
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
│
└── tests/                 # Terraform test files
    ├── basic.tftest.hcl   # Tests for basic example
    └── complete.tftest.hcl # Tests for complete example
```

## Testing Strategy

### Unit Tests (terraform test)

| Test File | Scope | What It Validates |
|-----------|-------|-------------------|
| `tests/basic.tftest.hcl` | Basic example | Minimum viable configuration creates expected resources |
| `tests/complete.tftest.hcl` | Complete example | Full-featured configuration with all options enabled |
| [Add more as needed] | | |

### Validation

| Check | Command | When |
|-------|---------|------|
| Format | `terraform fmt -check -recursive` | Pre-commit, CI |
| Validate | `terraform validate` | Pre-commit, CI |
| Lint | `tflint` | Pre-commit, CI |
| Security | `trivy config .` | Pre-commit, CI |
| Tests | `terraform test` | CI, pre-merge |

### Integration Testing

- Deploy `examples/basic/` to validate minimal configuration
- Deploy `examples/complete/` to validate full-featured configuration
- Verify outputs match expected values
- Destroy and verify clean teardown

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., nested submodule] | [current need] | [why flat structure insufficient] |
| [e.g., external data source] | [specific problem] | [why static value insufficient] |
