# master-benchmark

A 135-op cross-runtime benchmark for the L database.  Every op is written in
the shared 2.5-era q dialect, so the same script runs unmodified on any other
engine that speaks it (the "reference engine"), giving a direct head-to-head.

## Quickstart

```sh
l     master_compare.q > l.csv     # L side
<ref> master_compare.q > ref.csv   # same script under any q-dialect engine
python3 compare.py l.csv ref.csv   # per-op ratios + geomeans
```

`ratio = ref_ms / l_ms` — **>= 1 means L is faster** (2.00x = half the time).
Run both on the same idle machine, back to back.

## What it covers

`master_compare.q` times vector arithmetic, comparison, reductions, scans,
where/index, sort/group, linear algebra, fused compound chains, temporal ops,
compute-on-compressed (int, float, symbol), and 12 queries on a partitioned
on-disk table — one `R,section,op,type,n,ms` CSV line per op.

**Headline**: Apple Silicon (M-series), 2026-06-18 — overall geomean
**3.57x** in L's favor across 125 comparable ops.  Full breakdown in
[results/2026-06-18_apple_silicon.md](results/2026-06-18_apple_silicon.md).

## Files

| file | what |
|------|------|
| `master_compare.q` | Cross-runtime suite (L and the reference engine). |
| `master_bench.q`   | L-only suite: finer size grid, joins, built-in timers. |
| `compare.py`       | Reduces two runs to per-op ratios and section geomeans. |
| `results/`         | Published head-to-head results. |
