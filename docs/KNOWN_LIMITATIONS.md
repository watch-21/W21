# Known limitations

WATCH.21 `0.1.0-alpha` is a renamed and cleaned-up Bash development snapshot,
not a production-complete scanner.

Known limitations at this release:

1. Some external tools receive prefiltered targets but may follow redirects or
   make secondary requests before WATCH.21 post-filters their output. A single
   request-level Scope Engine is still being implemented.
2. Some phase failures degrade and allow independent later phases to continue;
   the final exit status does not yet express every partial failure precisely.
3. Resume and state checkpoints exist, but crash recovery and artifact
   completeness contracts are not yet durable across every phase.
4. Nuclei and validator output must be treated as candidates. The current
   validation layer is not sufficient to label all findings confirmed.
5. Rate limits are per process. A shared coordinator and multi-terminal worker
   budget do not exist in this Bash release.
6. The legacy read-only HackerOne scope adapter remains in the Bash snapshot and
   is planned to move out of the core engine.
7. The dependency catalog includes optional third-party tools with different
   licenses and maintenance models. Review `tools.lock.json` before installing.

Until the request-level scope and phase-contract milestones are complete, use
network-enabled operation only in controlled, explicitly authorized
environments with conservative limits.
