---
name: tf-consistency-rules
description: Cross-artifact traceability rules for spec-to-plan-to-tasks coverage analysis. Use when validating cross-artifact consistency, detecting orphan requirements, or identifying terminology drift between spec, plan, and tasks.
---

# Cross-Artifact Consistency Rules

## Detection Passes

### A. Duplication Detection
- Near-duplicate requirements across artifacts
- Mark lower-quality phrasing for consolidation

### B. Ambiguity Detection
- Vague adjectives without metrics: "fast", "scalable", "secure", "intuitive", "robust"
- Unresolved placeholders: TODO, TKTK, ???, `<placeholder>`

### C. Underspecification
- Requirements with verbs but missing object or measurable outcome
- User stories missing acceptance criteria alignment
- Tasks referencing files/components not in spec/plan

### D. Constitution Alignment (Structural Only)
- File organization violations (3.2): missing required files, wrong directory structure
- Naming convention violations (3.3): resources, variables, outputs not following conventions
- Variable management violations (3.4): missing descriptions, wrong types, no validation
- Module usage pattern violations (3.5): inline resources where modules are mandated
- Workspace management violations (5.1): missing backend config, wrong workspace structure
- Dependency management violations (7.2): unpinned versions, missing lock files
- Missing mandated artifact sections or quality gates

> **Exclusion**: Pass D does NOT evaluate security posture, compliance, or AWS best practices — that is the domain of `aws-security-advisor`. Pass D does NOT prescribe workflow steps or which agents to run — that is the orchestrator's domain. Pass D only checks that artifacts conform to the constitution's structural and process requirements.

### E. Coverage Gaps
- Requirements with zero associated tasks
- Tasks with no mapped requirement/story
- Non-functional requirements not reflected in tasks

### F. Inconsistency
- Terminology drift (same concept named differently)
- Data entities in plan but absent in spec (or vice versa)
- Task ordering contradictions without dependency notes
- Conflicting requirements

### G. Research-Plan Alignment
- Plan decisions contradicting research conclusions
- Research security considerations not reflected in plan or spec

## Examples

**Terminology drift (Pass F)**:
- Spec says `database_subnet_group`, plan says `db_subnet_group`, tasks say `rds_subnet_group` — same concept, three names. Consolidate to one term across all artifacts.

**Orphan requirement (Pass E)**:
- Spec requires "All S3 buckets must enable versioning" but no task in `tasks.md` implements or verifies bucket versioning. Flag as coverage gap and add a task.

**Ambiguity (Pass B)**:
- Bad: "The module should be fast and scalable"
- Good: "The module must support up to 50 subnets per VPC with plan time under 30 seconds"
