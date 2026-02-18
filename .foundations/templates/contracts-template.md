<!-- Placeholder convention: [BRACKETS] = human-authored content (instructions, descriptions).
     {{DOUBLE_BRACES}} = machine-filled values (timestamps, scores, IDs). -->

# Module Interface Specification

**Feature**: [FEATURE NAME]
**Date**: [DATE]
**Source**: Derived from plan.md resource inventory and spec.md requirements

## Module: {{MODULE_NAME}}
**Registry Path:** `terraform-{{PROVIDER}}-{{MODULE_NAME}}`
**Version:** `{{VERSION}}`

### Inputs (Variables)
| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| {{VAR_NAME}} | {{VAR_TYPE}} | {{REQUIRED}} | {{DEFAULT}} | [Variable description] |

### Outputs
| Output | Type | Sensitive | Description |
|--------|------|-----------|-------------|
| {{OUTPUT_NAME}} | {{OUTPUT_TYPE}} | {{SENSITIVE}} | [Output description] |

### Variable Validation Rules
| Variable | Validation | Error Message |
|----------|-----------|---------------|
| {{VAR_NAME}} | `{{VALIDATION_EXPRESSION}}` | "{{ERROR_MESSAGE}}" |

## Resource Dependencies
<!-- Internal resource dependency flow: which resources depend on which within the module -->
| Resource | Depends On | Relationship |
|----------|-----------|--------------|
| {{RESOURCE}} | {{DEPENDS_ON}} | [Relationship description] |

## Resource-to-Output Mapping
<!-- Shows which resources feed which outputs -->
| Resource | Attribute | Output |
|----------|-----------|--------|
| {{RESOURCE}} | {{ATTRIBUTE}} | {{OUTPUT_NAME}} |
