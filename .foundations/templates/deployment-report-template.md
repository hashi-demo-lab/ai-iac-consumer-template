<!-- Placeholder convention: [BRACKETS] = human-authored content (instructions, descriptions).
     {{DOUBLE_BRACES}} = machine-filled values (timestamps, scores, IDs). -->

# Terraform Module Readiness Report

**Feature**: `{{FEATURE_NAME}}`
**Branch**: `{{GIT_BRANCH}}`
**Evaluated**: `{{TIMESTAMP}}`
**Readiness Status**: {{READINESS_STATUS}}

---

## Executive Summary

### Module Readiness Overview

{{READINESS_OVERVIEW}}

### Readiness Outcome

| Metric | Value |
|--------|-------|
| **Status** | {{STATUS_BADGE}} |
| **Module Resources** | {{RESOURCE_COUNT}} resources managed |
| **Test Duration** | {{TEST_DURATION}} |
| **Total Cost Estimate** | {{COST_ESTIMATE}} |
| **Compliance Status** | {{COMPLIANCE_STATUS}} |

{{STATUS_BADGE}} options:
- ✅ **Module Ready for Publishing**
- ⚠️ **Ready with Warnings**
- ❌ **Not Ready - Issues Found**
- 🔄 **Partially Complete**

---

## Architecture Summary

### Infrastructure Overview

{{ARCHITECTURE_DESCRIPTION}}

### Architecture Diagram

```
{{ARCHITECTURE_DIAGRAM}}
```

### Key Components

{{KEY_COMPONENTS_TABLE}}

---

## Resources Created

### Resource Inventory

| Resource Type | Logical Name | Purpose | Conditional |
|---------------|-------------|---------|-------------|
{{RESOURCES_CREATED_TABLE}}

### Provider Dependencies

| Provider | Version Constraint | Source |
|----------|-------------------|--------|
{{PROVIDERS_TABLE}}

---

## Git & Version Control

### Repository Information

| Attribute | Value |
|-----------|-------|
| **Feature Branch** | `{{GIT_BRANCH}}` |
| **Base Branch** | `{{BASE_BRANCH}}` |
| **Commit SHA** | `{{COMMIT_SHA}}` |
| **Author** | {{GIT_AUTHOR}} |
| **Commits in Branch** | {{COMMIT_COUNT}} |
| **Files Changed** | {{FILES_CHANGED}} |
| **Lines Added/Removed** | +{{LINES_ADDED}} / -{{LINES_REMOVED}} |

### Pull Request

| Attribute | Value |
|-----------|-------|
| **PR Number** | {{PR_NUMBER}} |
| **PR Status** | {{PR_STATUS}} |
| **PR URL** | {{PR_URL}} |
| **Reviewers** | {{REVIEWERS}} |

---

## Module Testing Results

### terraform test Results

| Test File | Status | Tests Passed | Tests Failed | Duration |
|-----------|--------|-------------|-------------|----------|
{{TERRAFORM_TEST_RESULTS_TABLE}}

**Total**: {{TOTAL_TESTS_PASSED}} passed, {{TOTAL_TESTS_FAILED}} failed

### Example Plan/Apply Results

| Example | Plan Status | Resources | Apply Status | Destroy Status |
|---------|-------------|-----------|-------------|----------------|
| `examples/basic/` | {{BASIC_PLAN_STATUS}} | {{BASIC_RESOURCE_COUNT}} | {{BASIC_APPLY_STATUS}} | {{BASIC_DESTROY_STATUS}} |
| `examples/complete/` | {{COMPLETE_PLAN_STATUS}} | {{COMPLETE_RESOURCE_COUNT}} | {{COMPLETE_APPLY_STATUS}} | {{COMPLETE_DESTROY_STATUS}} |

### Validation Results

| Check | Status | Details |
|-------|--------|---------|
| **terraform validate** | {{VALIDATE_STATUS}} | {{VALIDATE_DETAILS}} |
| **terraform fmt -check** | {{FMT_STATUS}} | {{FMT_DETAILS}} |
| **tflint** | {{TFLINT_STATUS}} | {{TFLINT_DETAILS}} |
| **Pre-commit Hooks** | {{PRECOMMIT_STATUS}} | {{PRECOMMIT_DETAILS}} |

---

## Resource Utilization Metrics

### Claude AI Token Usage

