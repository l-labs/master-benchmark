/ master_compare.q — ONE cross-runtime benchmark: micro grid + sort/group +
/ where/index + linear algebra + compound chains + temporal + compressed +
/ HDB queries.  Runs IDENTICALLY on L and the reference engine (.z.t timing,
/ do[reps] repeats).  Prints one "R,section,op,type,n,ms" line per op to
/ stdout; redirect per runtime, then reduce with compare.py:
/   l master_compare.q > l.csv           (L)
/   <ref> master_compare.q > ref.csv     (reference engine)
/   python3 compare.py l.csv ref.csv
/ Shared 2.5-era q dialect only.  Mac ms-coarse timer -> reps tuned so op
/ totals are tens-to-hundreds of ms; treat <10ms totals as noise.

N:1000000                                                                       / vector size
B:{[sec;op;ty;n;reps;f] f[]; t:.z.t; do[reps;f[]]; r:"j"$.z.t-t;                / warm once, then time
  -1 "R,",(","sv(string sec;string op;string ty;string n;string r)); }

/ ── data (top-level set => RAW in both runtimes; tests raw SIMD paths) ──────
`xh set `short$N?100; `yh set `short$N?100;
`xi set N?100;        `yi set N?100;        `idx set (N div 3)?N;
`xj set N?100j;       `yj set N?100j;
`xe set `real$1.0+N?99.0; `ye set `real$1.0+N?99.0;
`xf set 1.0+N?99.0;       `yf set 1.0+N?99.0;
`syms set `AAA`BBB`CCC`DDD`EEE`FFF`GGG`HHH;
`xs set N?syms; `ys set N?syms; `in3 set 3?syms;
`xb set N?2;
`xs100 set N?100000; `xf100 set N?100000.0;                                     / wide-range for sort
`xn set 16h$N?1000000000j; `yn set 16h$N?1000000000j;                           / timespan (KN) ns vecs
`xp set 12h$N?1000000000j; `yp set 12h$N?1000000000j;                           / timestamp (KP) ns vecs
`xnlo set 16h$N?1000;                                                           / low-card timespan for group

/ ── arithmetic (vec-vec, scalar-vec, vec-scalar) ────────────────────────────
B[`arith;`add_vv;`KI;N;200;{xi+yi}]; B[`arith;`add_vv;`KJ;N;200;{xj+yj}];
B[`arith;`add_vv;`KF;N;200;{xf+yf}]; B[`arith;`add_vv;`KH;N;200;{xh+yh}];
B[`arith;`add_vv;`KE;N;200;{xe+ye}];
B[`arith;`sub_vv;`KI;N;200;{xi-yi}]; B[`arith;`sub_vv;`KF;N;200;{xf-yf}];
B[`arith;`mul_vv;`KI;N;200;{xi*yi}]; B[`arith;`mul_vv;`KF;N;200;{xf*yf}];
B[`arith;`div_vv;`KF;N;200;{xf%yf}];
B[`arith;`add_sv;`KI;N;200;{42+xi}]; B[`arith;`add_sv;`KF;N;200;{1.5+xf}];
B[`arith;`mul_sv;`KF;N;200;{2.5*xf}]; B[`arith;`div_sv;`KF;N;200;{1.0%xf}];
B[`arith;`add_vs;`KI;N;200;{xi+42}];

