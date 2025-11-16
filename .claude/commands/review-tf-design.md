---
name: review-tf-design
description: Comprehensive review of spec artifacts and AWS infrastructure security using specialized subagents
---

# Terraform Design Review Command

**Role**: You are orchestrating a comprehensive multi-agent review of Terraform design documents.

**Purpose**: Validate specification quality, architectural decisions, and security posture BEFORE implementation.

**Position in Workflow**: After `/speckit.plan`, before `/speckit.tasks`

## Quick Start

```bash
/review-tf-design
```

Launches 3 concurrent reviews:
- 📋 Specification Quality (spec-quality-judge)
- 🔒 AWS Security Assessment (aws-security-advisor)
- 📐 Terraform Best Practices (code-quality-judge)

## Prerequisites

### Required Files
```yaml
required:
  - spec.md     # Feature specification
  - plan.md     # Technical design plan
validation_command: ".specify/scripts/bash/check-prerequisites.sh --json --require-spec"
expected_output:
  status: "ready"
  feature_dir: "${FEATURE_DIR}"
  files: ["spec.md", "plan.md"]
```

### Gate Criteria
```yaml
quality_gates:
  pass:
    spec_score: ">= 7.0"
    critical_issues: 0
    high_issues: "<= 2"
  conditional:
    spec_score: ">= 6.0"
    critical_issues: 0
    high_issues: "<= 5"
  fail:
    spec_score: "< 6.0"
    critical_issues: "> 0"
```

## Execution Strategy

### Parallel Review Architecture

**CRITICAL**: Execute all reviews simultaneously in a single message with multiple tool calls.

```python
# Execution pattern (pseudo-code)
parallel_reviews = [
    Task(subagent="spec-quality-judge", model="sonnet"),
    Task(subagent="aws-security-advisor", model="sonnet"),
    Task(subagent="code-quality-judge", model="sonnet")
]
results = execute_concurrent(parallel_reviews)
aggregate_findings(results)
```

**Performance**: ~60 seconds total (vs ~180 seconds sequential)

## Review Components

### 1️⃣ Specification Quality Review

**Agent**: `spec-quality-judge`
**Focus**: Requirements clarity and completeness

#### Evaluation Framework
```yaml
dimensions:
  clarity_completeness:
    weight: 0.25
    checks: ["unambiguous", "complete", "consistent"]
  testability:
    weight: 0.20
    checks: ["measurable", "verifiable", "bounded"]
  technology_agnostic:
    weight: 0.20
    checks: ["implementation_neutral", "flexible"]
  constitution_alignment:
    weight: 0.20
    checks: ["principles_followed", "patterns_applied"]
  user_centricity:
    weight: 0.15
    checks: ["value_clear", "user_focused"]
```

#### Agent Prompt Template
```markdown
ROLE: You are the spec-quality-judge agent evaluating specification quality.

CONTEXT:
- Current feature: Read from environment
- Specification location: spec.md in feature directory
- Constitution: .specify/constitution.md

TASK:
1. Load and analyze spec.md
2. Evaluate against 5 dimensions (weights provided)
3. Calculate weighted score (0-10)
4. Generate prioritized findings (P0-P3)
5. Provide specific line references
6. Suggest concrete improvements

OUTPUT:
- Format: JSONL
- Path: specs/{FEATURE}/evaluations/spec-reviews.jsonl
- Include: score, dimensions, findings, recommendations

DECISION LOGIC:
IF score >= 7.0: Mark as "production_ready"
IF score >= 6.0: Mark as "needs_refinement"
IF score < 6.0: Mark as "requires_rework"
```

### 2️⃣ AWS Security Review

**Agent**: `aws-security-advisor`
**Focus**: Infrastructure security in planned architecture

