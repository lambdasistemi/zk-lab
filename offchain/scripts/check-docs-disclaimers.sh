#!/usr/bin/env bash
#
# check-docs-disclaimers.sh — enforce FR-011 at the docs layer.
#
# Fails CI if any `docs/**/*.md` file contains production-readiness
# claims about zk-lab itself.  Third-party references (e.g. "Zcash
# used in production") and explicit negative disclaimers ("not a
# production library") are allowed.
#
# The policy is conservative: the script flags specific positive
# claims.  If a new claim slips in, add it to the PATTERNS array
# alongside an issue link.

set -euo pipefail

resolve_root() {
    if [[ -n "${ZK_LAB_ROOT:-}" ]]; then
        printf '%s\n' "$ZK_LAB_ROOT"
        return
    fi
    local d
    d=$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)
    while [[ "$d" != "/" ]]; do
        if [[ -d "$d/docs" && -d "$d/offchain" ]]; then
            printf '%s\n' "$d"
            return
        fi
        d=$(dirname "$d")
    done
    echo "check-docs-disclaimers: unable to locate repo root" >&2
    exit 2
}

ROOT=$(resolve_root)
DOCS="$ROOT/docs"

# Phrases that only appear as positive claims.  Case-insensitive.
# Extend with care: the point is to block claims of readiness, not
# to flag every mention of the word "production".
PATTERNS=(
    'production-ready'
    'production ready'
    'ready for production'
    'deploy to mainnet'
    'safe for real use'
    'audited by'
    'security-audited'
    'battle-tested'
)

fail=0
for pattern in "${PATTERNS[@]}"; do
    hits=$(grep -rnI --include='*.md' -i -F -- "$pattern" "$DOCS" || true)
    if [[ -n "$hits" ]]; then
        echo "check-docs-disclaimers: forbidden claim '$pattern':" >&2
        while IFS= read -r line; do
            echo "  $line" >&2
        done <<<"$hits"
        fail=1
    fi
done

if [[ $fail -eq 0 ]]; then
    echo "check-docs-disclaimers: OK (no production-readiness claims)"
    exit 0
fi

echo "check-docs-disclaimers: FAIL (FR-011 violated)" >&2
exit 1
