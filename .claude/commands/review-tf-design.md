---
name: review-tf-design
description: Review plan.md for AWS security and Terraform best practices
---

Run 2 subagents in parallel to review plan.md:

subagent aws-security-advisor, @aws-security-advisor 
subagent code-quality-judge, @code-quality-judge 

After both complete, update plan.md with critical findings. Make a recommendation on next steps, user input will be required.

---

$ARGUMENTS
