<div align="center">

# FerrLabs

**Developer tools for teams that ship.**

[ferrlabs.com](https://ferrlabs.com) · [status](https://status.ferrlabs.com) · [changelog](https://ferrlabs.com/changelog)

</div>

---

We build small, opinionated tools for the parts of the dev workflow you should not have to think about. One org, one login, one bill across every product — and FerrFlow stays free inside all of them.

## Products

| Product | What it does | |
|---|---|---|
| **FerrFlow** | Releases your code. Reads your conventional commits, bumps the version, writes the changelog, tags and publishes — one binary, any language. | [ferrflow.com](https://ferrflow.com) |
| **FerrVault** | Stores your secrets and hands them to your apps, without running the infrastructure yourself. | [ferrvault.com](https://ferrvault.com) |
| **FerrTrack** | Tracks your issues. A keyboard-first, git-aware tracker for product teams — no SLAs or AI summaries you didn't ask for. | [ferrtrack.com](https://ferrtrack.com) |
| **FerrGrowth** | Builds and ships your marketing site: pages, forms, SEO audits, analytics. | [ferrgrowth.com](https://ferrgrowth.com) |
| **FerrFleet** | Runs your AI agents and shows you what they actually did — execution plus observability. | [ferrfleet.com](https://ferrfleet.com) |
| **FerrLens** | Checks your stack. Free standalone tools for SEO, DNS, email (SPF/DKIM/DMARC), TLS, and everyday dev chores. | [ferrlens.com](https://ferrlens.com) |
| **FerrGames** | Small multiplayer party games to play with friends. In the browser, no account needed. | [ferrgames.com](https://ferrgames.com) |

## Open source

### [FerrFlow](https://github.com/FerrLabs/FerrFlow) · v7 · MPL-2.0

Universal semantic versioning. One Rust binary reads your conventional commits, bumps versions across your monorepo (14+ file formats — `Cargo.toml`, `package.json`, `pyproject.toml`, `Chart.yaml`, `mix.exs`, gemspec, `pubspec.yaml`, …), generates changelogs, tags, and ships GitHub releases. Drop it into any CI.

```bash
cargo install ferrflow
# or
uses: FerrLabs/FerrFlow@v7
```

→ [Docs & playground at ferrflow.com](https://ferrflow.com)

### [FerrVault Operator](https://github.com/FerrLabs/FerrVault)

Kubernetes operator (Go) that syncs FerrVault secrets into native `kind: Secret`. Two CRDs — `FerrVaultConnection` and `FerrVaultSecret`. Pairs with FerrVault SaaS, works just as well against a self-hosted instance.

### [MCP](https://github.com/FerrLabs/MCP)

Model Context Protocol server. Lets AI assistants drive the suite — cut a release, read issues, manage secrets, query analytics.

### Tooling around FerrFlow

- **[Fixtures](https://github.com/FerrLabs/Fixtures)** — declarative git fixture generator. Reproducible repos for integration tests and benchmarks.
- **[Benchmarks](https://github.com/FerrLabs/Benchmarks)** — reusable GitHub Action that runs the FerrFlow perf suite and reports regressions on every PR.

## Principles

- **CLIs over UIs.** The terminal is the original keyboard shortcut.
- **Self-host is a feature.** Your data, your cluster.
- **Open source where it makes sense.** The infra layer should be readable.
- **No telemetry by default.** Off until you opt in.

---

<div align="center">
<sub><a href="https://ferrlabs.com">ferrlabs.com</a> · <a href="mailto:contact@ferrlabs.com">contact@ferrlabs.com</a></sub>
</div>
