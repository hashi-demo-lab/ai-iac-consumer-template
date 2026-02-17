---

description: "Task list template for Terraform module implementation"
---

<!-- Placeholder convention: [BRACKETS] = human-authored content (instructions, descriptions).
     {{DOUBLE_BRACES}} = machine-filled values (timestamps, scores, IDs). -->

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research/, contracts/

**Tests**: Tests are MANDATORY for all module features. Every user story must have corresponding `.tftest.hcl` test files that validate the module's behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [Story] Description`

- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- All tasks execute **sequentially** in ID order (Terraform state prevents safe parallel execution)
- Include exact file paths in descriptions

## Path Conventions

- **Root module**: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `locals.tf` at repository root
- **Examples**: `examples/basic/`, `examples/complete/`
- **Tests**: `tests/*.tftest.hcl`
- **Submodules**: `modules/[name]/main.tf`, `modules/[name]/variables.tf`, `modules/[name]/outputs.tf`
- Paths shown below assume standard Terraform module layout per plan.md

<!--
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.

  The task generation phase MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Resource inventory from plan.md
  - Entities from contracts/
  - Module interfaces from contracts/

  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently (via terraform test)
  - Delivered as an MVP increment

  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Module Scaffold)

**Purpose**: Module initialization and standard file structure

- [ ] T001 Create root module files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- [ ] T002 Configure `versions.tf` with required Terraform and provider version constraints
- [ ] T003 Create `examples/basic/main.tf` with minimal module invocation scaffold
- [ ] T004 Create `examples/complete/main.tf` with full-featured module invocation scaffold
- [ ] T005 Create `tests/basic.tftest.hcl` and `tests/complete.tftest.hcl` test file scaffolds

---

## Phase 2: Core Resources (Foundational Infrastructure)

**Purpose**: Primary resources that MUST be complete before ANY additional features can be implemented

**CRITICAL**: No feature work can begin until core resources are in place

Examples of foundational tasks (adjust based on your module):

- [ ] T006 Define core input variables in `variables.tf`
- [ ] T007 Implement primary resource in `main.tf`
- [ ] T008 Implement essential dependent resources in `main.tf`
- [ ] T009 Define core outputs in `outputs.tf`
- [ ] T010 Add `locals.tf` for computed values and common tag merging

**Checkpoint**: Core module resources created - `terraform validate` passes, `terraform plan` shows expected resources

---

## Phase 3: User Story 1 - [Title] (Priority: P1) MVP

**Goal**: [Brief description of what this story delivers, e.g., "Module creates VPC with public and private subnets across multiple AZs"]

**Independent Test**: [How to verify this story works on its own, e.g., "Run `terraform test -filter=tests/basic.tftest.hcl` to validate basic VPC with subnets"]

### Tests for User Story 1 (MANDATORY)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T011 [US1] Write test for basic module configuration in `tests/basic.tftest.hcl`
- [ ] T012 [US1] Write test assertions for expected resource outputs

### Implementation for User Story 1

- [ ] T013 [US1] Add feature variables to `variables.tf`
- [ ] T014 [US1] Implement feature resources in `main.tf`
- [ ] T015 [US1] Add feature outputs to `outputs.tf`
- [ ] T016 [US1] Update `examples/basic/main.tf` with working example configuration
- [ ] T017 [US1] Verify tests pass: `terraform test -filter=tests/basic.tftest.hcl`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (MANDATORY)

- [ ] T018 [US2] Write test for feature configuration in `tests/complete.tftest.hcl`
- [ ] T019 [US2] Write test assertions for expected resource outputs

### Implementation for User Story 2

- [ ] T020 [US2] Add feature variables to `variables.tf`
- [ ] T021 [US2] Implement feature resources in `main.tf`
- [ ] T022 [US2] Add feature outputs to `outputs.tf`
- [ ] T023 [US2] Update `examples/complete/main.tf` with feature enabled
- [ ] T024 [US2] Verify tests pass: `terraform test`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (MANDATORY)

- [ ] T025 [US3] Write test for feature configuration in `tests/[feature].tftest.hcl`
- [ ] T026 [US3] Write test assertions for expected resource outputs

### Implementation for User Story 3

- [ ] T027 [US3] Add feature variables to `variables.tf`
- [ ] T028 [US3] Implement feature resources in `main.tf`
- [ ] T029 [US3] Add feature outputs to `outputs.tf`

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N-1: Testing & Validation (MANDATORY)

**Purpose**: Comprehensive testing and validation of all module features

- [ ] TXXX Run `terraform fmt -check -recursive` and fix any formatting issues
- [ ] TXXX Run `terraform validate` in root module and all examples
- [ ] TXXX Run full test suite: `terraform test` (all `.tftest.hcl` files)
- [ ] TXXX Run `terraform plan` on `examples/basic/` and verify expected resources
- [ ] TXXX Run `terraform plan` on `examples/complete/` and verify expected resources
- [ ] TXXX Run security scan: `trivy config .` and resolve any CRITICAL/HIGH findings
- [ ] TXXX Verify all variable descriptions and types are accurate in `variables.tf`
- [ ] TXXX Verify all outputs have descriptions in `outputs.tf`

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect the overall module quality

- [ ] TXXX Update README.md with module documentation (inputs, outputs, examples)
- [ ] TXXX Code cleanup: consistent naming, remove unused locals/variables
- [ ] TXXX Add variable validation blocks where appropriate
- [ ] TXXX Verify tagging consistency across all resources
- [ ] TXXX Run quickstart.md validation
- [ ] TXXX Ensure all examples have `terraform.tfvars` with sample values

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Core Resources (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Core Resources phase completion -- execute sequentially in priority order (P1, P2, P3)
- **Testing & Validation (Phase N-1)**: Depends on all desired user stories being complete
- **Polish (Final Phase)**: Depends on testing passing

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Core Resources (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Core Resources (Phase 2) - May extend US1 resources but should be independently testable
- **User Story 3 (P3)**: Can start after Core Resources (Phase 2) - May extend US1/US2 resources but should be independently testable

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Variables before resources
- Resources before outputs
- Core resource implementation before dependent resources
- Examples updated after resources and outputs are ready
- Story complete before moving to next priority

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (module scaffold)
2. Complete Phase 2: Core Resources (primary infrastructure)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Run `terraform test` and `terraform validate`
5. Deploy example to verify end-to-end

### Incremental Delivery

1. Complete Setup + Core Resources -> Module scaffold ready
2. Add User Story 1 -> Test independently -> Validate (MVP!)
3. Add User Story 2 -> Test independently -> Validate
4. Add User Story 3 -> Test independently -> Validate
5. Each story adds module capability without breaking previous functionality

---

## Notes

- All tasks execute sequentially -- Terraform state prevents safe parallel execution
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Tests are MANDATORY: write `.tftest.hcl` tests first, verify they fail, then implement
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
