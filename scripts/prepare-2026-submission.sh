#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage:
  ./scripts/prepare-2026-submission.sh <github-id> <problem-id> [repo]

Example:
  ./scripts/prepare-2026-submission.sh ABC T1-1-1

Environment:
  INFINITENSOR_AUTHOR_NAME  Name used in HONOR_CODE.md and REFERENCE.md.
  ALLOW_DIRTY=1             Allow branch creation in a dirty target repo.
USAGE
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage >&2
    exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GITHUB_ID="$1"
PROBLEM_ID="$2"
REPO_NAME="${3:-ntops}"
REPO_DIR="$ROOT_DIR/$REPO_NAME"
AUTHOR_NAME="${INFINITENSOR_AUTHOR_NAME:-$GITHUB_ID}"
BRANCH="2026-spring-${GITHUB_ID}-${PROBLEM_ID}"

if [ ! -d "$REPO_DIR/.git" ] && [ ! -f "$REPO_DIR/.git" ]; then
    echo "error: target repo is not a git checkout: $REPO_DIR" >&2
    exit 1
fi

if [ -n "$(git -C "$REPO_DIR" status --short)" ] && [ "${ALLOW_DIRTY:-0}" != "1" ]; then
    echo "error: $REPO_NAME has uncommitted changes. Commit/stash them or rerun with ALLOW_DIRTY=1." >&2
    git -C "$REPO_DIR" status --short >&2
    exit 1
fi

if git -C "$REPO_DIR" show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git -C "$REPO_DIR" switch "$BRANCH"
else
    git -C "$REPO_DIR" switch -c "$BRANCH"
fi

copy_template() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ]; then
        echo "keep existing: ${dst#$REPO_DIR/}"
        return
    fi

    sed \
        -e "s/__GITHUB_ID__/$GITHUB_ID/g" \
        -e "s/__PROBLEM_ID__/$PROBLEM_ID/g" \
        -e "s/__AUTHOR_NAME__/$AUTHOR_NAME/g" \
        "$src" > "$dst"
    echo "created: ${dst#$REPO_DIR/}"
}

copy_template "$ROOT_DIR/templates/competition/HONOR_CODE.md" "$REPO_DIR/HONOR_CODE.md"
copy_template "$ROOT_DIR/templates/competition/REFERENCE.md" "$REPO_DIR/REFERENCE.md"
copy_template "$ROOT_DIR/templates/competition/PR_BODY_2026.md" "$REPO_DIR/PR_BODY_2026_${PROBLEM_ID}.md"

cat <<EOF
OK: prepared $REPO_NAME for 2026 submission.

Branch:
  $BRANCH

PR title:
  [2026春季][$PROBLEM_ID] $GITHUB_ID

Next:
  1. Implement the five operators.
  2. Run focused tests and collect screenshots.
  3. Fill $REPO_NAME/PR_BODY_2026_${PROBLEM_ID}.md.
EOF

