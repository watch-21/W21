#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf -- "${TEST_DIR}"' EXIT

DATA_DIR="${TEST_DIR}/share/w21"
BIN_DIR="${TEST_DIR}/bin"
mkdir -p "${DATA_DIR}/lib" "${BIN_DIR}"

install -m 0755 "${ROOT}/w21" "${DATA_DIR}/w21"
install -m 0644 "${ROOT}/lib/dependency-installer.sh" \
    "${DATA_DIR}/lib/dependency-installer.sh"
install -m 0644 "${ROOT}/tools.lock.json" "${DATA_DIR}/tools.lock.json"
ln -s "${DATA_DIR}/w21" "${BIN_DIR}/w21"

"${BIN_DIR}/w21" --version | grep -q 'w21 version 0.1.0-alpha'
"${BIN_DIR}/w21" --doctor --json \
    | jq -e '.platform and (.dependencies | type == "array")' >/dev/null

printf 'Installed symlink layout: passed\n'
