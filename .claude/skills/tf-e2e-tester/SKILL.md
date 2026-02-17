---
name: tf-e2e-tester
description: "Non-interactive test harness for end-to-end Terraform workflow testing. Runs full `/tf-plan` → `/tf-implement` cycle with test defaults, bypassing user prompts for automated validation. Pass the prompt filename as the skill argument."
---

# E2E Test Orchestrator

## Workflow

Execute phases sequentially. Before and after each subagent run: post progress to the gh issue. After each subagent run: commit its output to git.

```
bash .foundations/scripts/bash/post-issue-progress.sh $ISSUE_NUMBER "<step>" "<status>" "<summary>" "$DETAILS"
```

## E2E Overrides

These overrides replace interactive prompts with test defaults:

| Override        | Behavior                                                       |
| --------------- | -------------------------------------------------------------- |
| Requirements    | Read from `.claude/skills/tf-e2e-tester/prompts/<prompt-file>` |
| AskUserQuestion | Use test defaults, do not prompt                               |
| Approval gates  | Auto-approve, do not wait                                      |
| Destroy sandbox | Always yes                                                     |
| Create PR       | No, test artifacts stay on branch                              |

---

## PART 1: PLANNING

Follow `/tf-plan` skill phases 1-5 with these E2E-specific differences:

- **Phase 1 Setup**: Read requirements from `.claude/skills/tf-e2e-tester/prompts/<prompt-file>` instead of gathering from user. Create test issue with `test:e2e` label:
  ```bash
  gh issue create --title "E2E Test: <prompt-file>" --label "test:e2e" --body "$(cat .claude/skills/tf-e2e-tester/prompts/<prompt-file>)"
  ```
- **Phase 2 Specification**: sdd-clarify uses test defaults for HIGH-impact gaps; do not use `AskUserQuestion`
- **Phase 5 Summary**: Do NOT add `agent:awaiting-review` label. Do NOT stop for approval. Proceed directly to implementation.

---

## PART 2: IMPLEMENTATION

Follow `/tf-implement` skill phases 1-6 with these E2E-specific differences:

- **Phase 1 Prerequisites**: Use issue number from Part 1
- **Phase 2 Implementation**: Commit messages use `test(e2e): implement phase N - <description>`
- **Phase 6 Cleanup**: git push (do NOT create PR). Optionally destroy sandbox resources. Close issue with `test:passed` or `test:failed` label.

Display: > E2E test complete. Status: [PASSED|FAILED]. See issue #<number> for details.
