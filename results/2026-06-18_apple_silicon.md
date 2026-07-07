# L vs reference engine — master_compare.q (2026-06-18)

Hardware: Apple Silicon Mac (M-series, NEON).  L: PGO release build.
Reference engine: a commercial q-language database (2.5 dialect).
Vector size N = 1,000,000.  Ratio = `ref_ms / l_ms` (>1 = L faster).
125 comparable ops.

## scoc — symbol filters on compressed codes

| op        | L ms | ref ms | ref/L |
|-----------|-----:|-------:|------:|
| like_pre  |   47 |    907 | **19.30x** |
| like_suf  |   49 |    913 | **18.63x** |
| eq_atom   |    3 |     32 | **10.67x** |
| like_con  |  162 |   1314 |  **8.11x** |
| where_in  |   15 |     83 |  **5.53x** |
| where_eq  |   23 |     91 |  **3.96x** |

scoc geomean **9.38x** — the fastest section in the suite.

## Per-section geomean

| section  |   n | geomean |
|----------|----:|--------:|
| scoc     |   6 | **9.38x** |
| cmp      |  10 |  6.58x |
| coc      |  15 |  5.41x |
| reduce   |  12 |  4.49x |
| where    |   7 |  3.55x |
| scan     |   4 |  3.23x |
| arith    |  15 |  3.09x |
| la       |   4 |  3.09x |
| hdb      |  12 |  2.80x |
| temporal |  13 |  2.60x |
| cmpd     |  15 |  2.54x |
| sort     |   8 |  2.36x |
| map      |   4 |  2.10x |
| **OVERALL** | **125** | **3.57x** |
