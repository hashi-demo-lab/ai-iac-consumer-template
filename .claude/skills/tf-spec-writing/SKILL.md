---
name: tf-spec-writing
description: Terraform module specification writing patterns. Use when writing or reviewing Terraform module specifications, user stories, success criteria, or requirement quality rules.
---

# Terraform Module Specification Patterns

## Specification Purpose

Specifications describe **WHAT** the module should do and **WHY** — never HOW to implement. Written for module consumers and reviewers, not implementation details. Define the module's interface, features, and behavior.

## Section Requirements

### Mandatory Sections
- **Module Purpose**: What infrastructure this module creates and manages
- **User Scenarios & Testing**: Prioritized user stories with acceptance scenarios and edge cases
- **Requirements**: Functional requirements (FR-numbered) including module interface (inputs, outputs, features)
- **Success Criteria**: Measurable, technology-agnostic outcomes

## Requirement Writing Rules

1. Every requirement MUST be testable and unambiguous
2. Maximum 3 `[NEEDS CLARIFICATION]` markers total
3. Prioritize clarifications: scope > security/privacy > interface design > technical
4. Make informed guesses using context and industry standards
5. Document assumptions in Assumptions section

## Success Criteria Guidelines

Criteria must be:
- **Measurable**: Specific metrics (time, percentage, count, rate)
- **Technology-agnostic**: No frameworks, languages, databases, or tools
- **User-focused**: Outcomes from consumer/business perspective
- **Verifiable**: Testable without knowing implementation details

**Good**: "All data stored by this module is encrypted at rest and in transit by default"
**Bad**: "Enable KMS encryption on S3 buckets" (implementation leakage)

**Good**: "Module consumers can disable any optional feature via a single boolean variable"
**Bad**: "Use count = var.create ? 1 : 0 on all resources" (implementation leakage)

## Reasonable Defaults (don't ask about these)

- Encryption: At-rest and in-transit enabled by default
- Networking: Private subnets for workloads, public only for load balancers
- Logging: CloudWatch logging enabled for all services
- Tagging: Support for consumer-provided tags via `tags` variable
- Conditional creation: All major resource groups toggleable
- Data retention: Industry-standard practices

For each default listed above, the spec MUST include an explicit FR requiring that behavior as a secure default.

## Module-Specific Patterns

For module specifications:
- Describe what the module creates, not specific Terraform resources
- Define the module's interface: what inputs consumers provide, what outputs they receive
- Security requirements should describe secure defaults and toggles
- Scalability should describe capacity features, not implementation
- Reference cloud capabilities, not resource names
- Specify which features are enabled by default vs opt-in
- Define what the examples/ should demonstrate

## Quality Validation Checklist

After writing spec, validate:
- [ ] No implementation details (resource names, HCL syntax, specific arguments)
- [ ] Focused on module consumer value and use cases
- [ ] Written for module reviewers and consumers
- [ ] All mandatory sections completed
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable and technology-agnostic
- [ ] Edge cases identified (empty inputs, disabled features, max scale)
- [ ] Scope clearly bounded (what the module does NOT do)
- [ ] Dependencies and assumptions identified
- [ ] Module interface requirements specified (key inputs, outputs)