#### Security Assessment Areas
```yaml
assessment_areas:
  iam:
    priority: "critical"
    checks: ["least_privilege", "no_wildcards", "mfa_required"]
  data_protection:
    priority: "critical"
    checks: ["encryption_at_rest", "encryption_in_transit", "key_rotation"]
  network:
    priority: "high"
    checks: ["private_subnets", "security_groups", "nacls"]
  logging:
    priority: "high"
    checks: ["cloudtrail", "vpc_flow_logs", "s3_access_logs"]
  resilience:
    priority: "medium"
    checks: ["backups", "multi_az", "disaster_recovery"]
```

#### Agent Prompt Template
```markdown
ROLE: You are the aws-security-advisor agent assessing AWS infrastructure security.

CONTEXT:
- Reviewing: plan.md (design phase, no code yet)
- Framework: AWS Well-Architected Security Pillar
- Standards: CIS AWS Foundations Benchmark

TASK:
1. Analyze plan.md for AWS resources
2. Identify security risks by category
3. Rate each finding: [Critical|High|Medium|Low]
4. Provide remediation with code examples
5. Citation required for each finding

TOOLS:
- Use mcp__aws-knowledge-mcp-server__aws___search_documentation
- Use mcp__aws-knowledge-mcp-server__aws___read_documentation
- Verify current best practices

OUTPUT FORMAT:
For EACH finding provide:
- Risk: [Critical|High|Medium|Low]
- Finding: Clear issue description
- Impact: Exploitation consequences
- Remediation: Specific fix steps
- Example: Corrected configuration
- Citation: AWS documentation URL
- Effort: [Low|Medium|High]

SAVE TO: specs/{FEATURE}/evaluations/aws-security-review.md
```

### 3️⃣ Terraform Best Practices Review

**Agent**: `code-quality-judge`
**Focus**: Terraform patterns in design plan

#### Review Checklist
```yaml
terraform_patterns:
  modules:
    - "Module-first approach"
    - "Versioned module sources"
    - "Clear module boundaries"
  variables:
    - "Snake_case naming"
    - "Type constraints defined"
    - "Validation rules planned"
  organization:
    - "Standard file structure"
    - "Locals for DRY"
    - "Output strategy"
  state:
    - "Backend configuration"
    - "Workspace strategy"
```

#### Agent Prompt Template
```markdown
ROLE: You are evaluating Terraform design patterns in plan.md.

CONTEXT: Reviewing architectural plan (pre-implementation).

EVALUATE:
1. Module strategy and boundaries
2. Variable design patterns
3. File organization approach
4. State management plan
5. Provider configuration
6. Constitution alignment

OUTPUT:
- Priority: [High|Medium|Low] per finding
- Location: Section in plan.md
- Issue: Description
- Recommendation: Best practice
- Save to: specs/{FEATURE}/evaluations/terraform-best-practices-review.md
```

## Error Handling

### Failure Recovery Matrix

| Error Type | Detection | Recovery Action |
|------------|-----------|-----------------|
| Missing spec.md | File not found | Run `/speckit.specify` first |
| Missing plan.md | File not found | Run `/speckit.plan` first |
| Subagent timeout | >120s execution | Retry with focused scope |
| MCP tool error | API failure | Check credentials, retry |
| Parse error | Invalid JSON/YAML | Validate file format |

### Retry Strategy
```yaml
retry_policy:
  max_attempts: 2
  backoff: "exponential"
  individual_failures: "retry_specific_agent"
  systemic_failures: "check_environment"
```

## Output Aggregation

### Consolidated Report Template

