# W21
WATCH.21 (w21)
Scope-first reconnaissance orchestration for authorized security testing on Kali Linux.
� � �
WATCH.21 is a Bash-based orchestration tool that coordinates staged asset discovery, URL collection, bounded content discovery, Nuclei candidate collection, validation, evidence handling, and reporting. Its primary command is w21.
Current status: alpha. The project is being migrated toward a Python coordinator/worker engine. Review the known limitations before any network-enabled run. Never use WATCH.21 on systems you do not own or have explicit permission to test.
Highlights
Exact-host and wildcard scope inputs with explicit exclusions
26 checkpointed phases and resumable result directories
Safe and standard profiles with rate, concurrency, timeout, runtime, request, and artifact-size limits
Passive discovery, DNS/HTTP probing, crawling, historical URL collection, target-specific wordlists, bounded fuzzing, and Nuclei adapters
Candidate/validation/report stages with raw and normalized artifacts
--doctor, machine-readable diagnostics, dependency plans, and pinned tool metadata
Offline test fixtures; the default test suite does not scan public targets
Requirements
Kali Linux or Debian for managed dependency installation
Bash 4.4+
Core runtime commands: curl, jq, flock, sha256sum, sort, awk, sed, and grep
A normal user account. Network-enabled runs are rejected as root.
Reconnaissance tools are optional by capability. Use w21 --doctor to see what is installed and w21 --print-install-plan before changing the system.
Download
git clone https://github.com/watch-21/w21.git
cd w21
chmod +x w21 install.sh
./w21 --doctor
Install the w21 command
The installer copies WATCH.21 into ~/.local/share/w21 and creates the command ~/.local/bin/w21. It does not install reconnaissance dependencies and does not start a scan.
./install.sh
export PATH="$HOME/.local/bin:$PATH"
w21 --version
w21 --doctor
To preview or install missing external tools on Kali/Debian:
w21 --print-install-plan
w21 --install-missing
# Non-interactive confirmation, only after reviewing the plan:
w21 --install-missing --yes
Use PREFIX=/custom/path ./install.sh for a different user-owned prefix.
First safe run
Start with a dry-run. It creates a plan but sends no network requests.
w21 --target example.com --profile safe --dry-run
For a network-enabled run against an explicitly authorized target:
w21 \
  --target example.com \
  --profile safe \
  --rate-limit 5 \
  --concurrency 2 \
  --output results/example.com
Useful commands:
w21 --help
w21 --doctor
w21 --doctor --json
w21 --targets targets.txt --dry-run
w21 --scope scope.txt --dry-run
w21 --resume --output results/example.com
Scope semantics
Scope is a hard safety boundary, not a discovery suggestion.
example.com          # exact host only
*.example.com        # subdomains only; apex is not implied
!admin.example.com   # exclusion wins
Use scope.example.txt as a starting point. Keep exact hosts and wildcard rules separate and review the effective scope artifact before a real run.
Results
Each scan keeps state, scope artifacts, raw and normalized observations, wordlists, evidence, logs, and reports beneath its output directory. Existing result directories are not intentionally deleted during normal operation.
Development and verification
bash -n w21 lib/dependency-installer.sh install.sh
./tests.sh
./tests/offline-installer-tests.sh
./tests/install-layout-tests.sh
See the roadmap, implementation plan, migration guide, and security policy before contributing.
Responsible use
WATCH.21 is provided for defensive research and explicitly authorized security testing. You are responsible for written authorization, scope, rate limits, data handling, and compliance with applicable law and program rules. The project does not grant permission to test any third-party system.
License
Apache License 2.0. See LICENSE.
