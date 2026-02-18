---
name: tf-judge-criteria
description: Scoring rubrics, severity classification, evaluation methodology, and iterative refinement protocol for Terraform code quality assessment. Use when evaluating Terraform code quality, scoring module readiness, or reviewing code against production standards.
---

# Terraform Code Quality Evaluation Criteria

## Core Principles

1. **Evidence-Based**: All judgments grounded in observable evidence (file:line, code quotes)
2. **Actionable**: Every issue includes concrete remediation with before/after examples
3. **Calibrated**: Use full 1-10 scale, consistent and comparable, ±0.5 variance on re-evaluation
4. **Constitution Authority**: MUST violations = CRITICAL, SHOULD = HIGH, MAY = LOW

## Production Readiness Scale

| Score    | Level          | Action                             |
| -------- | -------------- | ---------------------------------- |
| 9.0-10.0 | Exceptional    | None — use as reference            |
| 8.0-8.9  | Excellent      | Optional refinement                |
| 7.0-7.9  | Good           | Address high-priority issues       |
| 6.0-6.9  | Adequate       | Fix critical issues before release |
| 5.0-5.9  | Below Standard | Rework required                    |
| 4.0-4.9  | Poor           | Substantial redesign needed        |
| 1.0-3.9  | Unacceptable   | Complete rework required           |

## 6 Evaluation Dimensions

| #   | Dimension              | Weight | Key Criteria                                                                                                                     |
| --- | ---------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Module Structure       | 25%    | Standard layout (examples/, tests/, modules/), clean interfaces, conditional creation, `this` naming, no provider config in root |
| 2   | Security & Compliance  | 30%    | Secure defaults, encryption, IAM least privilege, no creds, audit logs. **<5.0 = Not Production Ready**                          |
| 3   | Code Quality           | 15%    | `terraform fmt`, naming, validation, DRY, organization, dynamic blocks                                                           |
| 4   | Variables & Outputs    | 10%    | Type constraints, validation rules, secure defaults, descriptions, `sensitive` marking                                           |
| 5   | Testing                | 10%    | `.tftest.hcl` files, unit tests (plan mode), integration tests, validation tests, example coverage                               |
| 6   | Constitution Alignment | 10%    | Matches plan.md, constitution v3.0.0 MUST compliance                                                                             |

**Score formula**: `(D1×0.25) + (D2×0.30) + (D3×0.15) + (D4×0.10) + (D5×0.10) + (D6×0.10)`

**Security override**: If D2 < 5.0, force "Not Production Ready" regardless of overall score.

## D1 Module Structure Scoring Guide

| Score | Criteria                                                                                                                       |
| ----- | ------------------------------------------------------------------------------------------------------------------------------ |
| 9-10  | Standard structure, examples/basic + complete, tests/, clean root, no provider config, conditional creation throughout         |
| 7-8   | Standard structure, examples present, tests present, minor issues (missing complete example, some resources lack conditionals) |
| 5-6   | Partial structure, missing examples or tests, provider config in root                                                          |
| 3-4   | No standard structure, monolithic files, no examples or tests                                                                  |
| 1-2   | Single file, no structure, no separation of concerns                                                                           |

## D5 Testing Scoring Guide

| Score | Criteria                                                                                                    |
| ----- | ----------------------------------------------------------------------------------------------------------- |
| 9-10  | Unit + integration tests, validation tests, mock providers, all code paths covered, examples deploy cleanly |
| 7-8   | Unit tests for defaults and main features, basic integration test, examples present                         |
| 5-6   | Some tests present but incomplete coverage, or only plan-mode tests                                         |
| 3-4   | Minimal testing (only terraform validate)                                                                   |
| 1-2   | No test files                                                                                               |

## Severity Classification

- **CRITICAL (P0)**: Constitution MUST violations, hardcoded credentials, public databases, missing tests, provider config in root module
- **HIGH (P1)**: Constitution SHOULD violations, unencrypted data, overly permissive IAM, missing docs, no examples
- **MEDIUM (P2)**: Code quality issues, formatting, incomplete test coverage
- **LOW (P3)**: Style improvements, additional documentation, refactoring

## Evidence Requirements Per Dimension

- D1: Module structure verification, examples/ and tests/ presence, provider config location, conditional creation patterns
- D2: File:line + CVE/CWE + severity + code fix
- D3: Format violations, missing docs, duplication with refactoring
- D4: Hardcoded values, missing validation, missing outputs, missing `sensitive` marking
- D5: Test file presence, coverage breadth, mock usage, example deployability
- D6: Plan deviations with plan.md refs, constitution violations with X.Y citations

## Refinement Options (when score < 8.0)

- **A (Auto-fix)**: Fix all P0 issues, re-evaluate (max 3 iterations)
- **B (Interactive)**: Present each issue, show fix, wait for approval
- **C (Manual)**: User fixes, agent provides guidance
- **D (Detailed)**: Generate before/after examples for top 10 issues

## History Tracking

Store evaluations in JSONL format at `<FEATURE_DIR>/evaluations/`:

```jsonl
{"timestamp":"ISO-8601","iteration":N,"overall_score":X.X,"dimension_scores":{...},"readiness":"status","critical_issues":N}
```
