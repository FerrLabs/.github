# Contributing to FerrLabs

Thanks for taking the time to contribute. This guide applies across the
[FerrLabs](https://github.com/FerrLabs) organization unless a repository overrides
it with its own `CONTRIBUTING.md`.

## Before you start

- For anything non-trivial, **open an issue first** so we can agree on the approach
  before you write code. Small fixes (typos, docs, obvious bugs) can go straight to
  a pull request.
- Be kind. We follow our [Code of Conduct](CODE_OF_CONDUCT.md).
- By contributing, you agree your work is licensed under the same license as the
  repository you contribute to.

## Development workflow

1. **Fork** the repository (external contributors) or **branch** from `main`
   (members).
2. Create a branch named for the change, using a Conventional Commit type as the
   prefix:
   - `feat/…`, `fix/…`, `docs/…`, `refactor/…`, `perf/…`, `test/…`, `chore/…`, `ci/…`
3. Make your change. Keep the diff focused — one logical change per pull request.
4. Add or update tests for any behavior you change.
5. Run the repository's lint, format, and test tasks locally before pushing.

## Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/). Versioning and
changelogs are automated with [FerrFlow](https://github.com/FerrLabs/FerrFlow), so
your commit type drives the next release:

```
<type>: <short summary in the imperative>

[optional body explaining what and why]

[optional footer — e.g. BREAKING CHANGE: …]
```

- `feat:` → minor release   `fix:` → patch release
- `feat!:` or a `BREAKING CHANGE:` footer → major release
- `docs:`, `chore:`, `refactor:`, `test:`, `ci:`, `perf:` → no release

Keep the subject line concise and clean — no AI-attribution trailers.

## Pull requests

- Fill in the pull request template.
- The PR title must follow Conventional Commits (it is checked in CI).
- Make sure CI is green: lint, tests, and security scans must pass.
- Link the issue your PR closes (`Closes #123`).
- A maintainer ([@BryanFRD](https://github.com/BryanFRD)) will review. Address
  feedback by pushing follow-up commits; we squash on merge.

## Reporting bugs and requesting features

Use the issue templates under each repository's **Issues → New issue**. For security
issues, follow [SECURITY.md](SECURITY.md) instead — do not open a public issue.

## Questions

See [SUPPORT.md](SUPPORT.md).
