# WATCH.21 project rules

- Work only on explicitly authorized security-testing functionality.
- Never run automated tests against public targets; use offline fixtures or a
  local lab.
- Scope is a fail-closed boundary. Exact hosts never imply subdomains, wildcard
  rules never imply the apex, and exclusions always win.
- No network-capable component may bypass the central Scope Engine in the
  planned Python architecture.
- Raw tool output creates candidates, never confirmed findings.
- Preserve existing scan results and unrelated user changes. Do not use
  destructive Git operations or silently migrate historical evidence.
- Use argument arrays for subprocesses. Never use `eval`, `shell=True`, or
  target-controlled shell interpolation.
- Keep resource use bounded and TLS verification enabled by default.
- Run syntax checks and all offline tests after every behavioral change.
- Update `PLANS.md`, documentation, and known limitations with verified facts;
  do not count placeholders as implemented features.
