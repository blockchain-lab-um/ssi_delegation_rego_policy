#!/usr/bin/env bash
set -euo pipefail

POLICY="policy/delegation.rego"
QUERY='data.delegation.allow'

for f in inputs/*.json; do
  result=$(opa eval -d "$POLICY" -i "$f" "$QUERY" -f json | jq -r '.result[0].expressions[0].value')
  printf "%-40s  allow=%s\n" "$(basename "$f")" "$result"
done
