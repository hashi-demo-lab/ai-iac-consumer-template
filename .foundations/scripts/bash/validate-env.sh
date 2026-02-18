#!/usr/bin/env bash

# Environment validation script with GATE/WARN severity classification
#
# Each check is classified as:
#   GATE — Failure blocks all progress. Orchestrators MUST NOT proceed.
#   WARN — Failure degrades capability but does not block progress.
#
# Usage: ./validate-env.sh [OPTIONS]
#
# OPTIONS:
#   --json              Output in JSON format (includes gate_passed boolean)
#   --quiet             Suppress output (exit code only)
#   --help, -h          Show help message
#
# EXIT CODES:
#   0: All checks passed (GATE and WARN)
#   1: One or more GATE checks failed — orchestrators MUST stop
#   2: All GATE checks passed but one or more WARN checks failed

set -euo pipefail

# Parse command line arguments
JSON_MODE=false
QUIET_MODE=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --quiet)
            QUIET_MODE=true
            ;;
        --help|-h)
            cat << 'EOF'
Usage: validate-env.sh [OPTIONS]

Validate environment prerequisites for Terraform operations.

Each check has a severity:
  GATE  Failure blocks all progress. Orchestrators MUST stop.
  WARN  Failure degrades capability. Orchestrators may proceed.

GATE CHECKS:
  TFE_TOKEN          Terraform Cloud/Enterprise API token
  GITHUB_TOKEN       GitHub Personal Access Token
  GH_CLI             GitHub CLI installed and authenticated
                     (Required: issue creation is mandatory audit trail)

WARN CHECKS:
  TFLINT             TFLint installed (code quality, non-blocking)
  PRE_COMMIT         pre-commit installed (hooks, non-blocking)

OPTIONS:
  --json              Output in JSON format (includes gate_passed, checks array)
  --quiet             Suppress output (exit code only)
  --help, -h          Show this help message

EXIT CODES:
  0: All checks passed
  1: One or more GATE checks failed — MUST stop
  2: GATE checks passed, one or more WARN checks failed

JSON OUTPUT SCHEMA:
  {
    "gate_passed": true|false,
    "checks": [
      {"name": "TFE_TOKEN", "severity": "GATE", "passed": true|false, "detail": "..."},
      ...
    ]
  }

EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# --- Check definitions ---
# Each check: name, severity, passed, detail
declare -a check_names=()
declare -a check_severities=()
declare -a check_passed=()
declare -a check_details=()

add_check() {
    local name="$1" severity="$2" passed="$3" detail="$4"
    check_names+=("$name")
    check_severities+=("$severity")
    check_passed+=("$passed")
    check_details+=("$detail")
}

# GATE: TFE_TOKEN
if [[ -z "${TFE_TOKEN:-}" ]]; then
    add_check "TFE_TOKEN" "GATE" "false" "NOT SET — export TFE_TOKEN from https://app.terraform.io/app/settings/tokens"
else
    add_check "TFE_TOKEN" "GATE" "true" "SET"
fi

# GATE: GITHUB_TOKEN or GH_ENTERPRISE_TOKEN
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    add_check "GITHUB_TOKEN" "GATE" "true" "SET (GITHUB_TOKEN)"
elif [[ -n "${GH_ENTERPRISE_TOKEN:-}" ]]; then
    add_check "GITHUB_TOKEN" "GATE" "true" "SET (GH_ENTERPRISE_TOKEN)"
else
    add_check "GITHUB_TOKEN" "GATE" "false" "NOT SET — export GITHUB_TOKEN or GH_ENTERPRISE_TOKEN"
fi

# GATE: GH_CLI (required for issue creation — audit trail per Principle #11)
#
# gh CLI native env var auth (no gh auth login needed):
#   GITHUB_TOKEN / GH_TOKEN            → github.com and *.ghe.com (cloud)
#   GH_ENTERPRISE_TOKEN                → GitHub Enterprise Server (self-hosted)
#   GH_HOST                            → default hostname when not inferred from repo
#
# See: https://cli.github.com/manual/gh_help_environment
if ! command -v gh &> /dev/null; then
    add_check "GH_CLI" "GATE" "false" "NOT INSTALLED — see: https://cli.github.com"
