#!/usr/bin/env bash
# Secure dependency management for WATCH.21. This file is sourced by
# w21 and may also be sourced by the offline tests.

W21_INSTALL_MODE="${W21_INSTALL_MODE:-}"
W21_ASSUME_YES="${W21_ASSUME_YES:-0}"
W21_DOCTOR_JSON="${W21_DOCTOR_JSON:-0}"
W21_BIN_DIR="${W21_BIN_DIR:-${HOME:-/tmp}/.local/bin}"
W21_CONFIG_DIR="${W21_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME:-/tmp}/.config}/w21}"
W21_STATE_DIR="${W21_STATE_DIR:-${XDG_STATE_HOME:-${HOME:-/tmp}/.local/state}/w21}"
W21_LOCK_FILE="${W21_LOCK_FILE:-${SCRIPT_DIR}/tools.lock.json}"
W21_FAILURES=()

# name|exe|capability|required|method|package/source|version|destination|purpose|sudo|fallbacks
dependency_catalog() {
cat <<'EOF'
bash|bash|system utilities|required|apt|bash|distro|/usr/bin|shell runtime|yes|
curl|curl|system utilities|required|apt|curl|distro|/usr/bin|secure HTTPS transfers|yes|
jq|jq|reporting|required|apt|jq|distro|/usr/bin|preferred JSON reporting|yes|python3
git|git|system utilities|required|apt|git|distro|/usr/bin|trusted source checkout|yes|
python3|python3|system utilities|required|apt|python3|distro|/usr/bin|Python runtime|yes|
pipx|pipx|system utilities|optional|apt|pipx|distro|/usr/bin|isolated Python CLI installs|yes|
go|go|system utilities|optional|apt|golang-go|distro|/usr/bin|Go toolchain|yes|
cargo|cargo|system utilities|optional|apt|cargo|distro|/usr/bin|Rust toolchain|yes|
awk|awk|system utilities|required|apt|gawk|distro|/usr/bin|text processing|yes|
sed|sed|system utilities|required|apt|sed|distro|/usr/bin|text processing|yes|
grep|grep|system utilities|required|apt|grep|distro|/usr/bin|text search|yes|rg
ripgrep|rg|system utilities|optional|apt|ripgrep|distro|/usr/bin|fast text search|yes|grep
coreutils|sort|system utilities|required|apt|coreutils|distro|/usr/bin|file and hashing utilities|yes|
util-linux|flock|system utilities|required|apt|util-linux|distro|/usr/bin|process locking|yes|
file|file|artifact and document analysis|required|apt|file|distro|/usr/bin|file type detection|yes|
strings|strings|artifact and document analysis|required|apt|binutils|distro|/usr/bin|printable string extraction|yes|
openssl|openssl|system utilities|required|apt|openssl|distro|/usr/bin|TLS and cryptographic checks|yes|
tar|tar|artifact and document analysis|required|apt|tar|distro|/usr/bin|archive handling|yes|
unzip|unzip|artifact and document analysis|required|apt|unzip|distro|/usr/bin|ZIP archive handling|yes|
7zip|7z|artifact and document analysis|optional|apt|7zip|distro|/usr/bin|7z archive inspection|yes|
poppler|pdftotext|artifact and document analysis|optional|apt|poppler-utils|distro|/usr/bin|PDF text and metadata|yes|pdfinfo
exiftool|exiftool|artifact and document analysis|optional|apt|libimage-exiftool-perl|distro|/usr/bin|document metadata|yes|
dnsutils|dig|DNS and subdomain reconnaissance|required|apt|dnsutils|distro|/usr/bin|baseline DNS queries|yes|dnsx
seclists|__seclists__|content discovery|optional|apt|seclists|distro|/usr/share/seclists|curated discovery lists|yes|
subfinder|subfinder|DNS and subdomain reconnaissance|optional|go|github.com/projectdiscovery/subfinder/v2/cmd/subfinder|v2.6.6|~/.local/bin|preferred passive enumeration|no|assetfinder,amass
assetfinder|assetfinder|DNS and subdomain reconnaissance|optional|go|github.com/tomnomnom/assetfinder|v0.1.1|~/.local/bin|passive enumeration fallback|no|subfinder,amass
amass|amass|DNS and subdomain reconnaissance|optional|apt|amass|distro|/usr/bin|passive enumeration fallback|yes|subfinder,assetfinder
dnsx|dnsx|DNS and subdomain reconnaissance|optional|go|github.com/projectdiscovery/dnsx/cmd/dnsx|v1.2.1|~/.local/bin|preferred bulk DNS resolution|no|dig,puredns,shuffledns
puredns|puredns|DNS and subdomain reconnaissance|optional|go|github.com/d3mondev/puredns/v2|v2.1.1|~/.local/bin|DNS wildcard filtering|no|shuffledns,dnsx
shuffledns|shuffledns|DNS and subdomain reconnaissance|optional|go|github.com/projectdiscovery/shuffledns/cmd/shuffledns|v1.1.0|~/.local/bin|DNS resolution fallback|no|puredns,dnsx
massdns|massdns|DNS and subdomain reconnaissance|optional|apt|massdns|distro|/usr/bin|high-volume DNS resolver|yes|dnsx
httpx|httpx|HTTP probing and crawling|optional|go|github.com/projectdiscovery/httpx/cmd/httpx|v1.6.10|~/.local/bin|preferred HTTP probing|no|curl
naabu|naabu|HTTP probing and crawling|optional|go|github.com/projectdiscovery/naabu/v2/cmd/naabu|v2.3.4|~/.local/bin|safe allowed-port discovery|no|
katana|katana|HTTP probing and crawling|optional|go|github.com/projectdiscovery/katana/cmd/katana|v1.1.2|~/.local/bin|preferred crawler|no|curl
gau|gau|URL processing|optional|go|github.com/lc/gau/v2/cmd/gau|v2.2.4|~/.local/bin|historical URL collection|no|waymore
waymore|waymore|URL processing|optional|pipx|waymore|7.8|~/.local/bin|historical URL fallback|no|gau
uro|uro|URL processing|optional|pipx|uro|1.0.2|~/.local/bin|URL normalization|no|
unfurl|unfurl|URL processing|optional|go|github.com/tomnomnom/unfurl|v0.4.3|~/.local/bin|URL component extraction|no|
anew|anew|URL processing|optional|go|github.com/tomnomnom/anew|v0.1.1|~/.local/bin|stream deduplication|no|sort
ffuf|ffuf|content discovery|optional|go|github.com/ffuf/ffuf/v2|v2.1.0|~/.local/bin|preferred content discovery|no|feroxbuster,dirsearch
feroxbuster|feroxbuster|content discovery|optional|apt|feroxbuster|distro|/usr/bin|content discovery fallback|yes|ffuf,dirsearch
dirsearch|dirsearch|content discovery|optional|pipx|dirsearch|0.4.3|~/.local/bin|content discovery fallback|no|ffuf,feroxbuster
nuclei|nuclei|Nuclei and safe vulnerability validation|optional|go|github.com/projectdiscovery/nuclei/v3/cmd/nuclei|v3.3.7|~/.local/bin|safe template validation|no|
nuclei-templates|__nuclei_templates__|Nuclei and safe vulnerability validation|optional|git|https://github.com/projectdiscovery/nuclei-templates.git|v10.1.4|~/.local/share/w21/nuclei-templates|safe Nuclei templates|no|nuclei
interactsh-client|interactsh-client|Nuclei and safe vulnerability validation|optional|go|github.com/projectdiscovery/interactsh/cmd/interactsh-client|v1.2.4|~/.local/bin|out-of-band validation|no|
subzy|subzy|Nuclei and safe vulnerability validation|optional|go|github.com/PentestPad/subzy|v1.2.0|~/.local/bin|takeover candidate validation|no|nuclei
wafw00f|wafw00f|HTTP probing and crawling|optional|pipx|wafw00f|2.3.1|~/.local/bin|WAF fingerprinting|no|
sslscan|sslscan|HTTP probing and crawling|optional|apt|sslscan|distro|/usr/bin|preferred TLS review|yes|testssl
testssl|testssl.sh|HTTP probing and crawling|optional|apt|testssl.sh|distro|/usr/bin|TLS review fallback|yes|sslscan
arjun|arjun|JavaScript and API analysis|optional|pipx|arjun|2.2.7|~/.local/bin|parameter discovery|no|
gf|gf|URL processing|optional|go|github.com/tomnomnom/gf|v0.1.0|~/.local/bin|URL pattern filtering|no|
qsreplace|qsreplace|URL processing|optional|go|github.com/tomnomnom/qsreplace|v0.0.3|~/.local/bin|query replacement|no|
linkfinder|linkfinder|JavaScript and API analysis|optional|pipx|linkfinder|1.2.0|~/.local/bin|JavaScript endpoint extraction|no|jsluice
secretfinder|SecretFinder|JavaScript and API analysis|optional|pipx|secretfinder|1.2.0|~/.local/bin|secret candidate discovery|no|jsluice
jsluice|jsluice|JavaScript and API analysis|optional|go|github.com/BishopFox/jsluice/cmd/jsluice|v1.0.0|~/.local/bin|preferred JavaScript analysis|no|linkfinder,secretfinder
sqlmap|sqlmap|optional manual-review tools|manual|apt|sqlmap|distro|/usr/bin|manual SQL injection review only|yes|
tplmap|tplmap|optional manual-review tools|manual|pipx|tplmap|0.5|~/.local/bin|manual template injection review only|no|
xsstrike|xsstrike|optional manual-review tools|manual|pipx|xsstrike|3.1.5|~/.local/bin|manual XSS review only|no|
EOF
}

