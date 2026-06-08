<div align="center">

# FerrLabs

**Developer tools for teams that ship.**

[ferrlabs.com](https://ferrlabs.com) · [ferrflow.com](https://ferrflow.com)

</div>

---

We build small, opinionated CLIs and self-hostable backends for the parts of the dev workflow you should not have to think about. Open source where it makes sense, paid SaaS or self-host when you need more.

## Open source

### [FerrFlow](https://github.com/FerrLabs/FerrFlow) · v5

Universal semantic versioning. One Rust binary reads your conventional commits, bumps versions across your monorepo (14+ file formats — Cargo.toml, package.json, pyproject.toml, Chart.yaml, mix.exs, gemspec, pubspec.yaml, …), generates changelogs, tags, and ships GitHub releases. Free, MPL-2.0, drop into any CI.

```bash
cargo install ferrflow
# or
uses: FerrLabs/FerrFlow@v5
```

→ [Docs & playground at ferrflow.com](https://ferrflow.com)

### [FerrVault Operator](https://github.com/FerrLabs/FerrVault)

Kubernetes operator (Go) that syncs FerrVault SaaS secrets into native `kind: Secret`. Two CRDs — `FerrVaultConnection` + `FerrVaultSecret`. Pairs with the FerrVault SaaS but works equally well against a self-hosted FerrVault.

### Tooling around FerrFlow

- **[Fixtures](https://github.com/FerrLabs/Fixtures)** — declarative git fixture generator. Spin up reproducible repos in CI for integration tests and benchmarks.
- **[Benchmarks](https://github.com/FerrLabs/Benchmarks)** — reusable GitHub Action that runs the FerrFlow perf suite and reports regressions on every PR.

## Coming soon

| | What | Status |
|---|---|---|
| **FerrVault** | Secrets management without the infra. SaaS or self-host, K8s-native via the operator above. | beta |
| **FerrTrack** | Issue tracker for product teams. Keyboard-first, git-aware, no SLAs or AI summaries you didn't ask for. | soon |
| **FerrGrowth** | Marketing sites with built-in SEO, performance budgets, content automation. | soon |

The web apps for these live behind closed doors today; the open-source pieces (operators, CLIs, shared crates) land here as they ship.

## Principles

- **CLIs over UIs.** The terminal is the original keyboard shortcut.
- **Self-host is a feature.** Your data, your cluster, your problem to solve.
- **Open source where it makes sense.** The infra layer should be readable.
- **No telemetry by default.** Off until you opt in.

---

<div align="center">

Built in Rust, Go, and TypeScript · MPL-2.0 where applicable · Hand-built in Lille, FR

</div>
