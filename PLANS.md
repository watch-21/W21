# WATCH.21 implementation plan

## Current state

`0.1.0-alpha` is the public Bash foundation. Branding, repository layout,
documentation, local installation, and offline regression tests are in place.
The known engine limitations remain documented in
`docs/KNOWN_LIMITATIONS.md`.

## Milestone 1 — Python foundation

Status: pending

Acceptance criteria:

- Installable `watch21` Python package with `w21` CLI
- Typed target parser and fail-closed Scope Engine
- Exact/wildcard/apex/exclusion/path/port/IP/CIDR/IDNA tests
- SQLite schema migrations and atomic project initialization
- Structured JSONL logs and deterministic identifiers
- Dry-run proven to issue zero network requests
- Bash command retained as a deprecated compatibility path

## Milestone 2 — Coordinator and workers

Status: pending

- Durable queue, atomic leases, heartbeats, crash recovery, and retries
- Shared global/per-host rate budgets
- Pause, resume, cancel, retry, and multi-terminal status

## Milestone 3 — Adapters and discovery

Status: pending

- Versioned adapter contract and parser fixtures
- Scope-filtered inputs and outputs for every external tool
- Provenance-preserving URL normalization, discovery, and wordlists

## Milestone 4 — Validation and evidence

Status: pending

- Explicit candidate, inconclusive, rejected, and confirmed states
- Repeated non-destructive validation and redacted evidence bundles
- Stable deduplication fingerprints

## Milestone 5 — Reports and release hardening

Status: pending

- Internally consistent JSON, JSONL, Markdown, and HTML reports
- Local end-to-end lab, installer verification, and migration tooling
- Reproducible release artifacts and honest stable-release checklist
