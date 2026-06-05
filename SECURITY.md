# Security Policy

We take the security of FerrLabs software seriously. This policy applies to all
repositories in the [FerrLabs](https://github.com/FerrLabs) organization unless a
repository ships its own `SECURITY.md`.

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues,
discussions, or pull requests.**

Report privately through one of:

- **GitHub** — use the repository's
  [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
  ("Security" tab → "Report a vulnerability"). Preferred.
- **Email** — [contact@ferrlabs.com](mailto:contact@ferrlabs.com) with `SECURITY`
  in the subject line.

Please include as much of the following as you can:

- The affected project, version, and commit.
- The type of issue (e.g. memory safety, injection, auth bypass, secret exposure).
- Steps to reproduce, a proof of concept, or affected source paths.
- The impact, and any conditions required to trigger it.

This helps us triage faster.

## What to expect

- **Acknowledgement** within 3 business days.
- **Initial assessment** with a severity rating and next steps within 10 business days.
- We will keep you informed as we work on a fix, and coordinate a disclosure date
  with you.
- With your consent, we will credit you once a fix ships. We do not currently run
  a paid bug bounty.

## Supported versions

Security fixes land on the latest released version of each project. Older versions
are patched at our discretion based on severity. Please upgrade to the latest
release before reporting.

## Scope

In scope: source code, released artifacts, and container images published by the
FerrLabs organization.

Out of scope: third-party dependencies (report those upstream), findings that
require physical access or a compromised host, and reports generated solely by
automated scanners without a demonstrated impact.
