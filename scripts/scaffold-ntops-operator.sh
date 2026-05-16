#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage:
  ./scripts/scaffold-ntops-operator.sh <op-name> <kind>

Kinds:
  unary
  binary
  reduction

Example:
  ./scripts/scaffold-ntops-operator.sh logsigmoid unary
USAGE
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ "$#" -ne 2 ]; then
    usage >&2
    exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OP_NAME="$1"
KIND="$2"
TEMPLATE_DIR="$ROOT_DIR/templates/ntops_operator"
NTOPS_DIR="$ROOT_DIR/ntops"

case "$KIND" in
    unary|binary|reduction)
        ;;
    *)
        echo "error: unsupported kind: $KIND" >&2
        usage >&2
        exit 2
        ;;
esac

if ! [[ "$OP_NAME" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    echo "error: op-name must be a valid Python identifier" >&2
    exit 2
fi

write_from_template() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ]; then
        echo "keep existing: ${dst#$ROOT_DIR/}"
        return
    fi

    sed -e "s/__OP_NAME__/$OP_NAME/g" "$src" > "$dst"
    echo "created: ${dst#$ROOT_DIR/}"
}

write_from_template "$TEMPLATE_DIR/kernel_${KIND}.py" "$NTOPS_DIR/src/ntops/kernels/${OP_NAME}.py"
write_from_template "$TEMPLATE_DIR/torch_${KIND}.py" "$NTOPS_DIR/src/ntops/torch/${OP_NAME}.py"
write_from_template "$TEMPLATE_DIR/test_${KIND}.py" "$NTOPS_DIR/tests/test_${OP_NAME}.py"

cat <<EOF
OK: scaffolded $OP_NAME ($KIND).

Manual follow-up:
  1. Replace placeholder expressions in the generated files.
  2. Register $OP_NAME in:
     - ntops/src/ntops/kernels/__init__.py
     - ntops/src/ntops/torch/__init__.py
  3. Run:
     source ./scripts/env.sh
     cd ntops
     pytest -q tests/test_${OP_NAME}.py
EOF

