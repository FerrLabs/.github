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

## Using AI assistants

Writing code, tests or documentation with an AI assistant is entirely allowed — we do
it too. Nothing else changes: you are the author, you are accountable for what you
open, and you should be able to explain any line of it in review.

The one thing that genuinely hurts is size. An assistant produces two thousand lines
in a minute, and then a single maintainer has to read all of them. A pull request that
changes everything at once takes days to get through, gets a worse review than a small
one would, and stalls on a question that only concerns one corner of it.

So keep the diff proportional to the change, not to what the tool was able to generate:

- One logical change per pull request. Split a large piece of work into a sequence of
  pull requests that each stand on their own and each make sense to merge.
- If a wide refactor is genuinely unavoidable, land it alone, separately from any
  change in behavior, and say so in the description.
- Generated tests are still tests: they have to be able to fail. Drop the ones that
  only restate the implementation.
- Write the description yourself. An assistant's summary of its own diff is not one.

## Reporting bugs and requesting features

Use the issue templates under each repository's **Issues → New issue**. For security
issues, follow [SECURITY.md](SECURITY.md) instead — do not open a public issue.

## Questions

See [SUPPORT.md](SUPPORT.md).
