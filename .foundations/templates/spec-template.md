<!-- Placeholder convention: [BRACKETS] = human-authored content (instructions, descriptions).
     {{DOUBLE_BRACES}} = machine-filled values (timestamps, scores, IDs). -->

# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as module capabilities ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Module) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of module functionality that can be:
  - Developed independently
  - Tested independently (via terraform test)
  - Validated independently (via example configurations)
  - Demonstrated to consumers independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this module capability in plain language from the perspective of a module consumer]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by running `terraform test` against tests/basic.tftest.hcl and delivers [specific infrastructure capability]"]

**Acceptance Scenarios**:

1. **Given** [module input configuration], **When** [terraform apply is run], **Then** [expected infrastructure outcome]
2. **Given** [module input configuration], **When** [terraform plan is run], **Then** [expected resource plan]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this module capability in plain language from the perspective of a module consumer]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [module input configuration], **When** [terraform apply is run], **Then** [expected infrastructure outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this module capability in plain language from the perspective of a module consumer]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [module input configuration], **When** [terraform apply is run], **Then** [expected infrastructure outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!-- Fill in for this module. -->

- What happens when [invalid variable value is provided]?
- How does the module handle [missing optional input]?
- What happens when [dependent cloud resource does not exist]?
- How does the module behave when [resource quota or limit is reached]?

## Requirements *(mandatory)*

<!-- Fill in for this module. -->

### Functional Requirements

- **FR-001**: Module MUST [create primary resource, e.g., "create a VPC with configurable CIDR block"]
- **FR-002**: Module MUST [support configuration, e.g., "allow configurable number of public and private subnets"]
- **FR-003**: Module MUST [provide output, e.g., "export VPC ID and subnet IDs as outputs"]
- **FR-004**: Module MUST [enforce default, e.g., "enable DNS support and DNS hostnames by default"]
- **FR-005**: Module MUST [support tagging, e.g., "apply user-provided tags to all created resources"]

*Example of marking unclear requirements:*

- **FR-006**: Module MUST support [NEEDS CLARIFICATION: should NAT Gateway be single-AZ or multi-AZ?]
- **FR-007**: Module MUST create flow logs with retention period of [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if module involves multiple resource types)*

- **[Resource Group 1]**: [What it represents, key attributes - e.g., "VPC: primary network boundary, CIDR block, DNS settings"]
- **[Resource Group 2]**: [What it represents, relationships to other resources - e.g., "Subnets: network segments within VPC, AZ placement, route table associations"]

### Module Interface Summary *(optional, names only)*

<!-- Full types/defaults belong in contracts/module-interfaces.md -->

- **Input variables**: [list variable names only, e.g., `name`, `tags`, `enable_versioning`]
- **Output values**: [list output names only, e.g., `bucket_id`, `bucket_arn`]
- **Feature flags**: [list flag names only, e.g., `create`, `enable_logging`]

## Success Criteria *(mandatory)*

<!-- Fill in for this module. -->

### Measurable Outcomes

- **SC-001**: [Validation metric, e.g., "`terraform validate` passes with no errors"]
- **SC-002**: [Test metric, e.g., "All `.tftest.hcl` test files pass via `terraform test`"]
- **SC-003**: [Format metric, e.g., "`terraform fmt -check` reports no formatting issues"]
- **SC-004**: [Example metric, e.g., "Both `examples/basic/` and `examples/complete/` configurations plan and apply successfully"]
- **SC-005**: [Security metric, e.g., "No CRITICAL or HIGH findings from trivy security scan"]
- **SC-006**: [Documentation metric, e.g., "README.md includes all inputs, outputs, and at least one usage example"]