detect_platform() {
    local kernel id="" like=""
    kernel=$(uname -s 2>/dev/null || printf unknown)
    if [[ -r "${W21_OS_RELEASE:-/etc/os-release}" ]]; then
        id=$(sed -n 's/^ID=//p' "${W21_OS_RELEASE:-/etc/os-release}" | tr -d '"' | head -n1)
        like=$(sed -n 's/^ID_LIKE=//p' "${W21_OS_RELEASE:-/etc/os-release}" | tr -d '"' | head -n1)
    fi
    case "${kernel}" in
        *MINGW*|*MSYS*|*CYGWIN*) printf 'windows'; return;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then printf 'wsl'; return; fi
            [[ "${id}" == kali ]] && { printf 'kali'; return; }
            [[ "${id}" == debian || " ${like} " == *' debian '* ]] && { printf 'debian'; return; }
            printf 'linux-unsupported';;
        *) printf 'unsupported';;
    esac
}

installer_supported() { local p; p=$(detect_platform); [[ "${p}" == kali || "${p}" == debian ]]; }

find_outside_path() {
    local exe="$1" candidate
    for candidate in "${W21_BIN_DIR}/${exe}" "/usr/local/bin/${exe}" "${HOME:-/nonexistent}/go/bin/${exe}"; do
        [[ -x "${candidate}" ]] && { printf '%s' "${candidate}"; return 0; }
    done
    return 1
}

