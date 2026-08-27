# Changelog

All notable WATCH.21 changes are documented here.

## 0.1.0-alpha — 2026-08-27

- Renamed the public command and repository identity to `w21` / WATCH.21.
- Reorganized the development snapshot into a clean repository layout.
- Renamed configuration, state, and dependency environment prefixes to `W21`.
- Added a user-local installer, CI workflow, security policy, Arabic quick start,
  public roadmap, and explicit known limitations.
- Preserved the 26-phase Bash workflow and legacy read-only HackerOne adapter
  for compatibility during the planned Python migration.
- Fixed dry-run behavior under root-only CI/container environments while real
  scans continue to require a normal user.