| Metric | Value |
|--------|-------|
| **Total Tokens Consumed** | {{TOTAL_TOKENS}} tokens |
| **Input Tokens** | {{INPUT_TOKENS}} tokens |
| **Output Tokens** | {{OUTPUT_TOKENS}} tokens |
| **Cache Read Tokens** | {{CACHE_READ_TOKENS}} tokens |
| **Cache Write Tokens** | {{CACHE_WRITE_TOKENS}} tokens |
| **Estimated Cost** | {{ESTIMATED_COST}} |
| **Session Duration** | {{SESSION_DURATION}} |

### Agent & Tool Invocations

#### Subagent Calls

| Subagent | Invocations | Purpose | Outcome |
|----------|-------------|---------|---------|
{{SUBAGENT_TABLE}}

**Total Subagent Calls**: {{TOTAL_SUBAGENTS}}

#### Skills Invoked

| Skill | Invocations | Purpose | Outcome |
|-------|-------------|---------|---------|
{{SKILLS_TABLE}}

**Total Skill Calls**: {{TOTAL_SKILLS}}

#### Tool Call Statistics

| Tool Category | Successful Calls | Failed Calls | Total |
|---------------|------------------|--------------|-------|
| **MCP Tools** | {{MCP_SUCCESS}} | {{MCP_FAILED}} | {{MCP_TOTAL}} |
| **Bash Commands** | {{BASH_SUCCESS}} | {{BASH_FAILED}} | {{BASH_TOTAL}} |
| **File Operations** | {{FILE_SUCCESS}} | {{FILE_FAILED}} | {{FILE_TOTAL}} |
| **Terraform Operations** | {{TF_SUCCESS}} | {{TF_FAILED}} | {{TF_TOTAL}} |
| **Git Operations** | {{GIT_SUCCESS}} | {{GIT_FAILED}} | {{GIT_TOTAL}} |

---

## Failed Tool Calls & Remediations

### Summary

| Status | Count |
|--------|-------|
| **Total Failed Calls** | {{FAILED_TOTAL}} |
| **Successfully Remediated** | {{REMEDIATED_COUNT}} |
| **Unresolved** | {{UNRESOLVED_COUNT}} |

### Detailed Failure Log

{{FAILED_CALLS_TABLE}}

---

## Workarounds vs Fixes

### Critical Distinction

This section documents issues that were **worked around** rather than **properly fixed**. These require future attention.

### Workarounds Implemented

| Issue ID | Description | Workaround Applied | Why Workaround Chosen | Future Fix Required | Priority |
|----------|-------------|-------------------|----------------------|---------------------|----------|
{{WORKAROUNDS_TABLE}}

### Issues Properly Fixed

| Issue ID | Description | Fix Applied | Verification Method |
|----------|-------------|-------------|---------------------|
{{FIXES_TABLE}}

**Total Workarounds**: {{WORKAROUND_COUNT}} ⚠️
**Total Proper Fixes**: {{FIX_COUNT}} ✅

---

## Security Analysis

### Security Posture Summary

| Metric | Value |
|--------|-------|
| **Overall Security Score** | {{SECURITY_SCORE}}/10 |
| **Critical Vulnerabilities** | {{CRITICAL_VULNS}} |
| **High Severity Issues** | {{HIGH_VULNS}} |
| **Medium Severity Issues** | {{MEDIUM_VULNS}} |
| **Low Severity Issues** | {{LOW_VULNS}} |
| **Security Tool Compliance** | {{SECURITY_COMPLIANCE}}% |

### Pre-Commit Security Reports

#### terraform validate

| Status | Errors | Warnings | Details |
|--------|--------|----------|---------|
| {{VALIDATE_STATUS}} | {{VALIDATE_ERRORS}} | {{VALIDATE_WARNINGS}} | {{VALIDATE_DETAILS}} |

**Output**:
```
{{VALIDATE_OUTPUT}}
```

#### trivy

| Status | Critical | High | Medium | Low | Total Issues |
|--------|----------|------|--------|-----|--------------|
| {{TRIVY_STATUS}} | {{TRIVY_CRITICAL}} | {{TRIVY_HIGH}} | {{TRIVY_MEDIUM}} | {{TRIVY_LOW}} | {{TRIVY_TOTAL}} |

**Key Findings**:
{{TRIVY_FINDINGS}}

### Security Recommendations

{{SECURITY_RECOMMENDATIONS}}

---

## Pre-Commit & Validation Compliance

### Validation Tool Results

