---
name: tf-consumer-plan
description: Planning orchestrator for Terraform infrastructure provisioning. Drives spec-driven development from requirements intake through specification, clarification, planning, review, tasks, and analysis.Entry point for the planning workflow.
---

# Planning Orchestrator

## Workflow Steps

- Execute the phases sequentially. Do not move ahead until the step previous has completed.
- Before and after each subagent run: post progress to the gh issue.
- use the following template for gh issues:

```
bash .foundations/scripts/bash/post-issue-progress.sh $ISSUE_NUMBER "<step>" "<status>" "<summary>" "$DETAILS"
```

### example

```
bash .foundations/scripts/bash/post-issue-progress.sh $ISSUE_NUMBER "Research" "started"
bash .foundations/scripts/bash/post-issue-progress.sh $ISSUE_NUMBER "Research" "complete" $DETAILS
```

### Phase 1 — Setup

1. Run validate-env.sh
2. Check for error and stop if pre-requisites not met
3. Then call MCP `list_terraform_orgs` to verify TFE_TOKEN.
4. Gather requirements from the user using `.github/ISSUE_TEMPLATE/terraform-agent-provisioning.yml` as a guide. Cover required fields first, then ask about optional sections (network, monitoring, backup/DR, cost, tags)

### Phase 2 — Specification

1. run sdd-specify subagent with the captured requirements, creates spec.md
2. run sdd-checklist subagent against `spec.md`
3. run sdd-clarify subagent — pass `checklist` directory findings as input alongside `spec.md`. Use `AskUserQuestion` for any HIGH-impact gaps not covered during requirements intake

### Phase 3 — Research + Planning

1. run mutiple concurrent sdd-research subagents (parallel)
2. run mutiple concurrent sdd-plan-draft subagents to produce, creates `plan.md, data-model.md`, `contracts/module-interfaces.md`

### Phase 4 — Tasks + Analysis

1. Run mutiple concurrent sdd-tasks subagents, creates `tasks.md`
2. Run mutiple concurrent sdd-analyze subagents in parallel. pass in `tasks.md` creates`analysis.md`

### Phase 5 — Summary + Approval

1. Compile results, post to GitHub issue, add agent:awaiting-review label.

Display: > Planning is complete. Please review the artifacts in `specs/<branch>/` and approve before proceeding to implementation. Run `/tf-implement` when ready.
