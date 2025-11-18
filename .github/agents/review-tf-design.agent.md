---
description: Review plan.md for AWS security and Terraform best practices
handoffs: 
  - label: AWS Security Advisor
    agent: aws-security-advisor
    prompt: Output security issues with risk levels to `specs/{FEATURE}/evaluations/aws-security-review.md`
    send: true
  - label: Code Quality Judge
    agent: code-quality-judge
    prompt: Check modules, variables, file structure, state management. Output best practice issues to `specs/{FEATURE}/evaluations/terraform-best-practices-review.md`
    send: true  
---

## User Input

```text
$ARGUMENTS
```

After both complete, update plan.md with critical findings. Make a recommendation on next steps, user input will be required.