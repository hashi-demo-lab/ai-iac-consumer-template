---
name: review-tf-design
description: Review plan.md for AWS security and Terraform best practices
---

Run 2 subagents in parallel to review plan.md:

1. **aws-security-advisor**: Check IAM, encryption, network, logging, resilience. Output security issues with risk levels to `specs/{FEATURE}/evaluations/aws-security-review.md`

2. **code-quality-judge**: Check modules, variables, file structure, state management. Output best practice issues to `specs/{FEATURE}/evaluations/terraform-best-practices-review.md`

After both complete, update plan.md with critical findings. Make a recommendation on next steps, user input will be required.

---

$ARGUMENTS