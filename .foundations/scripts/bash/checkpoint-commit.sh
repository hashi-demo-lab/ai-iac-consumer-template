#!/usr/bin/env bash

# Checkpoint commit script for orchestrator artifact commits
#
# Abstracts the repeating git add/commit/push pattern used by tf-plan and
# tf-implement after each workflow step. Handles empty-commit detection,
# deterministic commit messages, and push failures.
#
# Usage: ./checkpoint-commit.sh [OPTIONS] <step_name>
#
# ARGUMENTS:
#   step_name           Short step identifier (e.g., "specify", "clarify",
#                       "research-and-plan-draft", "design-review",
#                       "tasks-generation", "cross-artifact-analysis",
#                       "planning", "compound", "implementation-phase-N")
#
# OPTIONS:
#   --dir <path>        Directory to stage (default: specs/)
#   --prefix <type>     Commit type prefix: docs, feat, compound (default: docs)
#   --json              Output result as JSON
#   --quiet             Suppress output (exit code only)
#   --help, -h          Show help message
#
# EXIT CODES:
#   0: Commit and push succeeded (or nothing to commit)
#   1: Git operation failed (commit or push)
#   2: Invalid arguments
#
# EXAMPLES:
#   checkpoint-commit.sh "specify"
#   checkpoint-commit.sh --dir .foundations/memory/ --prefix compound "learnings"
#   checkpoint-commit.sh --json "design-review"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

# --- Defaults ---
STAGE_DIR="specs/"
COMMIT_PREFIX="docs"
JSON_MODE=false
QUIET_MODE=false
STEP_NAME=""

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            STAGE_DIR="$2"
            shift 2
            ;;
        --prefix)
            COMMIT_PREFIX="$2"
            shift 2
            ;;
        --json)
            JSON_MODE=true
            shift
            ;;
        --quiet)
            QUIET_MODE=true
            shift
            ;;
        --help|-h)
            cat << 'EOF'
Usage: checkpoint-commit.sh [OPTIONS] <step_name>

Commit and push staged artifacts after a workflow step.

ARGUMENTS:
  step_name           Short step identifier (e.g., "specify", "clarify")

OPTIONS:
  --dir <path>        Directory to stage (default: specs/)
  --prefix <type>     Commit type prefix: docs, feat, compound (default: docs)
  --json              Output result as JSON
  --quiet             Suppress output (exit code only)
  --help, -h          Show this help message

EXIT CODES:
  0: Commit and push succeeded (or nothing to commit)
  1: Git operation failed
  2: Invalid arguments
EOF
            exit 0
            ;;
        -*)
            echo "ERROR: Unknown option '$1'. Use --help for usage." >&2
            exit 2
            ;;
        *)
            if [[ -z "$STEP_NAME" ]]; then
                STEP_NAME="$1"
            else
                echo "ERROR: Unexpected argument '$1'. Only one step_name allowed." >&2
                exit 2
            fi
            shift
            ;;
    esac
done

if [[ -z "$STEP_NAME" ]]; then
    echo "ERROR: step_name is required. Use --help for usage." >&2
    exit 2
fi

# --- Resolve feature name from branch ---
BRANCH=$(get_current_branch)

# Extract feature short-name: strip numeric prefix (e.g., "004-vpc-setup" → "vpc-setup")
if [[ "$BRANCH" =~ ^[0-9]{3}-(.+)$ ]]; then
    FEATURE_NAME="${BASH_REMATCH[1]}"
else
    FEATURE_NAME="$BRANCH"
fi

# --- Build deterministic commit message ---
COMMIT_MSG="${COMMIT_PREFIX}(${FEATURE_NAME}): complete ${STEP_NAME} artifacts"

# --- Stage files ---
git add "$STAGE_DIR"

# --- Check if there's anything to commit ---
if git diff --cached --quiet; then
    # Nothing staged — success with no-op
    if $JSON_MODE; then
        printf '{"committed":false,"pushed":false,"reason":"nothing_to_commit","message":""}\n'
    elif ! $QUIET_MODE; then
        echo "Nothing to commit in ${STAGE_DIR} — skipping."
    fi
    exit 0
fi

# --- Commit ---
if ! git commit -m "$COMMIT_MSG"; then
    if $JSON_MODE; then
        printf '{"committed":false,"pushed":false,"reason":"commit_failed","message":"%s"}\n' "$COMMIT_MSG"
    elif ! $QUIET_MODE; then
        echo "ERROR: git commit failed." >&2
    fi
    exit 1
fi

# --- Push ---
if ! git push; then
    if $JSON_MODE; then
        printf '{"committed":true,"pushed":false,"reason":"push_failed","message":"%s"}\n' "$COMMIT_MSG"
    elif ! $QUIET_MODE; then
        echo "ERROR: git push failed. Commit was created locally: $COMMIT_MSG" >&2
    fi
    exit 1
fi

# --- Success ---
if $JSON_MODE; then
    printf '{"committed":true,"pushed":true,"reason":"success","message":"%s"}\n' "$COMMIT_MSG"
elif ! $QUIET_MODE; then
    echo "Committed and pushed: $COMMIT_MSG"
fi

exit 0
