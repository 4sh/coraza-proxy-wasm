# 4SH fork of github.com/corazawaf/coraza/v3

Vendored copy of [Coraza](https://github.com/corazawaf/coraza) **v3.8.1**
(Apache-2.0, see `LICENSE`), wired in through a `replace` directive in the
root `go.mod`.

## What changed vs upstream v3.8.1

One upstream commit is reverted:
[`7a1b42ad`](https://github.com/corazawaf/coraza/commit/7a1b42ad531ff36ad76e303ca243b8ef246ff4ee)
"perf: prefix-based transformation cache with inline values" (#1544, first
released in v3.4.0). The revert touches `internal/corazawaf/rule.go`,
`rule_test.go`, `transaction.go` and `waf.go`; each carries a modification
notice. Everything else is upstream v3.8.1 as released.

Upstream development files are not vendored: `.github/`, `docs/`, `examples/`,
`testing/` (separate Go modules), `go.work`, magefiles and repository
metadata (changelog, contributing guides, bot configs).

## Why

#1544 caches every intermediate transformation step per argument. Under the
TinyGo 0.39 build of this plugin (`-gc=boehm`), the wasm heap then grows
without levelling off as soon as requests carry a JSON body. Measured with
Envoy 1.31, the full CRS and 10 KB JSON POSTs:

| Coraza                      | Envoy RSS after 90 s | Trend      |
|-----------------------------|----------------------|------------|
| v3.3.3                      | ~640 MiB             | flat       |
| v3.8.1                      | ~1.37 GiB            | increasing |
| v3.8.1 with #1544 reverted  | ~570 MiB             | flat       |

`git bisect` between v3.3.3 and v3.4.0 pins the regression on 7a1b42ad.
Coraza's own unit tests pass with the revert.

## Updating

To move to a newer Coraza release, re-apply the revert on top of it
(`git revert 7a1b42ad`, keeping upstream's version of any test-only conflict),
copy the tree here with the same exclusions, and re-run the memory check
before dropping the fork. Drop this directory and the `replace` once upstream
behaves under TinyGo.
