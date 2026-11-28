# Ruleset scripts

Baseline: org ruleset `ferrlabs-baseline-protection` (thread resolution) plus one `main: required CI checks` ruleset per repository.

```bash
./derive-checks.sh          # writes checks.json from the last 5 merged PRs per repo
./audit.sh                  # read only, writes audit.tsv
./apply.sh --repo Infra     # dry run: prints the gh api calls and a diff
./apply.sh --repo Infra --apply
./apply.sh --org --apply    # thread resolution, affects every repository
./apply.sh --rollback backup/<repo>-<id>-<timestamp>.json --apply
```

Dry run is the default. Every write saves the previous ruleset under `backup/`. Review `checks.json` before applying: drop contexts of path-filtered workflows.
