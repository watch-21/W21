# Migrating from Jekster Pro to WATCH.21

The project identity has changed:

| Previous | WATCH.21 |
|---|---|
| `jekster-pro.sh` | `w21` |
| `jekster.conf.example` | `w21.conf.example` |
| `JEKSTER_*` environment variables | `W21_*` environment variables |
| `$XDG_STATE_HOME/jekster-pro` | `$XDG_STATE_HOME/w21` |
| `$XDG_CONFIG_HOME/jekster-pro` | `$XDG_CONFIG_HOME/w21` |

Old scan result directories are not automatically migrated or deleted. Keep
them read-only as historical evidence. Start new scans in a new WATCH.21 output
directory.

Example command conversion:

```bash
# Previous
./jekster-pro.sh --target example.com --dry-run

# WATCH.21
./w21 --target example.com --dry-run
```

Copy configuration values manually into a new `w21.conf` and replace any
`JEKSTER_*` variable names with their `W21_*` equivalents. Never copy credential
files into the repository.
