---
name: tf-module-plan
description: Planning orchestrator for Terraform module development. Drives spec-driven development from requirements intake through specification, clarification, planning, review, tasks, and analysis. Entry point for the planning workflow.
---

# Planning Orchestrator

Execute phases sequentially. Complete each before proceeding. All artifacts land in `specs/{FEATURE}/`.

Before and after each subagent run, post progress to the gh issue:

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
4. Gather requirements from the user using `.github/ISSUE_TEMPLATE/terraform-module-requirements.yml` as a guide. Focus on: what the module should create, what features it should support, what provider(s), and what the interface should look like (key inputs/outputs).

### Phase 2 — Specification

1. Run sdd-specify subagent with the captured requirements. Verify `specs/{FEATURE}/spec.md` exists.
2. Run sdd-checklist subagent with FEATURE path. Verify `specs/{FEATURE}/checklist/*.md` files exist.
3. Run sdd-clarify subagent with FEATURE path.

### Phase 3 — Research + Planning

1. Run multiple sdd-research subagents in parallel — one per research question, each with FEATURE path. Verify `specs/{FEATURE}/research/research-*.md` files exist.
   1b. **Back-propagate**: Scan research files for security considerations or best practices not in spec.md. Update spec.md with new FR- entries before plan drafting.
2. Run sdd-plan-draft subagent with FEATURE path. Verify `specs/{FEATURE}/plan.md` exists.

### Phase 4 — Security Review

1. Run aws-security-advisor subagent with FEATURE path. Verify `specs/{FEATURE}/reports/security-review.md` exists.
2. Grep `specs/{FEATURE}/reports/security-review.md` for `Critical` severity. If Critical findings exist, flag to user before proceeding. If any findings require new FRs in spec.md, also update plan.md architectural decisions, contracts/module-interfaces.md variable/output tables, and contracts/data-model.md entity list before proceeding to Phase 5.

### Phase 5 — Tasks Generation

1. Run sdd-tasks subagent with FEATURE path. Verify `specs/{FEATURE}/tasks.md` exists.

### Phase 6 — Analysis + Remediation

Max **3 iterations**: 0. Systematically resolve every item in `checklists/*.md`: mark answered items `[x]` with a one-line rationale, mark items exposing gaps as `[!]` with the gap noted. All items must be resolved before running sdd-analyze.

1. Run sdd-analyze subagent with FEATURE path. Verify `specs/{FEATURE}/evaluations/consistency-analysis.md` exists.
2. If no Critical, High or Medium findings → proceed to Phase 7.
3. If Critical, High or Medium findings exist:
   a. Fix ALL source artifacts holistically: spec.md, plan.md, tasks.md, contracts/module-interfaces.md, and contracts/data-model.md. For each fix, trace the change through all five artifacts.
   b. Log fixes to `specs/{FEATURE}/evaluations/remediation-log.md` using `.foundations/templates/remediation-log-template.md`.
   c. Re-run sdd-analyze to verify. If Critical, High or Medium findings remain after iteration 3, stop and flag to user.

### Phase 7 — Summary + Approval

1. Compile results, post to GitHub issue, add agent:awaiting-review label.
2. The summary must include:
   - Analysis iteration count (e.g., "3 iterations, final run: 0 Critical, 1 Medium")
   - Link to `remediation-log.md` if any fixes were applied
   - Final finding counts come from the **last sdd-analyze run**, not orchestrator self-assessment

Display: > Planning is complete. Please review the artifacts in `specs/<branch>/` and approve before proceeding to implementation. Run `/tf-implement` when ready.
