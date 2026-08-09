# Renovate self-check fixture

`fixture/` is a minimal repository that reproduces the shape of a FerrLabs
product repo, as far as Renovate is concerned:

- the crate manifest lives in `api/Cargo.toml`, not at the root;
- `api/.cargo/config.toml` declares the `kellnr` registry, which Renovate's
  cargo manager does **not** discover (it reads `.cargo/config.toml` relative
  to the repo root);
- one dependency is pinned to a deliberately stale `ferrlabs-*` version.

`.github/workflows/renovate-selfcheck.yml` runs Renovate against it with
`--platform=local` and the same configuration the real sweep uses, then
asserts that the crate resolves and that an update is proposed.

This exists because the `ferrlabs-*` lookups silently returned `no-result`
for over a month (issue #205): Kit shipped 2.x while the products stayed on
0.x, so security fixes in `ferrlabs-auth` / `ferrlabs-permissions` reached
nobody. Nothing failed — Renovate logged a `WARN` and carried on. The three
independent causes were all invisible to config validation:

1. `allowCustomCrateRegistries` unset, so the crate datasource refused the
   registry before making a request;
2. the Kellnr `hostRule` used `hostType: cargo` (a manager id) instead of
   `crate` (the datasource id), so no token was attached and the sparse index
   answered 401;
3. `matchDepPatterns` / `matchPackagePatterns` were removed in Renovate 41.

Only an end-to-end lookup catches (1) and (2). The `validate` job in the same
workflow catches (3) and anything else `renovate-config-validator --strict`
knows about.

## Updating the fixture

Keep `ferrlabs-queue` pinned to a version that is **older** than the latest
published one — the check asserts that an update is found, so pinning it to
the current release would make the check pass vacuously. `0.1.0` is the
oldest published version and never needs bumping.
