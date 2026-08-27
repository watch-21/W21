# WATCH.21 (`w21`)

> Scope-first reconnaissance orchestration for authorized security testing on Kali Linux.

[![CI](https://github.com/watch-21/w21/actions/workflows/ci.yml/badge.svg)](https://github.com/watch-21/w21/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-alpha-orange.svg)](docs/KNOWN_LIMITATIONS.md)

WATCH.21 is a Bash-based orchestration tool that coordinates staged asset
discovery, URL collection, bounded content discovery, Nuclei candidate
collection, validation, evidence handling, and reporting. Its primary command
is `w21`.

**Current status: alpha.** The project is being migrated toward a Python
coordinator/worker engine. Review the [known limitations](docs/KNOWN_LIMITATIONS.md)
before any network-enabled run. Never use WATCH.21 on systems you do not own or
have explicit permission to test.

## Verified in this release

- Main offline suite: **37 passed, 0 failed, 1 skipped**
- Dependency-installer suite: **22 passed, 0 failed**
- Installed-command layout and symlink resolution: passed
- Bash syntax, dry-run no-network assertion, and sensitive-pattern scan: passed

## What this alpha includes

- Exact-host, wildcard, and exclusion scope inputs with normalized artifacts
- 26 checkpointed phases and resumable result directories
- Safe and standard profiles with rate, concurrency, timeout, runtime, request,
  and artifact-size limits
- Passive discovery, DNS/HTTP probing, crawling, historical URL collection,
  target-specific wordlists, bounded fuzzing, and Nuclei adapters
- Candidate/validation/report stages with raw and normalized artifacts
- `--doctor`, machine-readable diagnostics, dependency plans, and pinned tool
  metadata
- Offline test fixtures; the default test suite does not scan public targets

## Planned, not yet complete

The Python coordinator, shared multi-worker budgets, request-level centralized
Scope Engine, durable crash recovery, and strict independent finding validation
are roadmap items. The Bash alpha must not be presented as if those parts are
already finished. See [Known limitations](docs/KNOWN_LIMITATIONS.md) and
[Implementation plan](PLANS.md).

## Requirements

- Kali Linux or Debian for managed dependency installation
- Bash 4.4+
- Core runtime commands: `curl`, `jq`, `flock`, `sha256sum`, `sort`, `awk`,
  `sed`, and `grep`
- A normal user account. Network-enabled runs are rejected as root.

Reconnaissance tools are optional by capability. Use `w21 --doctor` to see what
is installed and `w21 --print-install-plan` before changing the system.

## Download

```bash
git clone https://github.com/watch-21/W21.git w21
cd w21
chmod +x w21 install.sh
./w21 --doctor
```

## Install the `w21` command

The installer copies WATCH.21 into `~/.local/share/w21` and creates the command
`~/.local/bin/w21`. It does not install reconnaissance dependencies and does
not start a scan.

```bash
./install.sh
export PATH="$HOME/.local/bin:$PATH"
w21 --version
w21 --doctor
```

To preview or install missing external tools on Kali/Debian:

```bash
w21 --print-install-plan
w21 --install-missing
# Non-interactive confirmation, only after reviewing the plan:
w21 --install-missing --yes
```

Use `PREFIX=/custom/path ./install.sh` for a different user-owned prefix.

## First safe run

Start with a dry-run. It creates a plan but sends no network requests.

```bash
w21 --target example.com --profile safe --dry-run
```

For a network-enabled run against an explicitly authorized target:

```bash
w21 \
  --target example.com \
  --profile safe \
  --rate-limit 5 \
  --concurrency 2 \
  --output results/example.com
```

Useful commands:

```bash
w21 --help
w21 --doctor
w21 --doctor --json
w21 --targets targets.txt --dry-run
w21 --scope scope.txt --dry-run
w21 --resume --output results/example.com
```

## Scope semantics

Scope is a hard safety boundary, not a discovery suggestion.

| Rule | Meaning |
|---|---|
| `example.com` | Exact host only |
| `*.example.com` | Subdomains only; the apex is not implied |
| `!admin.example.com` | Exclusion; exclusions win |

Use [scope.example.txt](scope.example.txt) as a starting point. Keep exact
hosts and wildcard rules separate. Because request-level enforcement is still
being hardened, review the effective scope artifact and use conservative limits
before any authorized network run.

## Results

Each scan keeps state, scope artifacts, raw and normalized observations,
wordlists, evidence, logs, and reports beneath its output directory. Existing
result directories are not intentionally deleted during normal operation.

## Development and verification

```bash
bash -n w21 lib/dependency-installer.sh install.sh
./tests.sh
./tests/offline-installer-tests.sh
./tests/install-layout-tests.sh
```

See the [roadmap](ROADMAP.md), [implementation plan](PLANS.md),
[migration guide](docs/MIGRATION.md), and
[security policy](SECURITY.md) before contributing.

## Responsible use

WATCH.21 is provided for defensive research and explicitly authorized security
testing. You are responsible for written authorization, scope, rate limits,
data handling, and compliance with applicable law and program rules. The
project does not grant permission to test any third-party system.

## License

Apache License 2.0. See [LICENSE](LICENSE).
