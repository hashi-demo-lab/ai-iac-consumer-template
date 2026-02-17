---
name: tf-implement
description: Implementation orchestrator for Terraform module development. Drives task execution, testing, reporting, and compound learning capture. Entry point for the implementation workflow.
---

# Implementation Orchestrator

## Context Management (CRITICAL)

1. **NEVER call TaskOutput** to read subagent results. All agents write artifacts to disk — reading them back into the orchestrator bloats context and triggers compaction.
2. **Verify completion via Glob or Grep** — do NOT read full file contents into the orchestrator.
3. **Task executors**: Run as **parallel foreground Task calls** (NOT `run_in_background`). Launch all independent task executors in a single message.
4. **Quality/report agents**: Verify output file exists via Glob, then Grep for severity keywords (e.g., `Critical`, `FAIL`) — do NOT read full report contents.
5. **Minimal $ARGUMENTS**: Only pass the FEATURE path + task scope. Never inject file contents.

### Expected Output Files

| Phase | Agent | Output Path | Verification |
|-------|-------|-------------|--------------|
| 2 | tf-task-executor | Module files + `tasks.md` updated | Grep `tasks.md` for `[X]` marks |
| 4 | code-quality-judge | `specs/{FEATURE}/reports/quality-*.md` | Glob for report file, Grep for `Critical` |
| 5 | tf-report-generator | `specs/{FEATURE}/reports/readiness_*.md` | Glob for report file |

## Workflow Steps

- Execute phases sequentially. Post progress to GH issue before/after each subagent. Commit outputs after each subagent.
- use the following template for gh issues:

```
bash .foundations/scripts/bash/post-issue-progress.sh $ISSUE_NUMBER "<step>" "<status>" "<summary>" "$DETAILS"
```

### example

```
bash .foundations/scripts/bash/post-issue-progress.sh $ISSUE_NUMBER "Implementation" "started"
bash .foundations/scripts/bash/post-issue-progress.sh $ISSUE_NUMBER "Implementation" "complete" $DETAILS
```

### Phase 1 — Prerequisites

1. Resolve feature directory: `FEATURE_DIR="specs/$(git rev-parse --abbrev-ref HEAD)"`
2. Run validate-env.sh
3. Get issue number from GitHub (search for issue linked to branch or ask user)
4. Verify artifacts exist: `spec.md`, `plan.md`, `tasks.md`

### Phase 2 — Implementation

1. Launch multiple concurrent tf-task-executor subagents as **parallel foreground Task calls in a single message**. Each gets FEATURE path + task scope.
2. Verify completion by Grep on `specs/{FEATURE}/tasks.md` for `[X]` marks — do NOT call TaskOutput to read executor results.
3. This includes writing module resources, variables, outputs, tests, and examples.

### Phase 3 — Testing

1. Run `terraform fmt -check` and `terraform validate` on root module
2. Run `terraform test` to execute all `.tftest.hcl` files
3. Verify examples plan successfully: `cd examples/basic && terraform init && terraform plan`
4. If tests fail, fix issues and re-run

### Phase 4 — Quality Review

1. Run `code-quality-judge` subagent with FEATURE path. Verify `specs/{FEATURE}/reports/quality-*.md` exists via Glob — do NOT read full report.
2. Grep the quality report for `Critical` — flag to user if Critical findings exist.

### Phase 5 — Report

1. Run `tf-report-generator` subagent with FEATURE path. Verify `specs/{FEATURE}/reports/readiness_*.md` exists via Glob — do NOT read full report.
2. Gate: report must exist at `specs/{FEATURE}/reports/readiness_*.md`.

### Phase 6 — Cleanup + PR

1. `git push` and create PR with `gh pr create` linking to issue
2. Post completion comment to issue with PR link
3. Optionally: deploy examples to sandbox workspace for integration testing via `tf-deployer`

Display: > Implementation complete. PR created and artifacts available in `specs/<branch>/`. Review the readiness report for details.
