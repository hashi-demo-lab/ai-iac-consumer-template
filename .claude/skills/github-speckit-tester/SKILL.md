---
name: github-speckit-tester
description: Test harness for executing Speckit workflows non-interactively using subagents. Use when you need to test the complete Speckit pipeline (Phase 0 → Phase 3) or individual phases, validate artifact generation across all commands, automate testing of specification-to-implementation workflows, or verify cross-phase consistency. This skill orchestrates the execution of all Speckit commands in order without user intervention.
---

# GitHub Speckit Tester

A comprehensive test harness for validating the Speckit workflow system by executing all phases non-interactively using subagents. After each phase clear the context using /clear

## Overview

This skill provides automated testing capabilities for the complete Speckit pipeline, executing all commands in sequence from specification to implementation without requiring user interaction.

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

1 validate-env.sh → env ok
2 /speckit.specify → spec.md
3 /speckit.clarify → spec.md updated
4 /speckit.plan → plan.md, data-model.md
5 /review-tf-design → approved
6 /speckit.tasks → tasks.md
7 /speckit.analyze → analysis
8 /speckit.implement → tf code + sandbox test
9 deploy (cli) → init/plan/apply
10 /report-tf-deployment → report
11 cleanup (confirm) → destroy