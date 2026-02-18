---
name: tf-report-template
description: Module readiness report structure, data collection patterns, and section templates for Terraform module documentation. Use when generating module readiness reports, collecting deployment metrics, or documenting security findings.
---

# Terraform Module Readiness Report Patterns

## Report Generation Workflow

1. **Setup**: `BRANCH=$(git branch --show-current); REPORT_FILE="specs/${BRANCH}/reports/readiness_$(date +%Y%m%d-%H%M%S).md"`
2. **Collect**: Architecture, resources, git, testing, security, tokens, workarounds
3. **Generate**: Read template → Replace `{{PLACEHOLDERS}}` → Validate none remain → Write
4. **Output**: Display path, key metrics, critical issues

## Data Collection Sources

| Data          | Source                                 | Method                                                  |
| ------------- | -------------------------------------- | ------------------------------------------------------- |
| Architecture  | `specs/${BRANCH}/plan.md`              | Read file                                               |
| Resources     | `*.tf` files                           | Parse `resource` blocks, count by type                  |
| Git           | `git log`, `git diff`                  | Bash commands                                           |
| Testing       | `terraform test`, `terraform validate` | Bash, parse output                                      |
| HCP Terraform | MCP tools                              | `get_workspace_details`, `list_runs`, `get_run_details` |
| Security      | `trivy`, `tflint`, `vault-radar`       | Bash, parse JSON output                                 |
| Tokens        | Agent logs                             | Sum by phase                                            |
| Workarounds   | Code review                            | Distinguish tech debt vs fixes                          |

## Critical Report Sections

Target 300 lines maximum. Use tables over prose. Omit passing checks — report only findings, warnings, and metrics.

### Workarounds vs Fixes

Distinguish tech debt (workarounds) from resolved issues (fixes):

- **Workarounds**: What, why, impact, priority, effort for future fix
- **Fixes**: What was fixed, verification method

### Security Analysis

Categorize by severity (Critical/High/Medium/Low):

- File:line reference
- Status: Fixed / Workaround / Not Addressed
- Tool results: terraform validate, trivy, vault-radar

### Module Structure Compliance

- Standard module layout (root, examples/, tests/, modules/)
- Resource organization and naming conventions
- Provider version constraints (`>=` for modules)

## Template Location

Use `.foundations/templates/deployment-report-template.md` (module readiness report) as the canonical template.

## Validation Checklist

- ✓ No `{{PLACEHOLDER}}` remains (use "N/A" if unavailable)
- ✓ Workarounds documented with priority
- ✓ Security findings complete with severity
- ✓ Module structure compliance verified
- ✓ Testing results included (terraform test, validate, examples)
- ✓ File path displayed to user