tool_version() {
    local exe="$1" out
    out=$("${exe}" --version 2>&1 | head -n1) || out=$("${exe}" -version 2>&1 | head -n1) || out=$("${exe}" version 2>&1 | head -n1) || out="version unavailable"
    printf '%s' "${out//$'\r'/}"
}

tool_status() {
    local exe="$1" required="$2" requested="$3" path="" version=""
    if [[ "${exe}" == __seclists__ ]]; then
        for path in "${SECLISTS_DIR:-}" /usr/share/seclists /usr/share/wordlists/seclists "${HOME:-/nonexistent}/.local/share/seclists"; do
            [[ -n "${path}" && -d "${path}" ]] && { printf 'installed|%s|directory' "${path}"; return; }
        done
    elif [[ "${exe}" == __nuclei_templates__ ]]; then
        for path in "${HOME:-/nonexistent}/nuclei-templates" "${HOME:-/nonexistent}/.local/nuclei-templates" "${HOME:-/nonexistent}/.local/share/w21/nuclei-templates"; do
            [[ -d "${path}" ]] && { version=$(git -C "${path}" describe --tags --always 2>/dev/null || printf unknown); printf 'installed|%s|%s' "${path}" "${version}"; return; }
        done
    elif path=$(command -v "${exe}" 2>/dev/null); then
        path=$(readlink -f "${path}" 2>/dev/null || printf '%s' "${path}")
        if [[ ! -x "${path}" ]]; then printf 'broken|%s|not executable' "${path}"; return; fi
        version=$(tool_version "${path}")
        [[ "${version}" == 'version unavailable' ]] && { printf 'broken|%s|%s' "${path}" "${version}"; return; }
        if [[ "${requested}" != distro && "${requested}" != latest && "${version}" != *"${requested#v}"* ]]; then
            printf 'outdated|%s|%s' "${path}" "${version}"
        else printf 'installed|%s|%s' "${path}" "${version}"; fi
        return
    elif path=$(find_outside_path "${exe}"); then printf 'installed but not in PATH|%s|%s' "${path}" "$(tool_version "${path}")"; return
    fi
    installer_supported || { printf 'unsupported||platform %s' "$(detect_platform)"; return; }
    [[ "${required}" == required ]] && printf 'missing required||' || printf 'missing optional||'
}