else
    # Derive hostname from git remote (falls back to github.com)
    GH_TARGET="github.com"
    if git rev-parse --is-inside-work-tree &> /dev/null; then
        REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)
        if [[ "$REMOTE_URL" =~ ^git@([^:]+): ]]; then
            GH_TARGET="${BASH_REMATCH[1]}"
        elif [[ "$REMOTE_URL" =~ ^https?://([^/]+)/ ]]; then
            GH_TARGET="${BASH_REMATCH[1]}"
        fi
    fi

    IS_GHE_SERVER=false
    [[ "$GH_TARGET" != "github.com" && ! "$GH_TARGET" =~ \.ghe\.com$ ]] && IS_GHE_SERVER=true

    if gh auth status --hostname "$GH_TARGET" &> /dev/null; then
        add_check "GH_CLI" "GATE" "true" "AUTHENTICATED ($GH_TARGET)"
    elif $IS_GHE_SERVER && [[ -n "${GH_ENTERPRISE_TOKEN:-}" ]]; then
        add_check "GH_CLI" "GATE" "true" "AUTHENTICATED via GH_ENTERPRISE_TOKEN ($GH_TARGET)"
    elif ! $IS_GHE_SERVER && [[ -n "${GITHUB_TOKEN:-}${GH_TOKEN:-}" ]]; then
        add_check "GH_CLI" "GATE" "true" "AUTHENTICATED via GITHUB_TOKEN ($GH_TARGET)"
    else
        if $IS_GHE_SERVER; then
            add_check "GH_CLI" "GATE" "false" "NOT AUTHENTICATED for $GH_TARGET — export GH_ENTERPRISE_TOKEN"
        else
            add_check "GH_CLI" "GATE" "false" "NOT AUTHENTICATED — export GITHUB_TOKEN"
        fi
    fi
fi

# WARN: TFLint
if command -v tflint &> /dev/null; then
    add_check "TFLINT" "WARN" "true" "INSTALLED"
else
    add_check "TFLINT" "WARN" "false" "NOT INSTALLED — code quality linting unavailable"
fi

# WARN: pre-commit
if command -v pre-commit &> /dev/null; then
    add_check "PRE_COMMIT" "WARN" "true" "INSTALLED"
else
    add_check "PRE_COMMIT" "WARN" "false" "NOT INSTALLED — git hooks unavailable"
fi

# --- Evaluate results ---
gate_failed=0
warn_failed=0
for i in "${!check_names[@]}"; do
    if [[ "${check_passed[$i]}" == "false" ]]; then
        if [[ "${check_severities[$i]}" == "GATE" ]]; then
            gate_failed=$((gate_failed + 1))
        else
            warn_failed=$((warn_failed + 1))
        fi
    fi
done

gate_passed="true"
[[ $gate_failed -gt 0 ]] && gate_passed="false"

if [[ $gate_failed -gt 0 ]]; then
    EXIT_CODE=1
elif [[ $warn_failed -gt 0 ]]; then
    EXIT_CODE=2
else
    EXIT_CODE=0
fi

# --- Output ---
if $QUIET_MODE; then
    exit $EXIT_CODE
elif $JSON_MODE; then
    # Build checks JSON array
    checks_json=""
    for i in "${!check_names[@]}"; do
        [[ -n "$checks_json" ]] && checks_json+=","
        checks_json+=$(printf '{"name":"%s","severity":"%s","passed":%s,"detail":"%s"}' \
            "${check_names[$i]}" "${check_severities[$i]}" "${check_passed[$i]}" "${check_details[$i]}")
    done

    printf '{"gate_passed":%s,"checks":[%s]}\n' "$gate_passed" "$checks_json"
else
    echo "Environment Validation"
    echo "======================"
    echo ""

    for i in "${!check_names[@]}"; do
        local_severity="${check_severities[$i]}"
        local_name="${check_names[$i]}"
        local_status="Passed"
        [[ "${check_passed[$i]}" == "false" ]] && local_status="FAILED"
        echo "  [$local_severity] $local_name — $local_status — ${check_details[$i]}"
    done

    echo ""
    echo "Summary"
    echo "-------"
    if [[ $gate_failed -gt 0 ]]; then
        echo "BLOCKED: $gate_failed GATE check(s) failed. Cannot proceed."
        echo ""
        echo "Quick Setup:"
        step=1
        for i in "${!check_names[@]}"; do
            if [[ "${check_passed[$i]}" == "false" && "${check_severities[$i]}" == "GATE" ]]; then
                echo "  $step. ${check_names[$i]}: ${check_details[$i]}"
                step=$((step + 1))
            fi
        done
        echo ""
        echo "For permanent setup, add exports to your ~/.bashrc or ~/.zshrc"
    elif [[ $warn_failed -gt 0 ]]; then
        echo "PASSED (with warnings): All GATE checks passed. $warn_failed WARN check(s) failed."
    else
        echo "ALL PASSED: Environment is fully configured."
    fi
fi

# Initialize tools in text mode only (non-blocking)
if ! $QUIET_MODE && ! $JSON_MODE && [[ $EXIT_CODE -ne 1 ]]; then
    echo ""
    echo "Tool Initialization"
    echo "==================="
    echo ""

    if command -v tflint &> /dev/null; then
        echo "Initializing TFLint..."
        if ! tflint --init; then
            echo "WARNING: TFLint initialization failed, but continuing..."
        fi
        echo ""
    fi

    if command -v pre-commit &> /dev/null; then
        echo "Installing pre-commit hooks..."
        pre-commit install
    fi
    echo ""
fi

exit $EXIT_CODE
