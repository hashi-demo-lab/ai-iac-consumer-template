---
name: tf-checklist-patterns
description: >
  Checklist creation patterns for requirement quality validation. "Unit tests for English" —
  test the requirements themselves, not the implementation. Anti-examples, quality dimensions,
  traceability rules. Use when creating or reviewing requirement quality checklists for
  Terraform infrastructure specifications.
---

# Checklist Patterns: Unit Tests for Requirements

## Core Concept

Checklists are **unit tests for requirements writing** — they validate quality, clarity, and completeness of requirements in a given domain. They do NOT test implementation behavior.

## What Checklists Test

- **Completeness**: Are all necessary requirements present?
- **Clarity**: Are requirements unambiguous and specific?
- **Consistency**: Do requirements align with each other?
- **Measurability**: Can requirements be objectively verified?
- **Coverage**: Are all scenarios/edge cases addressed?

## Prohibited Patterns

- ❌ "Verify the EC2 instance launches successfully" (tests implementation)
- ❌ "Test that the security group allows port 443" (tests behavior)
- ❌ "Confirm the S3 bucket is created" (tests system)
- ❌ Starting with "Verify", "Test", "Confirm", "Check" + implementation behavior
- ❌ References to resource state, apply output, or infrastructure behavior

## Required Patterns

- ✅ "Are [requirement type] defined/specified/documented for [scenario]?"
- ✅ "Is [vague term] quantified/clarified with specific criteria?"
- ✅ "Are requirements consistent between [section A] and [section B]?"
- ✅ "Can [requirement] be objectively measured/verified?"
- ✅ "Does the spec define [missing aspect]?"

## Category Structure

Group items by requirement quality dimensions:
1. **Requirement Completeness** — All necessary requirements documented?
2. **Requirement Clarity** — Specific and unambiguous?
3. **Requirement Consistency** — Aligned without conflicts?
4. **Acceptance Criteria Quality** — Measurable success criteria?
5. **Scenario Coverage** — All flows/cases addressed?
6. **Edge Case Coverage** — Boundary conditions defined?
7. **Non-Functional Requirements** — Performance, Security, Operability specified?
8. **Dependencies & Assumptions** — Documented and validated?
9. **Ambiguities & Conflicts** — What needs clarification?

## Item Format

```markdown
- [ ] CHK### - [Question about requirement quality] [Dimension, Spec: Section Name]
```

- Sequential IDs starting from CHK001
- Question format asking about requirement quality
- Include quality dimension in brackets
- Reference spec section when checking existing requirements
- Use `[Gap]` marker when checking for missing requirements

## Traceability

- Minimum 80% of items MUST include at least one traceability reference
- Reference: spec section `[Spec: Section Name]`, or markers: `[Gap]`, `[Ambiguity]`, `[Conflict]`, `[Assumption]`

## Scenario Classification

Check requirements exist for:
- Provisioning (initial deployment)
- Modification (day-2 changes, scaling)
- Failure & Recovery (outages, rollback)
- Decommissioning (destroy, cleanup)
- Non-Functional domains

## Content Rules

- Soft cap: 40 items max; prioritize by risk/impact
- Merge near-duplicates checking the same requirement aspect
- If >5 low-impact edge cases, consolidate into one item
- Each `checklist generation` run creates a NEW file (never overwrites)
- Filenames: `[domain].md` (e.g., `networking.md`, `iam.md`, `security.md`)
