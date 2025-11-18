---
description: Review plan.md for AWS security and Terraform best practices
---
Run 2 subagents in parallel to review plan.md:


Run /aws-security-advisor with input "Output security issues with risk levels to `specs/{FEATURE}/evaluations/aws-security-review.md`" using #runSubagent


Run /code-quality-judge with input "Check modules, variables, file structure, state management. Output best practice issues to `specs/{FEATURE}/evaluations/terraform-best-practices-review.md`" using #runSubagent

## User Input

```text
$ARGUMENTS
```

After both complete, update plan.md with critical findings. Make a recommendation on next steps, user input will be required.