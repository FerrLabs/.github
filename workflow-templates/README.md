# FerrLabs workflow templates

GitHub-discovered workflow templates. They appear under **Actions → New workflow → By FerrLabs** in every repo of the org. Picking one **copies** the file into `.github/workflows/` of the target repo — the original here is not propagated retroactively.

## Catalog

| Template | What it does | When to pick it |
|---|---|---|
| [`ci-rust`](ci-rust.yml) | fmt, clippy, test, cargo-audit, cargo-deny, cargo-machete, typos, llvm-cov | Any Rust crate. Requires [`deny.toml`](../snippets/deny.toml) and [`typos.toml`](../snippets/typos.toml). |
| [`ci-node`](ci-node.yml) | typecheck, lint, test+coverage, build, knip, madge, pnpm audit | Any Node/TS package. |
| [`ci-astro`](ci-astro.yml) | astro check, build, i18n parity, Lighthouse on PRs | Astro marketing sites (`*-Cloud/site`). |
| [`ci-go`](ci-go.yml) | gofmt, vet, golangci-lint, race tests, govulncheck, build | Any Go module (operators, services). |
| [`codeql`](codeql.yml) | GitHub CodeQL static analysis (security-and-quality queries) | All TS/JS/Go/Python repos (CodeQL doesn't support Rust yet). |
| [`scorecard`](scorecard.yml) | OpenSSF Scorecard supply-chain risk score | All public repos and key private repos. |
| [`security-scan`](security-scan.yml) | Reusable: gitleaks (secrets) + osv-scanner (CVE) + trufflehog (deep history) | Every repo — call the shared workflow from `FerrLabs/.github`. |
| [`pr-title`](pr-title.yml) | Conventional Commits validation on PR titles | Every repo (mandatory because we squash-merge). |
| [`release`](release.yml) | Auto-release on push to main with `FerrLabs/FerrFlow@v4` | Repos that ship semver releases. |
| [`docker-publish`](docker-publish.yml) | Reusable: hadolint + multi-arch build + Trivy + cosign keyless + SBOM | Repos that publish a container image. |

## Reusable workflows

The `security-scan` and `docker-publish` templates **call** reusable workflows hosted in `FerrLabs/.github`:

- `FerrLabs/.github/.github/workflows/reusable-security-scan.yml@main`
- `FerrLabs/.github/.github/workflows/reusable-docker-build.yml@main`
- `FerrLabs/.github/.github/workflows/reusable-release-rust.yml@main` (cross-compile binaries → attest → upload to release → optional crates.io + Docker)

Hosting the reusables in the **public** `.github` repo (rather than the private `Infra` repo) is required for OSS repos like FerrFlow to call them — GitHub forbids public→private reusable calls. Updating the source workflow propagates to every consumer at the next run.

## Conventions

- Default runner: `ubuntu-latest`. Heavier jobs (Node install, Astro build, Docker build) target the self-hosted `ferrlabs-k8s` cluster.
- Pinned major versions for trusted official actions (`actions/checkout@v6`, `dtolnay/rust-toolchain@stable`, etc.).
- Coverage is uploaded to Codecov when `CODECOV_TOKEN` is set; failures are non-blocking.
- All security templates upload SARIF to the GitHub code-scanning UI.

## Required secrets per template

| Template | Secret | Required? |
|---|---|---|
| `ci-rust`, `ci-node`, `ci-go` | `CODECOV_TOKEN` | Optional |
| `ci-node`, `ci-astro` | `FERRLABS_PACKAGES_READ` | Required if the repo consumes private `@ferrlabs/*` packages |
| `ci-astro` | `LHCI_GITHUB_APP_TOKEN` | Optional (Lighthouse comments on PRs) |
| `security-scan` | `GITLEAKS_LICENSE` | Required for orgs with >25 contributors |
| `release` | `FERRLABS_BOT_*` (FerrFlow OIDC) | Configured org-wide |
| `docker-publish` | `GITHUB_TOKEN` | Auto-provided |