| Tool | Status | Findings | Details |
|------|--------|----------|---------|
| terraform validate | {{VALIDATE_TOOL_STATUS}} | {{VALIDATE_TOOL_FINDINGS}} | {{VALIDATE_TOOL_DETAILS}} |
| terraform fmt | {{FMT_TOOL_STATUS}} | {{FMT_TOOL_FINDINGS}} | {{FMT_TOOL_DETAILS}} |
| tflint | {{TFLINT_TOOL_STATUS}} | {{TFLINT_TOOL_FINDINGS}} | {{TFLINT_TOOL_DETAILS}} |
| trivy | {{TRIVY_TOOL_STATUS}} | {{TRIVY_TOOL_FINDINGS}} | {{TRIVY_TOOL_DETAILS}} |

### Compliance Status

| Metric | Value |
|--------|-------|
| **Total Checks Run** | {{CHECK_TOTAL}} |
| **Checks Passed** | {{CHECK_PASSED}} |
| **Warnings** | {{CHECK_WARNINGS}} |
| **Failures** | {{CHECK_FAILED}} |
| **Compliance Rate** | {{CHECK_COMPLIANCE}}% |

---

## Development Timeline

### Execution Phases

| Phase | Start Time | End Time | Duration | Status | Notes |
|-------|------------|----------|----------|--------|-------|
{{TIMELINE_TABLE}}

### Critical Events

{{CRITICAL_EVENTS}}

---

## Module Resources

### Resources Managed by Module

| Resource Type | Resource Name | Identifier | Status |
|---------------|---------------|------------|--------|
{{RESOURCES_TABLE}}

### Terraform Outputs

```hcl
{{TERRAFORM_OUTPUTS}}
```

### Output Values

| Output Name | Value | Sensitive | Description |
|-------------|-------|-----------|-------------|
{{OUTPUTS_TABLE}}

---

## Cost Analysis

### Estimated Monthly Costs

| Service | Resource Count | Estimated Cost | Notes |
|---------|----------------|----------------|-------|
{{COST_BREAKDOWN_TABLE}}

**Total Estimated Monthly Cost**: {{TOTAL_MONTHLY_COST}}

### Cost Optimization Recommendations

{{COST_OPTIMIZATION}}

---

## Lessons Learned

### What Went Well ✅

{{LESSONS_SUCCESS}}

### Challenges Encountered ⚠️

{{LESSONS_CHALLENGES}}

### Improvements for Next Time 💡

{{LESSONS_IMPROVEMENTS}}

---

## Next Steps

### Immediate Actions Required

{{NEXT_IMMEDIATE}}

### Follow-up Tasks

{{NEXT_FOLLOWUP}}

### Future Enhancements

{{NEXT_ENHANCEMENTS}}

---

## Appendix

### A. Test Logs

#### terraform test Output

```
{{TERRAFORM_TEST_LOG}}
```

#### Terraform Plan Output (examples/basic)

```
{{TERRAFORM_PLAN_OUTPUT_BASIC}}
```

#### Terraform Plan Output (examples/complete)

```
{{TERRAFORM_PLAN_OUTPUT_COMPLETE}}
```

### B. Configuration Files

#### Example terraform.tfvars (basic)

```hcl
{{BASIC_TFVARS}}
```

#### Example terraform.tfvars (complete)

```hcl
{{COMPLETE_TFVARS}}
```

### C. Error Messages & Stack Traces

{{ERROR_LOGS}}

### D. Environment Variables

```bash
{{ENV_VARS}}
```

---

## Report Metadata

| Attribute | Value |
|-----------|-------|
| **Report Generated** | {{GENERATION_TIMESTAMP}} |
| **Report Version** | {{REPORT_VERSION}} |
| **Generated By** | Claude Code ({{MODEL_VERSION}}) |
| **Report ID** | `{{REPORT_ID}}` |
| **Feature Directory** | `{{FEATURE_DIR}}` |
| **Report Location** | `{{REPORT_PATH}}` |
| **Module Name** | {{MODULE_NAME}} |
| **Terraform Version** | {{TF_VERSION}} |

---

**Module Readiness Report Complete**

This report provides a comprehensive overview of the Terraform module development process, including all test results, security analysis, and readiness assessment. Use this document for audit trails, quality verification, and publishing decisions.

**Document Status**: {{DOC_STATUS}}
**Next Review Date**: {{NEXT_REVIEW}}
**Document Owner**: {{DOC_OWNER}}
