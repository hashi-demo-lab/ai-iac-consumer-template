---
name: tf-compound-patterns
description: >
  Pattern extraction heuristics, pitfall recording format, and compound memory
  directory structure for capturing learnings from Terraform workflows.
  Use when extracting patterns, recording pitfalls, or capturing learnings from
  completed Terraform workflow runs.
---

# Compound Engineering Patterns for Terraform

## Core Principle

Each completed workflow run should leave the system better prepared for the next. Knowledge compounds — small, consistent investments in knowledge capture accumulate into exponential productivity gains.

## Memory Directory Structure

```
.foundations/memory/
├── patterns/
│   ├── modules/        # Which module combinations work well together
│   └── architecture/   # Proven architecture templates
├── pitfalls/           # Common mistakes and their resolutions
└── reviews/            # Recurring review issues across runs
```

## Pattern Extraction Heuristics

When extracting patterns from a completed workflow:

1. **Module Combinations**: Which modules were used together? What inputs connected them?
2. **Architecture Decisions**: What structure was chosen? Why? What alternatives were considered?
3. **Variable Patterns**: What validation rules proved useful? What defaults worked well?
4. **Security Patterns**: What security controls were applied? What was the reviewer's assessment?
5. **Testing Patterns**: What test strategies worked? What edge cases were discovered?

### Pattern File Format

```markdown
# Pattern: [Descriptive Name]

**Created**: [Date]
**Feature**: [Feature branch/name]
**Confidence**: [High|Medium|Low] (based on review scores and deployment success)

## Context
[When to use this pattern]

## Module Combination
[List of modules used together with version constraints]

## Key Configuration
[Important settings and their rationale]

## Lessons Learned
[What worked well, what to watch out for]
```

## Pitfall Recording Format

```markdown
# Pitfall: [Short Description]

**Discovered**: [Date]
**Feature**: [Feature branch/name]
**Severity**: [Critical|High|Medium|Low]
**Phase**: [Planning|Implementation|Testing|Deployment]

## Symptoms
[What went wrong — observable behavior]

## Root Cause
[Why it happened]

## Resolution
[How it was fixed]

## Prevention
[How to avoid this in future — checklist items, validation rules, etc.]

## Related
[Links to patterns, other pitfalls, or documentation]
```

## AGENTS.md Update Patterns

When updating AGENTS.md files:
- Add implementation details discovered during the workflow
- Document debugging insights and architectural patterns
- Record dependency relationships between components
- Note common pitfalls specific to the component area
- Keep updates minimal and high-signal — no noise

## Constitution Review Patterns

When reviewing constitution alignment:
- Identify gaps where the constitution didn't cover a scenario
- Note principles that were too strict or too loose
- Suggest new MUST/SHOULD/MAY rules based on experience
- Document exceptions that were needed and why

## Template Improvement Patterns

When assessing templates:
- Identify sections consistently skipped → consider making optional
- Identify information consistently added → consider making a section
- Note formatting issues that caused friction
- Suggest reordering based on actual workflow

## Compound Phase Triggers

Run outcome is determined by `deploy_status` from tf-implement Step 4a:
- `RUN_SUCCESS` = (`deploy_status == "success"`)

| Agent | Runs when | Receives |
|-------|-----------|----------|
| `compound-pattern-extractor` | `RUN_SUCCESS` only | deploy_status, feature dir, report path |
| `compound-pitfall-recorder` | Always | deploy_status, feature dir, `failure: true` if `!RUN_SUCCESS` |
| `compound-agents-updater` | `RUN_SUCCESS` only | feature dir |
| `compound-constitution-reviewer` | Review flagged constitution issues | feature dir, review findings |
| `compound-template-improver` | Template deviations detected | feature dir, template paths |

- **Auto-commit**: `bash .foundations/scripts/bash/checkpoint-commit.sh --dir .foundations/memory/ --prefix compound "learnings"`
- **Best-effort**: Compound failures don't block the workflow
