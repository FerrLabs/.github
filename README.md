# FerrLabs `.github`

Organization-level defaults for every repository in the
[FerrLabs](https://github.com/FerrLabs) GitHub organization.

Files here are **inherited automatically** by any repo that does not ship its own
version — community health files, the org profile, shared CI, and config presets all
live in one place.

## What's in here

| Path | Purpose |
|------|---------|
| `profile/README.md` | The public [organization profile](https://github.com/FerrLabs) page. |
| `.github/workflows/` | **Reusable workflows** (`reusable-ci-*`, `reusable-docker-build`, `reusable-release-rust`, `reusable-security-scan`, `reusable-sonarqube-scan`) called by repos via `workflow_call`, plus the org-wide `renovate.yml`. |
| `workflow-templates/` | **Starter workflows** shown under *Actions → New workflow* (CI for Astro/Go/Node/Rust, CodeQL, docker-publish, release, scorecard, pr-title, security-scan), each with its `.properties.json`. |
| `snippets/` | Config files to **copy into** repos: `CODEOWNERS`, `renovate.json`, `dependabot.yml`, `deny.toml`, `typos.toml`, `.gitleaksignore`, `.trivyignore`. Not inherited — these are templates to drop in. |
| `default.json` / `renovate.json` | Shared **Renovate** config. `default.json` is loaded by `renovate.yml`; `renovate.json` is the org-wide preset. |
| `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SUPPORT.md` | Community health files inherited org-wide. |
| `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md` | Default issue and PR templates inherited by repos without their own. |

## How inheritance works

GitHub falls back to this repo when a target repo is missing a given file:

- **Inherited org-wide:** health files (`SECURITY`, `CONTRIBUTING`, `CODE_OF_CONDUCT`,
  `SUPPORT`), issue templates, the PR template, and the profile page.
- **Opt-in per repo:** reusable workflows (referenced explicitly with `uses:`),
  starter workflows (picked from the UI), and everything in `snippets/` (copied in).

A repo overrides any inherited file simply by committing its own.

## Conventions

- Commits and PR titles follow [Conventional Commits](https://www.conventionalcommits.org/);
  versioning and changelogs are automated with
  [FerrFlow](https://github.com/FerrLabs/FerrFlow).
- See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

[MPL-2.0](LICENSE).
