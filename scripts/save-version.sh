#!/usr/bin/env bash
set -euo pipefail

message="${1:-}"

if [[ -z "$message" ]]; then
  echo "Usage: ./scripts/save-version.sh \"Describe this version\""
  exit 1
fi

git add -A

if git diff --cached --quiet; then
  echo "No changes to save."
  exit 0
fi

git commit -m "$message"

if git remote get-url origin >/dev/null 2>&1; then
  git push
else
  echo "Saved locally. Add a remote repository before pushing."
fi