json_escape() { local s="$1"; s=${s//\\/\\\\}; s=${s//\"/\\\"}; s=${s//$'\n'/\\n}; printf '%s' "$s"; }

run_dependency_doctor() {
    local json="${1:-0}" platform first=1 row name exe cap req method source ver dest purpose sudo fallbacks status path detected
    platform=$(detect_platform)
    [[ "${json}" == 1 ]] && printf '{"platform":"%s","dependencies":[' "$(json_escape "${platform}")" || printf '=== WATCH.21 DOCTOR ===\nPlatform: %s\ndependencies (preferred tools and capability fallbacks):\n' "${platform}"
    while IFS='|' read -r name exe cap req method source ver dest purpose sudo fallbacks; do
        IFS='|' read -r status path detected <<< "$(tool_status "${exe}" "${req}" "${ver}")"
        if [[ "${json}" == 1 ]]; then
            (( first )) || printf ','; first=0
            printf '{"tool":"%s","capability":"%s","requirement":"%s","status":"%s","path":"%s","version":"%s","fallbacks":"%s"}' "$(json_escape "$name")" "$(json_escape "$cap")" "$req" "$(json_escape "$status")" "$(json_escape "$path")" "$(json_escape "$detected")" "$(json_escape "$fallbacks")"
        else printf '%-22s %-24s %-34s %s%s\n' "$name" "$status" "$cap" "${path:-—}" "${detected:+ — $detected}"; fi
    done < <(dependency_catalog)
    [[ "${json}" == 1 ]] && printf ']}\n' || {
        printf 'CRLF: '; grep -Iq $'\r' "${SCRIPT_DIR}/w21" && printf 'detected; run: sed -i '\''s/\\r$//'\'' w21\n' || printf 'not detected (LF OK)\n'
        [[ -x "${SCRIPT_DIR}/w21" ]] && printf 'Executable permission: OK\n' || printf 'Executable permission: missing; run: chmod +x w21\n'
        printf 'Available disk space: %sK\n' "$(df -Pk "${SCRIPT_DIR}" | awk 'NR==2 {print $4}')"
    }
}

want_tool_for_mode() { local req="$1"; case "${W21_INSTALL_MODE}" in required) [[ "$req" == required ]];; optional) [[ "$req" == optional ]];; missing|update) [[ "$req" != manual ]];; *) return 1;; esac; }

print_install_plan() {
    local row name exe cap req method source ver dest purpose sudo fallbacks status path detected action
    printf 'Operating system: %s\n' "$(detect_platform)"
    printf '%-20s %-9s %-12s %-8s %-24s %-10s %s\n' TOOL TYPE METHOD SUDO DESTINATION VERSION PURPOSE
    while IFS='|' read -r name exe cap req method source ver dest purpose sudo fallbacks; do
        [[ "$req" != manual ]] || continue
        IFS='|' read -r status path detected <<< "$(tool_status "$exe" "$req" "$ver")"
        action=skip
        if [[ "${W21_INSTALL_MODE:-missing}" == update ]]; then [[ "$status" == outdated ]] && action=upgrade
        elif want_tool_for_mode "$req" && [[ "$status" == missing* || "$status" == broken ]]; then action=install; fi
        [[ "$action" != skip ]] && printf '%-20s %-9s %-12s %-8s %-24s %-10s %s\n' "$name" "$req" "$method" "$sudo" "$dest" "$ver" "$purpose"
    done < <(dependency_catalog)
}

confirm_action() { local prompt="$1"; [[ "${W21_ASSUME_YES}" == 1 ]] && return 0; [[ -t 0 ]] || return 1; read -r -p "${prompt} [y/N] " reply; [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; }

run_apt() {
    local package="$1"
    if [[ "${W21_APT_UPDATED:-0}" != 1 ]]; then confirm_action 'Run apt update?' || return 20; "${W21_SUDO:-sudo}" apt-get update || return; W21_APT_UPDATED=1; fi
    confirm_action "Install apt package ${package}?" || return 20
    "${W21_SUDO:-sudo}" apt-get install -y --no-install-recommends "${package}"
}

ensure_bin_path() {
    mkdir -p "${W21_BIN_DIR}"
    case ":${PATH}:" in *":${W21_BIN_DIR}:"*) return;; esac
    confirm_action "Add ${W21_BIN_DIR} to PATH in ~/.profile?" || return 20
    printf '\n# WATCH.21 user tools\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "${HOME}/.profile"
    PATH="${W21_BIN_DIR}:${PATH}"; export PATH
}

