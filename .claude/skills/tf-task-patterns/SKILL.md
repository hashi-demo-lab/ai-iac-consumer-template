---
name: tf-task-patterns
description: Task breakdown format and phase organization for Terraform module development. Use when generating tasks.md from plan.md, organizing implementation phases, or mapping requirements to task checklists.
---

# Task Breakdown Patterns

Transform plan.md into dependency-ordered, checklist-format tasks organized by implementation phase. The tf-implement orchestrator passes phases to tf-task-executor subagents.

## Workflow

1. **Extract**: Pull user stories, resources, data model, infrastructure from plan.md and spec.md
2. **Map requirements**: Build coverage matrix linking requirements → tasks
3. **Assign phases**: Setup → Foundational → User Stories (priority order) → Testing → Polish
4. **Order tasks**: Sequential T001, T002... respecting dependencies
5. **Label stories**: Add `[US#]` labels only in story phases
6. **Generate sections**: Header, matrix, phases, dependencies, strategy, checklist, summary

## Output

- **Location**: `tasks.md` in feature directory
- **Format**: Markdown checklist with phase headers

### Required Sections

| Section | Purpose |
|---------|---------|
| Header | Feature name, input path, prerequisites, tests stance, organization note |
| Format explanation | `[ID] [Story] Description` with sequential execution note |
| Requirements Coverage Matrix | Requirement → Task(s) → Description traceability |
| Phase sections | Grouped tasks with purpose, checkpoints, and dependency notes |
| Dependencies & Execution Order | Phase deps, story deps, cross-resource data flow table |
| Implementation Strategy | MVP first, incremental delivery approach |
| File Checklist | File → Task → Purpose mapping |
| Task Summary | Single line: "**Total Tasks**: N" at end. |

## Constraints

- Every task: `- [ ] T### [US#?] Description with file path`
- Include checkpoint markers after each phase
- Document circular dependencies explicitly
- **Testing phase is MANDATORY** — every behavioral FR must map to at least one test task. The Requirements Coverage Matrix must show test task IDs for each FR.

## Examples

**Good task format**:
```
- [ ] T001 Create module structure per implementation plan
- [ ] T005 [US1] Implement VPC resource with conditional creation in main.tf
- [ ] T010 [US1] Implement flow log resources in main.tf
- [ ] T015 Write unit tests for VPC module in tests/basic.tftest.hcl
- [ ] T016 Write integration tests in tests/complete.tftest.hcl
```

**Good phase header**:
```
## Phase 2: Foundational (Core Resources)

**Purpose**: Primary resources that other features depend on

**CRITICAL**: Subnet resources require VPC to exist first

- [ ] T005 Implement VPC resource with conditional creation at /main.tf
- [ ] T006 Implement subnet resources with for_each at /main.tf

**Checkpoint**: Core VPC resources defined - dependent resources can proceed
```

**Good testing phase**:
```
## Phase 5: Testing

**Purpose**: Validate module behavior with unit and integration tests

- [ ] T015 Write unit tests for default configuration at /tests/basic.tftest.hcl
- [ ] T016 Write unit tests for all features enabled at /tests/complete.tftest.hcl
- [ ] T017 Write validation tests for invalid inputs at /tests/validation.tftest.hcl
- [ ] T018 Update examples/basic/ with minimal usage
- [ ] T019 Update examples/complete/ with full-featured usage

**Checkpoint**: `terraform test` passes, examples plan successfully
```

**Bad**:
```
- [ ] Create VPC
```
Missing task ID, story label, and file path.

## Context

### Phase Structure

| Phase | Content | Story Labels |
|-------|---------|--------------|
| 1 - Setup | Project initialization, file structure, Terraform config | No |
| 2 - Foundational | Core resources, blocking prerequisites | No |
| 3+ - User Stories | Priority order (P1, P2...) with feature implementation | Required |
| Testing | Unit tests, integration tests, examples | No |
| Final - Polish | Cross-cutting concerns, formatting, documentation, validation | No |

### Source Material Placement

| Source | Placement |
|--------|-----------|
| User stories | Own phase; map resources, variables, outputs |
| Resource contracts | Serving story; interface tests before impl if TDD |
| Data model | Earliest needing story; multi-story resources → Setup |
| Infrastructure | Shared → Phase 1; blocking → Phase 2; story-specific → that phase |
| Tests | Testing phase; unit tests for all code paths, integration for critical paths |
| Examples | Testing phase; basic and complete examples |

### Header Template

```markdown
# Tasks: [Feature Name]

**Input**: [spec path]
**Prerequisites**: plan.md, spec.md, contracts/data-model.md
**Tests**: Unit tests in `tests/`, integration tests against sandbox
**Organization**: [brief description]
```

### File Checklist

```markdown
| File | Task | Purpose |
|------|------|---------|
| `main.tf` | T005-T010 | Primary resources |
| `variables.tf` | T003 | Input variables |
| `outputs.tf` | T004 | Output values |
| `tests/basic.tftest.hcl` | T015 | Unit tests |
| `tests/complete.tftest.hcl` | T016 | Integration tests |
| `examples/basic/main.tf` | T018 | Basic usage example |
| `examples/complete/main.tf` | T019 | Complete usage example |
```

### Task Summary

```markdown
**Total Tasks**: N
```