/ ── comparison ──────────────────────────────────────────────────────────────
B[`cmp;`eq_vv;`KI;N;200;{xi=yi}]; B[`cmp;`eq_vv;`KF;N;200;{xf=yf}];
B[`cmp;`eq_vv;`KS;N;200;{xs=ys}]; B[`cmp;`eq_va;`KI;N;200;{xi=50}];
B[`cmp;`eq_va;`KF;N;200;{xf=50.0}]; B[`cmp;`eq_va;`KS;N;200;{xs=`AAA}];
B[`cmp;`lt_vv;`KI;N;200;{xi<yi}]; B[`cmp;`lt_va;`KI;N;200;{xi<50}];
B[`cmp;`lt_va;`KF;N;200;{xf<50.0}]; B[`cmp;`gt_va;`KF;N;200;{xf>50.0}];

/ ── reductions (cheap => high reps) ─────────────────────────────────────────
B[`reduce;`sum;`KI;N;1000;{sum xi}]; B[`reduce;`sum;`KJ;N;1000;{sum xj}];
B[`reduce;`sum;`KF;N;1000;{sum xf}]; B[`reduce;`sum;`KH;N;1000;{sum xh}];
B[`reduce;`sum;`KE;N;1000;{sum xe}]; B[`reduce;`sum;`KB;N;1000;{sum xb}];
B[`reduce;`prd;`KI;N;1000;{prd xi}]; B[`reduce;`prd;`KF;N;1000;{prd xf}];
B[`reduce;`min;`KI;N;1000;{min xi}]; B[`reduce;`min;`KF;N;1000;{min xf}];
B[`reduce;`max;`KI;N;1000;{max xi}]; B[`reduce;`max;`KF;N;1000;{max xf}];
B[`reduce;`avg;`KI;N;1000;{avg xi}]; B[`reduce;`avg;`KF;N;1000;{avg xf}];

/ ── scans / each-prior ──────────────────────────────────────────────────────
B[`scan;`sums;`KI;N;200;{sums xi}]; B[`scan;`sums;`KF;N;200;{sums xf}];
B[`scan;`deltas;`KI;N;200;{deltas xi}]; B[`scan;`maxs;`KI;N;200;{maxs xi}];

/ ── monadic / transcendental (float) ────────────────────────────────────────
B[`map;`neg;`KF;N;200;{neg xf}]; B[`map;`abs;`KF;N;200;{abs xf}];
B[`map;`sqrt;`KF;N;200;{sqrt xf}]; B[`map;`floor;`KF;N;200;{"j"$xf}];

/ ── where / index / within / in ─────────────────────────────────────────────
B[`where;`ind;`KI;N;200;{xi idx}]; B[`where;`ind;`KF;N;200;{xf idx}];
B[`where;`ind;`KS;N;200;{xs idx}];
B[`where;`where_eq;`KI;N;200;{where xi=50}];
B[`where;`where_lt;`KF;N;200;{where xf<50.0}];
B[`where;`within;`KI;N;200;{where xi within 30 70}];
B[`where;`in;`KS;N;100;{where xs in in3}];

/ ── sort / grade / distinct / group ─────────────────────────────────────────
B[`sort;`asc;`KI;N;30;{asc xs100}]; B[`sort;`asc;`KF;N;30;{asc xf100}];
B[`sort;`asc;`KS;N;30;{asc xs}];
B[`sort;`iasc;`KI;N;30;{iasc xs100}];
B[`sort;`distinct;`KI;N;50;{distinct xi}];
B[`sort;`distinct;`KS;N;50;{distinct xs}];
B[`sort;`group;`KI;N;30;{group xi}]; B[`sort;`group;`KS;N;30;{group xs}];

/ ── linear algebra (mmu, dot, mv) ───────────────────────────────────────────
`mA set (256;256)#(256*256)?1.0; `mB set (256;256)#(256*256)?1.0;
`vA set N?1.0; `vB set N?1.0;
`mV set (512;512)#(512*512)?1.0; `vv512 set 512?1.0;
B[`la;`matmul;`KF;256;100;{mA mmu mB}];
B[`la;`dot;`KF;N;200;{vA mmu vB}];
B[`la;`mv;`KF;512;200;{mV mmu vv512}];
B[`la;`wsum;`KF;N;200;{vA wsum vB}];

/ ── compound / fused expressions (multi-op chains — the real workload) ──────
softmax:{e:exp x-max x; e%sum e};                                               / exp(x-max) / sum (stable)
zscore:{m:avg x; (x-m)%sqrt((avg x*x)-m*m)};                                    / (x-mean)/std
norm01:{m:min x; (x-m)%((max x)-m)};                                            / min-max to [0,1]
B[`cmpd;`where_or;`KI;N;200;{xi where (xi>50)|(xi<35)}];                        / compound predicate + where
B[`cmpd;`where_and;`KI;N;200;{xi where (xi>20)&(xi<80)}];
B[`cmpd;`bool_or;`KI;N;200;{(xi>50)|(xi<35)}];                                  / fused dual compare -> KB
B[`cmpd;`clamp;`KI;N;200;{20|xi&80}];                                           / clamp [20,80] (min then max)
B[`cmpd;`count_gt;`KI;N;500;{sum xi>50}];                                       / count matching (sum of bool)
B[`cmpd;`sumsq;`KF;N;200;{sum xf*xf}];                                          / sum of squares
B[`cmpd;`l2norm;`KF;N;200;{sqrt sum xf*xf}];                                    / L2 norm
B[`cmpd;`poly;`KF;N;200;{1.0+xf+xf*xf}];                                        / 1+x+x^2 (map chain)
B[`cmpd;`affine;`KF;N;200;{1.5+2.0*xf}];                                        / scale+shift
B[`cmpd;`wcombine;`KF;N;200;{(0.3*xf)+0.7*yf}];                                 / weighted blend of two vecs
B[`cmpd;`softmax;`KF;N;100;{softmax xf}];                                       / exp/max/sum/div chain
B[`cmpd;`zscore;`KF;N;100;{zscore xf}];                                         / standardize
B[`cmpd;`norm01;`KF;N;100;{norm01 xf}];                                         / min-max normalize
B[`cmpd;`logsumexp;`KF;N;100;{(max xf)+log sum exp xf-max xf}];                 / LSE
B[`cmpd;`relu_sum;`KF;N;200;{sum 0.0|xf-50.0}];                                 / sum(max(0,x-50)) relu chain

/ ── temporal: timespan (KN) + timestamp (KP) — 8-byte ns, base-type KJ ──────
B[`temporal;`add_vv;`KN;N;200;{xn+yn}]; B[`temporal;`sub_vv;`KN;N;200;{xn-yn}];
B[`temporal;`mul_sv;`KN;N;200;{xn*2}];  B[`temporal;`div_sv;`KN;N;200;{xn%2}];
B[`temporal;`sub_tt;`KP;N;200;{xp-yp}];                                         / ts-ts -> timespan
B[`temporal;`eq_vv;`KN;N;200;{xn=yn}];  B[`temporal;`eq_va;`KN;N;200;{xn=xn 0}];
B[`temporal;`lt_vv;`KN;N;200;{xn<yn}];
B[`temporal;`sum;`KN;N;1000;{sum xn}];  B[`temporal;`min;`KN;N;1000;{min xn}];
B[`temporal;`max;`KN;N;1000;{max xn}];
B[`temporal;`min;`KP;N;1000;{min xp}];  B[`temporal;`max;`KP;N;1000;{max xp}];
B[`temporal;`asc;`KN;N;20;{asc xn}];    B[`temporal;`iasc;`KN;N;20;{iasc xn}];
B[`temporal;`where_gt;`KN;N;200;{xn where xn>xn 0}];
B[`temporal;`group;`KN;N;20;{group xnlo}];

/ ── coc: L on COMPRESSED data vs reference RAW — beats the DRAM ceiling ─────
/ Each lambda builds a FRESH `::` global: in L it is COMPRESSED (FOR-int /
/ ALP-float) and STAYS compressed through the inline op (compute-on-
/ compressed); in the reference engine it is a plain raw global.  SAME
/ type+values in both (j-cast int / float), so the only difference is bytes-
/ from-DRAM: L reads the compressed payload (~2-4x fewer bytes), so
/ bandwidth-bound ops should BEAT raw, not merely match it.  R,coc,op,ty,N,ms.
BC:{[op;ty;reps;f] r:"j"$f[]; -1 "R,coc,",(","sv(op;ty;string N;string r));}
BC["sum";"FOR";1000;{g::"j"$(til N)mod 1000; s:.z.t; do[1000;sum g]; .z.t-s}]
BC["avg";"FOR";1000;{g::"j"$(til N)mod 1000; s:.z.t; do[1000;avg g]; .z.t-s}]
BC["min";"FOR";1000;{g::"j"$(til N)mod 1000; s:.z.t; do[1000;min g]; .z.t-s}]
BC["max";"FOR";1000;{g::"j"$(til N)mod 1000; s:.z.t; do[1000;max g]; .z.t-s}]
BC["add_vv";"FOR";200;{a::"j"$(til N)mod 1000; b::"j"$(til N)mod 997;
  s:.z.t; do[200;a+b]; .z.t-s}]
BC["add_atom";"FOR";200;{g::"j"$(til N)mod 1000;
  s:.z.t; do[200;g+5]; .z.t-s}]
BC["mul_atom";"FOR";200;{g::"j"$(til N)mod 1000;
  s:.z.t; do[200;g*3]; .z.t-s}]
BC["where_gt";"FOR";200;{g::"j"$(til N)mod 1000;
  s:.z.t; do[200;g where g>500]; .z.t-s}]
BC["where_or";"FOR";200;{g::"j"$(til N)mod 1000;
  s:.z.t; do[200;g where (g>500)|(g<350)]; .z.t-s}]
BC["sum";"KN";1000;{g::16h$(til N)mod 1000; s:.z.t; do[1000;sum g]; .z.t-s}]
BC["min";"KN";1000;{g::16h$(til N)mod 1000; s:.z.t; do[1000;min g]; .z.t-s}]
BC["where_gt";"KN";200;{g::16h$(til N)mod 1000;
  s:.z.t; do[200;g where g>16h$500]; .z.t-s}]
BC["add_atom";"KN";200;{g::16h$(til N)mod 1000;
  s:.z.t; do[200;g+16h$5]; .z.t-s}]
BC["sum";"ALP";1000;{g::0.01*til N; s:.z.t; do[1000;sum g]; .z.t-s}]
BC["avg";"ALP";1000;{g::0.01*til N; s:.z.t; do[1000;avg g]; .z.t-s}]
BC["min";"ALP";1000;{g::0.01*til N; s:.z.t; do[1000;min g]; .z.t-s}]
BC["max";"ALP";1000;{g::0.01*til N; s:.z.t; do[1000;max g]; .z.t-s}]
BC["add_atom";"ALP";200;{g::0.01*til N; s:.z.t; do[200;g+5.0]; .z.t-s}]
BC["where_gt";"ALP";200;{g::0.01*til N;
  s:.z.t; do[200;g where g>5000.0]; .z.t-s}]

/ ── scoc: L compressed symbol codec vs reference raw — like/=/in on codes ───
/ NB: a top-level `:` assign auto-compresses symbols in L (`set`/`::` do
/ NOT), so g MUST be made with `:` to land a packed symbol column that stays
/ compressed.  The same line is a raw symbol vector in the reference engine,
/ so each row is L-on-compressed vs reference-on-raw.  R,scoc,op,KS.
g:N?syms;                                                                       / L: packed codes; ref: raw
BS:{[op;reps;f] r:"j"$f[]; -1 "R,scoc,",(","sv(op;"KS";string N;string r));}
BS["like_suf";200;{s:.z.t; do[200;g like "*A"];  .z.t-s}]
BS["like_con";200;{s:.z.t; do[200;g like "*B*"]; .z.t-s}]
BS["like_pre";200;{s:.z.t; do[200;g like "A*"];  .z.t-s}]
BS["eq_atom"; 200;{s:.z.t; do[200;g=`AAA];       .z.t-s}]
BS["where_eq";200;{s:.z.t; do[200;where g=`AAA]; .z.t-s}]
BS["where_in";100;{s:.z.t; do[100;where g in in3];.z.t-s}]

/ ── HDB: build a small splay, run diverse queries ───────────────────────────
`base set "/tmp/master_cmp_hdb";
system "rm -rf ",base; system "mkdir -p ",base,"/hdb";
`hsyms set `IBM`MSFT`AAPL`GOOG`AMZN`META`NVDA`TSLA`AMD`INTC`QCOM`AVGO`CRM,
  `ORCL`ADBE`NFLX;
`exchs set `NYSE`NASD`ARCA`BATS`IEX`EDGX;
`d0 set 2024.01.01; `ND set 10; `NR set 200000;
wd:{[bs;sy;ex;nr;dt]
  trade::([]date:nr#dt;sym:nr?sy;price:50.0+nr?200.0;size:100*1+nr?1000;
    side:nr?`B`S;exch:nr?ex);
  .Q.dpft[`$":",bs,"/hdb";dt;`sym;`trade]};
i:0; do[ND; wd[base;hsyms;exchs;NR;d0+i]; i+:1]; system "l ",base,"/hdb";
B[`hdb;`Q01_cnt_by_sym;`KT;ND;50;{select count i by sym from trade}];
B[`hdb;`Q02_agg_by_sym;`KT;ND;50;
  {select avg price,sum size by sym from trade where date=d0+rand ND}];
B[`hdb;`Q03_sym_filter;`KT;ND;50;
  {select avg price,max price from trade where sym=rand hsyms}];
B[`hdb;`Q04_sym_date_pt;`KT;ND;50;
  {select from trade where date=d0+rand ND,sym=rand hsyms}];
B[`hdb;`Q05_max_by_sd;`KT;ND;30;{select max price by sym,date from trade}];
B[`hdb;`Q06_vwap;`KT;ND;50;
  {select vw:size wavg price by sym from trade where date=d0+rand ND}];
B[`hdb;`Q07_range;`KT;ND;50;
  {select from trade where date=d0+rand ND,price>200}];
B[`hdb;`Q08_dual_grp;`KT;ND;50;
  {select sum size by side,sym from trade where date=d0+rand ND}];
B[`hdb;`Q09_in_filter;`KT;ND;50;
  {select from trade where date=d0+rand ND,sym in 3?hsyms}];
B[`hdb;`Q10_sum_size;`KT;ND;50;{select sum size by sym from trade}];
B[`hdb;`Qc1_compound_where;`KT;ND;50;
  {select from trade where date=d0+rand ND,(price>180)|(price<70)}];
B[`hdb;`Qc2_agg_compound;`KT;ND;50;
  {select avg price by sym from trade where date=d0+rand ND,
    (size>500)&(price<150)}];

-1 "R,DONE,,,,0";
exit 0
