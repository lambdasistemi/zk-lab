#!/usr/bin/env bash
#
# check-property-parity.sh — mechanize SC-003 for 001-set-membership.
#
# Verifies that the Lean and QuickCheck property surfaces stay in
# 1:1 correspondence per the mapping table of
# `specs/001-set-membership/contracts/properties.md`.
#
# Inputs:
#   lean/ZKLab/SetMembership.lean
#     — theorems inside the section opened by the marker line
#       `-- ## Parity-tracked properties ##` are parity-tracked;
#       theorems outside are helpers and ignored.
#   offchain/src/ZK/DSL/Properties/SetMembership.hs
#     — every top-level identifier matching `^prop_`.
#
# The mapping below is the single source of truth inside CI; it is
# a verbatim transcription of the table in contracts/properties.md.
# Diverging from the contract file is a PR-level review concern.

set -euo pipefail

# Resolve repo root: prefer ZK_LAB_ROOT, else walk up from the
# script's own directory until we find a justfile + offchain/ pair.
resolve_root() {
    if [[ -n "${ZK_LAB_ROOT:-}" ]]; then
        printf '%s\n' "$ZK_LAB_ROOT"
        return
    fi
    local d
    d=$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)
    while [[ "$d" != "/" ]]; do
        if [[ -d "$d/offchain" && -d "$d/lean" && -d "$d/specs" ]]; then
            printf '%s\n' "$d"
            return
        fi
        d=$(dirname "$d")
    done
    echo "check-property-parity: unable to locate repo root" >&2
    exit 2
}

ROOT=$(resolve_root)
LEAN_FILE="$ROOT/lean/ZKLab/SetMembership.lean"
HS_FILE="$ROOT/offchain/src/ZK/DSL/Properties/SetMembership.hs"

[[ -f "$LEAN_FILE" ]] || {
    echo "check-property-parity: missing $LEAN_FILE" >&2
    exit 2
}
[[ -f "$HS_FILE" ]] || {
    echo "check-property-parity: missing $HS_FILE" >&2
    exit 2
}

# The mapping table (P1..P6), mirrored from contracts/properties.md.
# Each entry is "LeanName=HaskellName".  Adding a property here
# requires adding a row to contracts/properties.md in the same PR.
MAPPING=(
    "completeness=prop_completeness"
    "soundness=prop_soundness"
    "zeroKnowledge=prop_zero_knowledge"
    "canonicalization=prop_canonicalization_idempotent"
    "emptyRejected=prop_empty_rejected"
    "proofUnlinkability=prop_proofs_unlinkable"
)

# Extract parity-tracked Lean theorems: names declared with
# `theorem <name>` appearing *after* the marker line
# `-- ## Parity-tracked properties ##` inside SetMembership.lean.
extract_lean_theorems() {
    awk '
        /^-- ## Parity-tracked properties ##[[:space:]]*$/ { in_section = 1; next }
        in_section && /^theorem[[:space:]]+[A-Za-z_][A-Za-z0-9_]*/ {
            match($0, /^theorem[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)/, arr)
            if (arr[1] != "") print arr[1]
        }
    ' "$LEAN_FILE" | sort -u
}

# Extract top-level Haskell property identifiers: lines whose first
# token matches `^prop_[A-Za-z0-9_]+ ::`.
extract_haskell_props() {
    grep -E '^prop_[A-Za-z0-9_]+[[:space:]]*::' "$HS_FILE" \
        | awk '{ print $1 }' | sort -u
}

LEAN_FOUND=$(extract_lean_theorems)
HS_FOUND=$(extract_haskell_props)

# Expected sets, derived from the mapping table.
EXPECTED_LEAN=$(printf '%s\n' "${MAPPING[@]}" \
    | awk -F= '{ print $1 }' | sort -u)
EXPECTED_HS=$(printf '%s\n' "${MAPPING[@]}" \
    | awk -F= '{ print $2 }' | sort -u)

fail=0

missing_in_lean=$(comm -23 <(echo "$EXPECTED_LEAN") <(echo "$LEAN_FOUND"))
extra_in_lean=$(comm -13 <(echo "$EXPECTED_LEAN") <(echo "$LEAN_FOUND"))
missing_in_hs=$(comm -23 <(echo "$EXPECTED_HS") <(echo "$HS_FOUND"))
extra_in_hs=$(comm -13 <(echo "$EXPECTED_HS") <(echo "$HS_FOUND"))

report() {
    local label=$1 payload=$2
    if [[ -n "$payload" ]]; then
        echo "  $label:" >&2
        while IFS= read -r line; do
            [[ -n "$line" ]] && echo "    - $line" >&2
        done <<<"$payload"
        fail=1
    fi
}

echo "check-property-parity: $(echo "$LEAN_FOUND" | wc -l) Lean theorem(s) / $(echo "$HS_FOUND" | wc -l) Haskell property(ies) / ${#MAPPING[@]} mapping row(s)"

report "missing in $LEAN_FILE"        "$missing_in_lean"
report "unexpected in $LEAN_FILE (helper lemmas must live outside the parity section)" "$extra_in_lean"
report "missing in $HS_FILE"          "$missing_in_hs"
report "unexpected in $HS_FILE (add a row to contracts/properties.md and update the mapping)" "$extra_in_hs"

if [[ $fail -eq 0 ]]; then
    echo "check-property-parity: OK (mapping matches contracts/properties.md)"
    exit 0
fi

echo "check-property-parity: FAIL (SC-003 drift; update Lean, Haskell, or the mapping)" >&2
exit 1
