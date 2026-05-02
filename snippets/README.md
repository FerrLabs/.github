# Snippets

Starter files to copy into FerrLabs repos. They are **not** propagated automatically — copy what you need.

| File | Goes to | Purpose |
|---|---|---|
| [`dependabot.yml`](dependabot.yml) | `<repo>/.github/dependabot.yml` | Per-repo Dependabot config (npm + cargo + gomod + docker + actions). Use this **or** Renovate, not both. |
| [`renovate.json`](renovate.json) | `<repo>/renovate.json` | Per-repo Renovate config that extends the org default at `FerrLabs/.github/default.json`. |
| [`CODEOWNERS`](CODEOWNERS) | `<repo>/.github/CODEOWNERS` | Auto-assign reviewers. Edit owners per repo. |
| [`deny.toml`](deny.toml) | `<repo>/deny.toml` | `cargo-deny` config (advisories + bans + licences + sources). Required by the `ci-rust` workflow template. |
| [`typos.toml`](typos.toml) | `<repo>/typos.toml` | `crate-ci/typos` config. Required by the `ci-rust` workflow template. |
| [`.gitleaksignore`](.gitleaksignore) | `<repo>/.gitleaksignore` | Gitleaks false-positive list. Required by the `security-scan` workflow template. |
| [`.trivyignore`](.trivyignore) | `<repo>/.trivyignore` | Trivy CVE waiver list. Used by the `docker-publish` workflow template. |

## Dependabot vs Renovate — pick one

The org currently mixes both (see [Infra#50](https://github.com/FerrLabs/Infra/issues/50)). Recommendation:
- **Renovate** for repos that benefit from grouping, merge confidence and auto-merge (most cases).
- **Dependabot** for repos that already use it and have no reason to migrate, or for security updates only (turn the rest off in repo settings).

## How to use

```bash
cd <your-repo>
mkdir -p .github
curl -fsSL https://raw.githubusercontent.com/FerrLabs/.github/main/snippets/renovate.json -o renovate.json
curl -fsSL https://raw.githubusercontent.com/FerrLabs/.github/main/snippets/CODEOWNERS -o .github/CODEOWNERS
git add . && git commit -m "chore: bootstrap FerrLabs hygiene snippets"
```