run_go_install() {
    local module="$1" version="$2" exe="$3" tmp
    command -v go >/dev/null || { printf 'Go is required to install %s\n' "$exe" >&2; return 1; }
    ensure_bin_path || return
    tmp=$(mktemp -d); GOBIN="$tmp" go install "${module}@${version}" || { rm -rf "$tmp"; return 1; }
    [[ -x "$tmp/$exe" ]] || { rm -rf "$tmp"; return 1; }
    [[ ! -e "${W21_BIN_DIR}/${exe}" ]] || { confirm_action "Replace existing ${exe} binary?" || { rm -rf "$tmp"; return 20; }; cp -p "${W21_BIN_DIR}/${exe}" "${W21_BIN_DIR}/${exe}.rollback"; }
    chmod 755 "$tmp/$exe"; mv -f "$tmp/$exe" "${W21_BIN_DIR}/${exe}.new"; mv -f "${W21_BIN_DIR}/${exe}.new" "${W21_BIN_DIR}/${exe}"; rm -rf "$tmp"
}

run_pipx_install() { local package="$1" version="$2"; command -v pipx >/dev/null || return 1; PIPX_BIN_DIR="${W21_BIN_DIR}" pipx install "${package}==${version}"; }
run_cargo_install() { local crate="$1" version="$2"; command -v cargo >/dev/null || return 1; cargo install --locked --root "${HOME}/.local" --version "${version#v}" "$crate"; }