```markdown
# Design Review Summary

**Feature**: {feature_name}
**Reviewed**: {iso_timestamp}
**Status**: {overall_gate_status}

## 📊 Review Dashboard

| Component | Status | Score/Rating | Action Required |
|-----------|--------|--------------|-----------------|
| Specification | {emoji} | {score}/10 | {blockers} |
| Security | {emoji} | {critical}/{high} | {blockers} |
| Best Practices | {emoji} | {high}/{medium} | {blockers} |

**Gate Decision**: [{PASS|CONDITIONAL|FAIL}]

## 🚨 Blocking Issues (P0)

{if_any_blocking_issues}
1. [{category}] {issue} → {action}
2. ...
{else}
✅ No blocking issues found
{endif}

## 📋 Review Details

<details>
<summary>Specification Quality</summary>

Score: {score}/10
Top findings: {top_3_only}
[Full Report](specs/{feature}/evaluations/spec-reviews.jsonl)

</details>

<details>
<summary>Security Assessment</summary>

Critical: {count}
High: {count}
[Full Report](specs/{feature}/evaluations/aws-security-review.md)

</details>

<details>
<summary>Terraform Patterns</summary>

Issues: {high_count} high, {medium_count} medium
[Full Report](specs/{feature}/evaluations/terraform-best-practices-review.md)

</details>

## ⏭️ Next Steps

{decision_tree}
IF status == "PASS":
  → Run `/speckit.implement`
ELIF status == "CONDITIONAL":
  → Review P1 issues
  → Run `/speckit.implement` with caution
ELSE:
  → Fix P0 issues
  → Re-run `/review-tf-design`
```

## Implementation Workflow

### Step 1: Validate Environment
```bash
# Check prerequisites
.specify/scripts/bash/check-prerequisites.sh --json --require-spec

# Parse response
if [[ "$status" != "ready" ]]; then
  echo "❌ Prerequisites not met: $missing_files"
  exit 1
fi
```

### Step 2: Launch Reviews
```python
# Single message, multiple tool calls
await Promise.all([
  Task({
    subagent_type: "spec-quality-judge",
    description: "Evaluate specification",
    model: "sonnet",
    prompt: SPEC_QUALITY_PROMPT
  }),
  Task({
    subagent_type: "aws-security-advisor",
    description: "Security assessment",
    model: "sonnet",
    prompt: AWS_SECURITY_PROMPT
  }),
  Task({
    subagent_type: "code-quality-judge",
    description: "Terraform patterns",
    model: "sonnet",
    prompt: TERRAFORM_PATTERNS_PROMPT
  })
])
```

### Step 3: Process Results
```python
# Aggregate findings
results = collect_all_reviews()
blocking_issues = filter(results, priority="P0")
overall_status = calculate_gate_status(results)

# Generate report
report = render_template(
  template="consolidated_report",
  data=results,
  status=overall_status
)

# Save artifacts
save_report(report, "specs/{feature}/evaluations/design-review-summary.md")
```

### Step 4: User Communication
```markdown
IF overall_status == "PASS":
  "✅ All reviews passed! Ready for implementation.
   Run `/speckit.implement` to generate Terraform code."

ELIF overall_status == "CONDITIONAL":
  "⚠️ Reviews passed with recommendations.
   {count} non-blocking issues found.
   Review details above before proceeding."

ELSE:
  "❌ Reviews identified blocking issues.
   {count} P0 issues must be resolved.
   Fix issues and re-run `/review-tf-design`."
```

## Customization Options

### Profile Configurations
```yaml
profiles:
  strict:
    spec_min_score: 8.0
    allow_high_security: false
    allow_medium_security: false

  standard:
    spec_min_score: 7.0
    allow_high_security: true
    allow_medium_security: true

  permissive:
    spec_min_score: 6.0
    allow_high_security: true
    allow_medium_security: true
```

### Provider Adaptations
```yaml
security_advisors:
  aws: "aws-security-advisor"
  gcp: "gcp-security-advisor"
  azure: "azure-security-advisor"
  multi_cloud: ["aws-security-advisor", "gcp-security-advisor"]
```

## Success Metrics

### Performance SLAs
- Total execution: < 90 seconds
- Individual review: < 60 seconds
- Report generation: < 10 seconds

### Quality Targets
- Spec correlation with human review: > 0.80
- Security finding accuracy: > 95%
- False positive rate: < 10%

## Appendix: Full Prompt Templates

Full prompt templates are maintained in:
- `.claude/agents/spec-quality-judge.md`
- `.claude/agents/aws-security-advisor.md`
- `.claude/agents/code-quality-judge.md`

---

$ARGUMENTS