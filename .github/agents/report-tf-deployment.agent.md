---
name: report-tf-deployment
description: Perform a non-destructive cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md after task generation.
tools: ["edit", "search", "runCommands", "fetch", "runTasks", "runSubagent", "problems", "terraform-mcp-server/get_run_details", "terraform-mcp-server/get_workspace_details", "terraform-mcp-server/list_runs", "terraform-mcp-server/list_terraform_orgs", "terraform-mcp-server/list_terraform_projects", "terraform-mcp-server/list_variable_sets", "terraform-mcp-server/list_workspace_variables", "terraform-mcp-server/list_workspaces", "terraform-mcp-server/search_private_providers", "terraform-mcp-server/search_providers", "terraform-mcp-server/create_run", "terraform-mcp-server/search_private_modules"]
color: purple
---

# Generate Terraform Deployment Report

Create a comprehensive deployment report using the template at `/workspace/.specify/templates/deployment-report-template.md`.

## Setup

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
REPORT_DIR="/workspace/specs/${BRANCH}/reports"
mkdir -p "${REPORT_DIR}"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="${REPORT_DIR}/deployment_report_${TIMESTAMP}.md"
```

## Data Collection

**Architecture**: Read `specs/${BRANCH}/plan.md`, summarize components and diagram

**HCP Terraform**: Org/project/workspace names, workspace URL, configuration details

**Modules**: Parse `*.tf` for sources, distinguish private vs public, include versions and justifications

**Git**: Branch, commit SHA, author, files changed, lines +/-, PR info

**Agent Token Usage**: extract totals and breakdown across all phases

**AI Agent Tool Calls**: Review Tool calls stats and failures, document remediations, categorize by type

**Agents**: List all subagent calls (speckit.*, code-quality-judge, etc.) and skills with purpose/outcome

**Workarounds vs Fixes**: CRITICAL - itemize what was worked around vs fixed, explain why, prioritize future fixes

**Security**: Collect results from:
- `trivy config .`
- `tflint`
- `vault-radar-scan .`
Categorize by severity, document remediation status

**Sentinel**: Query workspace for policy results, document advisories and failures

## Output

1. Read template, replace all `{{PLACEHOLDERS}}` with actual data
2. Use "N/A" if data unavailable - DO NOT GUESS
3. Use tables for structured data, code blocks for logs
4. Write to `${REPORT_FILE}`
5. Display: file path, key metrics (tokens, resources, security score), critical issues, next steps

## Success Criteria

- All required sections populated
- No `{{PLACEHOLDER}}` variables remain
- Workarounds vs fixes clearly distinguished
- Security scans fully documented
- Token/tool statistics accurate
- Proper markdown formatting