run_git_install() {
    local url="$1" version="$2" dest="$3" real_dest
    command -v git >/dev/null || return 1; confirm_action "Clone ${url} at ${version}?" || return 20
    real_dest=${dest/#\~/$HOME}; mkdir -p "$(dirname "$real_dest")"
    [[ ! -e "$real_dest" ]] || { confirm_action "Replace existing checkout ${real_dest}?" || return 20; mv "$real_dest" "${real_dest}.rollback"; }
    git clone --filter=blob:none --depth 1 --branch "$version" -- "$url" "${real_dest}.new" || return
    mv "${real_dest}.new" "$real_dest"
}

# Generic verified official binary handler. Catalog additions use source as
# HTTPS archive URL and version as sha256:<digest>. Redirects are refused so a
# trusted release host cannot redirect to a different host; archive members are
# traversal-checked.
run_binary_install() {
    local url="$1" checksum="$2" exe="$3" tmp member digest
    [[ "$url" == https://* && "$checksum" == sha256:* ]] || return 1
    tmp=$(mktemp -d); curl --fail --show-error --silent --max-redirs 0 --proto '=https' -o "$tmp/archive" "$url" || { rm -rf "$tmp"; return 1; }
    digest=$(sha256sum "$tmp/archive" | awk '{print $1}'); [[ "$digest" == "${checksum#sha256:}" ]] || { printf 'checksum mismatch for %s\n' "$exe" >&2; rm -rf "$tmp"; return 1; }
    file "$tmp/archive" | grep -Eq 'tar archive|gzip compressed|Zip archive' || { rm -rf "$tmp"; return 1; }
    if unzip -Z1 "$tmp/archive" >/dev/null 2>&1; then unzip -Z1 "$tmp/archive" > "$tmp/list"; else tar -tf "$tmp/archive" > "$tmp/list"; fi
    grep -Eq '(^/|(^|/)\.\.(/|$))' "$tmp/list" && { rm -rf "$tmp"; return 1; }
    mkdir "$tmp/out"; if unzip -Z1 "$tmp/archive" >/dev/null 2>&1; then unzip -q "$tmp/archive" -d "$tmp/out"; else tar -xf "$tmp/archive" -C "$tmp/out"; fi
    member=$(find "$tmp/out" -type f -name "$exe" -print -quit); [[ -n "$member" ]] || { rm -rf "$tmp"; return 1; }
    ensure_bin_path || return; [[ ! -e "${W21_BIN_DIR}/${exe}" ]] || cp -p "${W21_BIN_DIR}/${exe}" "${W21_BIN_DIR}/${exe}.rollback"
    install -m 0755 "$member" "${W21_BIN_DIR}/${exe}.new"; mv -f "${W21_BIN_DIR}/${exe}.new" "${W21_BIN_DIR}/${exe}"; rm -rf "$tmp"
}

save_detected_manifest() {
    mkdir -p "${W21_STATE_DIR}"; local out="${W21_STATE_DIR}/tools.lock.json" first=1 name exe cap req method source ver dest purpose sudo fallbacks status path detected
    printf '{"schema":1,"updated_at":"%s","tools":[' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$out.tmp"
    while IFS='|' read -r name exe cap req method source ver dest purpose sudo fallbacks; do IFS='|' read -r status path detected <<< "$(tool_status "$exe" "$req" "$ver")"; ((first)) || printf ',' >> "$out.tmp"; first=0; printf '{"tool":"%s","source":"%s","install_method":"%s","tested_version":"%s","executable":"%s","checksum":null,"installation_timestamp":"%s","detected_version":"%s","upgrade_status":"%s"}' "$(json_escape "$name")" "$(json_escape "$source")" "$method" "$ver" "$exe" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(json_escape "$detected")" "$(json_escape "$status")" >> "$out.tmp"; done < <(dependency_catalog)
    printf ']}\n' >> "$out.tmp"; mv "$out.tmp" "$out"
    mkdir -p "${W21_CONFIG_DIR}"
    local seclists_path=""
    for seclists_path in "${SECLISTS_DIR:-}" /usr/share/seclists /usr/share/wordlists/seclists "${HOME:-/nonexistent}/.local/share/seclists"; do
        [[ -n "$seclists_path" && -d "$seclists_path" ]] && { printf 'SECLISTS_DIR=%q\n' "$seclists_path" > "${W21_CONFIG_DIR}/paths.conf.tmp"; mv "${W21_CONFIG_DIR}/paths.conf.tmp" "${W21_CONFIG_DIR}/paths.conf"; break; }
    done
}

run_installation() {
    installer_supported || { printf 'Installation is supported only inside Kali Linux or Debian. Detected: %s. Copy the project to Kali/Debian, convert CRLF if needed, chmod +x w21, then rerun.\n' "$(detect_platform)" >&2; return 2; }
    [[ "${EUID}" -ne 0 ]] || { printf 'Do not run WATCH.21 as root. Log in as a normal user; sudo is requested only for apt operations.\n' >&2; return 2; }
    print_install_plan; confirm_action 'Proceed with this installation plan?' || { printf 'Installation declined; nothing changed.\n'; return 0; }
    mkdir -p "${W21_STATE_DIR}"; : > "${W21_STATE_DIR}/install-errors.log"
    local name exe cap req method source ver dest purpose sudo fallbacks status path detected rc=0 action
    while IFS='|' read -r name exe cap req method source ver dest purpose sudo fallbacks; do
        [[ "$req" != manual ]] || continue; want_tool_for_mode "$req" || continue
        IFS='|' read -r status path detected <<< "$(tool_status "$exe" "$req" "$ver")"
        if [[ "$W21_INSTALL_MODE" == update ]]; then [[ "$status" == outdated ]] || continue; else [[ "$status" == missing* || "$status" == broken ]] || continue; fi
        printf 'Installing %s...\n' "$name"
        if { case "$method" in apt) run_apt "$source";; go) run_go_install "$source" "$ver" "$exe";; pipx) run_pipx_install "$source" "$ver";; cargo) run_cargo_install "$source" "$ver";; git) run_git_install "$source" "$ver" "$dest";; binary) run_binary_install "$source" "$ver" "$exe";; *) printf 'unsupported installation method: %s\n' "$method" >&2; false;; esac; } 2> >(tee -a "${W21_STATE_DIR}/install-errors.log" >&2); then action=0; else action=$?; fi
        if (( action != 0 && action != 20 )); then printf 'ERROR %s: installation failed with exit %s (details: %s)\n' "$name" "$action" "${W21_STATE_DIR}/install-errors.log" >&2; W21_FAILURES+=("$name"); rc=1; fi
    done < <(dependency_catalog)
    save_detected_manifest
    if ((${#W21_FAILURES[@]})); then printf 'Failed tools: %s\nRetry: ./w21 --install-missing\n' "${W21_FAILURES[*]}" >&2; fi
    # A required capability may have fallbacks; only fail when none is present.
    local missing_required=0
    while IFS='|' read -r name exe cap req method source ver dest purpose sudo fallbacks; do [[ "$req" == required ]] || continue; IFS='|' read -r status path detected <<< "$(tool_status "$exe" "$req" "$ver")"; [[ "$status" == installed* || "$status" == outdated ]] || missing_required=1; done < <(dependency_catalog)
    (( missing_required == 0 )) || return 4
    return "$rc"
}
