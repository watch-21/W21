#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PREFIX="${PREFIX:-${HOME:?HOME is required}/.local}"
DATA_DIR="${INSTALL_PREFIX}/share/w21"
BIN_DIR="${INSTALL_PREFIX}/bin"
COMMAND_PATH="${BIN_DIR}/w21"
INSTALLED_COMMAND="${DATA_DIR}/w21"

if [[ ${EUID} -eq 0 ]]; then
    printf 'Do not install WATCH.21 as root. Use a normal user account.\n' >&2
    exit 2
fi

if [[ -e "${COMMAND_PATH}" && ! -L "${COMMAND_PATH}" ]]; then
    printf 'Refusing to replace existing non-symlink: %s\n' "${COMMAND_PATH}" >&2
    exit 3
fi

if [[ -L "${COMMAND_PATH}" ]]; then
    current_target="$(readlink "${COMMAND_PATH}")"
    if [[ "${current_target}" != "${INSTALLED_COMMAND}" ]]; then
        printf 'Refusing to replace symlink to another program: %s -> %s\n' \
            "${COMMAND_PATH}" "${current_target}" >&2
        exit 3
    fi
fi

install -d -m 0755 "${DATA_DIR}/lib" "${BIN_DIR}"
install -m 0755 "${SCRIPT_DIR}/w21" "${INSTALLED_COMMAND}"
install -m 0644 "${SCRIPT_DIR}/lib/dependency-installer.sh" \
    "${DATA_DIR}/lib/dependency-installer.sh"
install -m 0644 "${SCRIPT_DIR}/tools.lock.json" "${DATA_DIR}/tools.lock.json"
install -m 0644 "${SCRIPT_DIR}/w21.conf.example" "${DATA_DIR}/w21.conf.example"
install -m 0644 "${SCRIPT_DIR}/scope.example.txt" "${DATA_DIR}/scope.example.txt"

if [[ ! -L "${COMMAND_PATH}" ]]; then
    ln -s "${INSTALLED_COMMAND}" "${COMMAND_PATH}"
fi

printf 'WATCH.21 installed: %s\n' "${COMMAND_PATH}"
case ":${PATH}:" in
    *":${BIN_DIR}:"*) ;;
    *) printf 'Add to PATH: export PATH="%s:$PATH"\n' "${BIN_DIR}" ;;
esac
printf 'Next: w21 --doctor\n'
