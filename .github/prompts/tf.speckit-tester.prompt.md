---
name: github-speckit-tester
description: Test harness for executing Speckit workflows non-interactively using subagents. Use when you need to test the complete Speckit pipeline (Phase 0 → Phase 3) or individual phases, validate artifact generation across all commands, automate testing of specification-to-implementation workflows, or verify cross-phase consistency. This skill orchestrates the execution of all Speckit commands in order without user intervention.
---

# GitHub Speckit Tester

A comprehensive test harness for validating the Speckit workflow system by executing all phases non-interactively using subagents. After each phase clear the context using /clear

## Overview

This skill provides automated testing capabilities for the complete Speckit pipeline, executing all commands in sequence from specification to implementation without requiring user interaction.

## Test Scenario
Please read the following file to load the test scenario:
#file: github/test-scenarios/${input:scenario}


## Core Concepts

### Non-Interactive Execution

All Speckit commands must be executed without user intervention:
- Automatic decision-making for clarifications
- Default selections for ambiguous choices
- Automated validation and progression through phases
- Error handling and recovery without user input
- always create a new feature branch from dev

### Subagent Orchestration

The test harness uses subagents to:
- Execute each phase independently
- Isolate phase execution for better debugging
- Parallelize independent phases when possible
- Maintain clean execution context per phase

Document start time and end time, totals execution time, and tokens consumed inclusive of all subagents

### Execution Workflow

1. Prerequisites: Validate environment and credentials by running `.specify/scripts/bash/validate-env.sh`
2. Run `/speckit.specify` prompt
3. Run `/speckit.clarify` prompt
4. Run `/speckit.checklist` prompt 
5. Run `/speckit.plan` prompt 
6. Run `/review.tf-design` prompt 
7. Run `/speckit.tasks` prompt 
8. Run `/speckit.analyze` prompt 
9. Run `/speckit.implement` prompt 
10. Deploy to HCP Terraform ephemeral workspace to test and validate the generated Terraform code
11. Run `/report.tf-deployment` prompt 
12. Destroy resources and cleanup, delete ephemeral workspace