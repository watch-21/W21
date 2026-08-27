#!/usr/bin/env bash
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT_DIR=$ROOT
source "$ROOT/lib/dependency-installer.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok() { if "$@"; then printf 'ok - %s\n' "$*"; ((pass++)); else printf 'not ok - %s\n' "$*"; ((fail++)); fi; }
has() { grep -q -- "$2" "$1"; }

printf 'ID=kali\nID_LIKE=debian\n' > "$T/kali"; W21_OS_RELEASE=$T/kali
ok test "$(detect_platform)" = kali
printf 'ID=debian\n' > "$T/debian"; W21_OS_RELEASE=$T/debian
ok test "$(detect_platform)" = debian
mkdir "$T/bin"; printf '#!/bin/sh\nprintf MINGW64_NT\n' > "$T/bin/uname"; chmod +x "$T/bin/uname"
ok test "$(PATH="$T/bin:$PATH" detect_platform)" = windows

IFS='|' read -r st path ver <<< "$(tool_status bash required distro)"
ok test "$st" = installed
IFS='|' read -r st path ver <<< "$(tool_status definitely-not-a-tool required distro)"
ok test "$st" = 'missing required'
IFS='|' read -r st path ver <<< "$(tool_status definitely-not-a-tool optional distro)"
ok test "$st" = 'missing optional'

W21_BIN_DIR=$T/outside; mkdir -p "$W21_BIN_DIR"; printf '#!/bin/sh\necho 1.0\n' > "$W21_BIN_DIR/offpath"; chmod +x "$W21_BIN_DIR/offpath"
IFS='|' read -r st path ver <<< "$(tool_status offpath optional distro)"
ok test "$st" = 'installed but not in PATH'

tool_version "$T/outside/offpath" > "$T/version"
ok has "$T/version" 1.0
W21_INSTALL_MODE=missing; print_install_plan > "$T/plan"
ok has "$T/plan" TOOL
ok has "$T/plan" PURPOSE

W21_ASSUME_YES=0
if confirm_action 'decline'; then false; else true; fi; ok test $? -eq 0
W21_ASSUME_YES=1; ok confirm_action accepted

# Mock apt failure: no network or real package manager is invoked.
printf '#!/bin/sh\nexit 42\n' > "$T/bin/sudo"; chmod +x "$T/bin/sudo"; W21_SUDO=$T/bin/sudo; W21_ASSUME_YES=1; W21_APT_UPDATED=0
run_apt fake-package >/dev/null 2>&1; ok test $? -eq 42

# Checksum mismatch is rejected before extraction/installation.
printf x > "$T/archive"; curl() { local prev= arg= out=; for arg in "$@"; do [[ "$prev" == -o ]] && out=$arg; prev=$arg; done; cp "$T/archive" "$out"; }; export -f curl
run_binary_install https://github.com/example/tool.tar.gz sha256:0000 fake > "$T/checksum" 2>&1; ok test $? -ne 0
ok has "$T/checksum" 'checksum mismatch'

# Failed/interrupted build leaves the working binary untouched.
W21_BIN_DIR=$T/atomic; mkdir -p "$W21_BIN_DIR"; printf '#!/bin/sh\necho old\n' > "$W21_BIN_DIR/demo"; chmod +x "$W21_BIN_DIR/demo"
go() { return 130; }; export -f go; run_go_install example.invalid/demo v1 demo >/dev/null 2>&1; ok test "$($W21_BIN_DIR/demo)" = old

# Successful replacement is atomic and retains a rollback copy.
go() { local dst=${GOBIN}; printf '#!/bin/sh\necho new\n' > "$dst/demo"; chmod +x "$dst/demo"; }; export -f go
run_go_install example.invalid/demo v1 demo >/dev/null 2>&1
ok test "$($W21_BIN_DIR/demo)" = new
ok test "$($W21_BIN_DIR/demo.rollback)" = old

# Repeated detection reports installed and therefore plans no reinstall for a
# synthetic catalog row (the production loop uses this same predicate).
IFS='|' read -r st path ver <<< "$(tool_status demo optional distro)"; ok test "$st" = installed

# Diagnostics must be JSON, secret-free, and installation must not mention or
# invoke reconnaissance phases.
W21_OS_RELEASE=$T/debian; run_dependency_doctor 1 > "$T/doctor.json"
ok jq -e '.platform == "debian" and (.dependencies|length > 20)' "$T/doctor.json"
ok sh -c "! grep -Eiq '(token|password|api[_-]?key)' '$T/doctor.json'"
W21_INSTALL_MODE=missing; print_install_plan > "$T/install-output"
ok sh -c "! grep -q 'Executing reconnaissance phases' '$T/install-output'"

printf '\nOffline installer tests: %s passed, %s failed\n' "$pass" "$fail"
((fail == 0))
