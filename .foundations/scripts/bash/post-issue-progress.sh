#!/usr/bin/env bash
# post-issue-progress.sh — Standardised issue progress commenting
#
# Usage:
#   post-issue-progress.sh <issue_number> <phase_name> <status> [summary] [details]
#
# Arguments:
#   issue_number  GitHub issue number (required)
#   phase_name    Human-readable phase name, e.g. "Environment Validation" (required)
#   status        One of: started, complete, failed (required)
#   summary       Brief one-line summary of outcome (optional for started, recommended for complete/failed)
#   details       Multi-line details/bullets to append as **Summary** block (optional)
#
# Examples:
#   post-issue-progress.sh 42 "Environment Validation" "complete" "All gates passed"
#   post-issue-progress.sh 42 "Specify" "complete" "spec.md generated (12 sections)" "- Defined VPC with 3 AZs
# - 4 success criteria with measurable thresholds"
#   post-issue-progress.sh 42 "Sandbox Testing" "failed" "terraform apply failed: missing provider"
#   post-issue-progress.sh 42 "Implementation Phase 1" "started"

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: post-issue-progress.sh <issue_number> <phase_name> <status> [summary]" >&2
  echo "  status: started | complete | failed" >&2
  exit 1
fi

ISSUE_NUMBER="$1"
PHASE_NAME="$2"
STATUS="$3"
SUMMARY="${4:-}"
DETAILS="${5:-}"

# Validate status
case "$STATUS" in
  started|complete|failed) ;;
  *)
    echo "Error: status must be one of: started, complete, failed (got: $STATUS)" >&2
    exit 1
    ;;
esac

# Build comment body
case "$STATUS" in
  started)
    ICON="🔄"
    STATUS_LABEL="In Progress"
    BODY="## ${ICON} Phase: ${PHASE_NAME}
**Status**: ${STATUS_LABEL}"
    if [[ -n "$SUMMARY" ]]; then
      BODY="${BODY}
${SUMMARY}"
    fi
    ;;
  complete)
    ICON="✅"
    STATUS_LABEL="Complete"
    BODY="## ${ICON} Phase: ${PHASE_NAME}
**Status**: ${STATUS_LABEL}"
    if [[ -n "$SUMMARY" ]]; then
      BODY="${BODY}
**Result**: ${SUMMARY}"
    fi
    ;;
  failed)
    ICON="❌"
    STATUS_LABEL="Failed"
    BODY="## ${ICON} Phase: ${PHASE_NAME}
**Status**: ${STATUS_LABEL}"
    if [[ -n "$SUMMARY" ]]; then
      BODY="${BODY}
**Error**: ${SUMMARY}"
    fi
    ;;
esac

# Append details block if provided
if [[ -n "$DETAILS" ]]; then
  BODY="${BODY}

**Summary**:
${DETAILS}"
fi

# Detect GHE hostname from git remote
GH_HOST_DETECTED=$(git remote get-url origin 2>/dev/null | sed -n 's|.*://\([^/]*\)/.*|\1|p' | grep -v 'github\.com' || true)
if [ -n "$GH_HOST_DETECTED" ]; then
  export GH_HOST="$GH_HOST_DETECTED"
fi

# Post to GitHub issue
gh issue comment "$ISSUE_NUMBER" --body "$BODY"
