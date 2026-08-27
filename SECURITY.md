# Security policy

## Supported version

WATCH.21 is currently an alpha project. Security fixes are applied to the
default branch; no stable release line is supported yet.

## Reporting a vulnerability in WATCH.21

Use GitHub private vulnerability reporting when it is available. If it is not
available, open a minimal issue requesting a private contact channel. Do not
publish exploit details, credentials, tokens, private targets, or scan evidence
in a public issue.

Include the affected revision, operating system, reproduction conditions,
impact, and a minimal redacted proof.

## Operational safety

- Use WATCH.21 only with explicit authorization.
- Review scope and exclusions before network activity.
- Start with `--dry-run` and the `safe` profile.
- Run as a normal user, never as root.
- Keep TLS verification enabled unless a controlled lab requires otherwise.
- Treat every tool result as a candidate until independently verified.
- Redact credentials and sensitive response data before sharing reports.
