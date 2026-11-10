# 4SH fork of github.com/corazawaf/coraza/v3

Vendored copy of [Coraza](https://github.com/corazawaf/coraza) **v3.8.1**
(Apache-2.0, see `LICENSE`), wired in through a `replace` directive in the
root `go.mod`.

## What changed vs upstream v3.8.1

Two upstream changes made after v3.8.1 are backported. They touch
`internal/corazawaf/rule.go`, `rule_test.go`, `rulegroup.go`,
`transaction.go` and `waf.go`; each file carries a modification notice.

1. Commit
   [`a66ffcfe`](https://github.com/corazawaf/coraza/commit/a66ffcfe27a565d0b77cdb28f0e6532d98cf647a)
   "fix(corazawaf): key the transformation cache by value identity" (#1682,
   merged on main after v3.8.1, unreleased at the time of the backport). See
   [Transformation cache memory](#transformation-cache-memory).
2. PR [#1750](https://github.com/corazawaf/coraza/pull/1750)
   "perf(engine): expand RULE:msg/logdata at match time, not per evaluated
   rule" (commit `b577160f`, open at the time of the backport). See
   [Log noise from eager msg/logdata expansion](#log-noise-from-eager-msglogdata-expansion).

The tests these changes add under `testing/` and their ADRs under `docs/` are
not vendored. Everything else is upstream v3.8.1 as released.

Upstream development files are not vendored: `.github/`, `docs/`, `examples/`,
`testing/` (separate Go modules), `go.work`, magefiles and repository
metadata (changelog, contributing guides, bot configs).

## Transformation cache memory

#1544 (v3.4.0) made the per-phase transformation cache store every
intermediate transformation step, keyed by the argument's position in the
collection. Map-backed collections (`ARGS_POST`, `REQUEST_HEADERS`, ...) return
their values in random order, so most lookups missed and each rule stored
duplicate entries. Under the TinyGo 0.39 build of this plugin (`-gc=boehm`) the
wasm heap then grew without levelling off as soon as requests carried a JSON
body. TinyGo's `sync.Pool` never releases pooled transactions, and Go maps
never shrink, so every pooled transaction keeps a cache sized for the largest
phase it ran.

`a66ffcfe` keys the cache by the value itself (data pointer and length), so
rules share one entry per value and transformation prefix, and `Close()`
empties the cache. Measured with Envoy 1.31 (2 workers), the full CRS, a JSON
audit log and two streams of 10 KB JSON POSTs for 5 minutes, all variants with
#1750:

| Coraza                            | Envoy RSS (5 min) | Trend | wasm `Sys` (2 VMs) | Throughput |
|-----------------------------------|-------------------|-------|--------------------|------------|
| v3.8.1 with #1544 reverted        | 639 MiB           | flat  | 218 MiB            | 25 req/s   |
| v3.8.1 with `a66ffcfe`            | 491 MiB           | flat  | 132 MiB            | 37 req/s   |

For reference, plain v3.8.1 reached 1.37 GiB after 90 seconds on the same
bench and was still growing. Earlier versions of this fork reverted #1544
instead; `a66ffcfe` keeps its speed-up and uses less memory than the revert.

## Log noise from eager msg/logdata expansion

Upstream #1606 (v3.8.0) expands `msg` and `logdata` into the `RULE` collection
every time a rule is evaluated, whether it matches or not. CRS rules 943110 and
943120 have a `logdata` that reads `TX.943110_MATCHED_VAR_NAME` /
`TX.943120_MATCHED_VAR_NAME`, which only their own `setvar` writes on a match.
On every request the expansion misses the key and logs, at `SecDebugLogLevel`
2 and above:

```
key not found in collection, returning the original text variable="TX" key="943110_matched_var_name"
```

With multiphase evaluation this is four warnings per request (two rules, two
phases), which floods the Envoy logs of a gateway at `SecDebugLogLevel 3`.
#1750 moves the expansion to match time, as before v3.8.0: no warning on
requests that do not match, same `msg`/`logdata` on requests that do, and fewer
allocations per request.

## Not backported

PR [#1751](https://github.com/corazawaf/coraza/pull/1751) (bounded retention
of pooled transactions) would suit TinyGo's never-draining `sync.Pool`, but as
of its commit `1c00676b` it reads file-backed body buffers through
`io.SectionReader`, which makes the module import
`wasi_snapshot_preview1.fd_pread`. Envoy does not provide it and refuses to
load the plugin (`Failed to load Wasm module due to a missing import`).

## Updating

To move to a newer Coraza release: if it predates `a66ffcfe` or #1750,
cherry-pick them on top of it; copy the tree here with the same exclusions;
check that the wasm imports nothing new (`go run mage.go build` prints the
import count, compare the list against the previous build); and re-run the
memory check. Drop this directory and the `replace` once a release contains
both changes and behaves under TinyGo.
