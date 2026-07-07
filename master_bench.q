/ master_bench.q — comprehensive L-only bench: types x primitives x sizes +
/ HDB.  Uses L's built-in tick/tock/profile[] timers, so it does NOT run on
/ the reference engine; use master_compare.q for the head-to-head.
/ -
/ Single self-contained script.  Outputs benchResults_{mac,lin}.csv with the
/ profile[] table (name, total, calls, tmax, tmin, tavg, tdev).  The `name`
/ column is "section,op,type,n" so the CSV can be split downstream.
/ -
/ Use:   l master_bench.q
/        l master_bench.q HDB_ONLY                          / skip micro
/        l master_bench.q MICRO_ONLY                        / skip HDB
/ -
/ Cross-platform: Mac NEON + Linux AVX-512.
/ -
/ NOTE on globals: L's q lambdas (`{...}`) close over GLOBALS at call time,
/ never over enclosing-function locals.  We therefore set test data via the
/ `name set value` form (which always writes to the global namespace) before
/ each bench section.  `xi:N?100` inside a function would be a LOCAL and the
/ lambda passed to B[] would see an unbound name.

-1 "[bench] start";

/ ----- Timing harness -------------------------------------------------- /
ITERS:{[n] $[n<2000;10000; n<20000;3000; n<200000;500; n<2000000;100; 20]}

B:{[sec;op;ty;n;f] nm:`$"," sv (string sec;string op;string ty;string n);
  do[3;f[]]; tick nm; do[ITERS n;f[]]; tock nm;}

/ ----- Section 1: Arithmetic (V2 dispatch: +, -, *, %) ----------------- /

bench_arith:{[N]
  -1 "=== Arithmetic n=",string[N]," ===";
  `xh set `short$N?100; `yh set `short$N?100;
  `xi set N?100;        `yi set N?100;
  `xj set N?100j;       `yj set N?100j;
  `xe set `real$1.0+N?99.0; `ye set `real$1.0+N?99.0;
  `xf set 1.0+N?99.0;       `yf set 1.0+N?99.0;
  / vector-vector
  B[`arith;`add_vv;`KH;N;{xh+yh}];
  B[`arith;`add_vv;`KI;N;{xi+yi}];
  B[`arith;`add_vv;`KJ;N;{xj+yj}];
  B[`arith;`add_vv;`KE;N;{xe+ye}];
  B[`arith;`add_vv;`KF;N;{xf+yf}];
  B[`arith;`sub_vv;`KI;N;{xi-yi}];
  B[`arith;`sub_vv;`KJ;N;{xj-yj}];
  B[`arith;`sub_vv;`KF;N;{xf-yf}];
  B[`arith;`mul_vv;`KI;N;{xi*yi}];
  B[`arith;`mul_vv;`KJ;N;{xj*yj}];
  B[`arith;`mul_vv;`KF;N;{xf*yf}];
  B[`arith;`div_vv;`KF;N;{xf%yf}];
  / scalar-vector (atom on left)
  B[`arith;`add_sv;`KI;N;{42+xi}];
  B[`arith;`add_sv;`KF;N;{1.5+xf}];
  B[`arith;`mul_sv;`KF;N;{2.5*xf}];
  B[`arith;`div_sv;`KF;N;{1.0%xf}];
  / vector-scalar
  B[`arith;`add_vs;`KI;N;{xi+42}];
  B[`arith;`mul_vs;`KF;N;{xf*2.5}];
  };

/ ----- Section 2: Comparison (=, <, >) --------------------------------- /

bench_compare:{[N]
  -1 "=== Compare n=",string[N]," ===";
  `xi set N?100; `yi set N?100;
  `xj set N?100j; `yj set N?100j;
  `xe set `real$N?100.0; `ye set `real$N?100.0;
  `xf set N?100.0; `yf set N?100.0;
  `syms set `AAA`BBB`CCC`DDD`EEE`FFF`GGG`HHH;
  `xs set N?syms;
  `ys set N?syms;
  B[`compare;`eq_vv;`KI;N;{xi=yi}];
  B[`compare;`eq_vv;`KJ;N;{xj=yj}];
  B[`compare;`eq_vv;`KF;N;{xf=yf}];
  B[`compare;`eq_vv;`KS;N;{xs=ys}];
  B[`compare;`eq_va;`KI;N;{xi=50}];
  B[`compare;`eq_va;`KF;N;{xf=50.0}];
  B[`compare;`eq_va;`KS;N;{xs=`AAA}];
  B[`compare;`lt_vv;`KI;N;{xi<yi}];
  B[`compare;`lt_vv;`KF;N;{xf<yf}];
  B[`compare;`lt_va;`KI;N;{xi<50}];
  B[`compare;`lt_va;`KF;N;{xf<50.0}];
  B[`compare;`gt_va;`KI;N;{xi>50}];
  B[`compare;`gt_va;`KF;N;{xf>50.0}];
  };

/ ----- Section 3: Reductions (sum, prd, min, max, avg) ----------------- /

bench_reduce:{[N]
  -1 "=== Reduce n=",string[N]," ===";
  `xh set `short$N?100;
  `xi set N?100;
  `xj set N?1000j;
  `xe set `real$N?100.0;
  `xf set N?100.0;
  `xb set N?2;
  B[`reduce;`sum;`KH;N;{sum xh}];
  B[`reduce;`sum;`KI;N;{sum xi}];
  B[`reduce;`sum;`KJ;N;{sum xj}];
  B[`reduce;`sum;`KE;N;{sum xe}];
  B[`reduce;`sum;`KF;N;{sum xf}];
  B[`reduce;`prd;`KI;N;{prd xi}];
  B[`reduce;`prd;`KF;N;{prd xf}];
  B[`reduce;`min;`KI;N;{min xi}];
  B[`reduce;`min;`KJ;N;{min xj}];
  B[`reduce;`min;`KF;N;{min xf}];
  B[`reduce;`max;`KI;N;{max xi}];
  B[`reduce;`max;`KF;N;{max xf}];
  B[`reduce;`avg;`KI;N;{avg xi}];
  B[`reduce;`avg;`KF;N;{avg xf}];
  B[`reduce;`bsum;`KB;N;{sum xb}];
  B[`reduce;`count;`KI;N;{count xi}];
  };

/ ----- Section 4: Where / Index / In / Within -------------------------- /

bench_where:{[N]
  -1 "=== Where/Index n=",string[N]," ===";
  `xi set N?100;
  `xf set N?100.0;
  `syms set `AAA`BBB`CCC`DDD`EEE`FFF`GGG`HHH;
  `xs set N?syms;
  `idx set (N div 3)?N;
  `in3 set 3?syms;
  B[`where;`ind_vec;`KI;N;{xi idx}];
  B[`where;`ind_vec;`KF;N;{xf idx}];
  B[`where;`ind_vec;`KS;N;{xs idx}];
  B[`where;`where_eq;`KI;N;{where xi=50}];
  B[`where;`where_lt;`KF;N;{where xf<50.0}];
  B[`where;`where_eq;`KS;N;{where xs=`AAA}];
  B[`where;`within;`KI;N;{where xi within (30;70)}];
  B[`where;`within;`KF;N;{where xf within (30.0;70.0)}];
  B[`where;`in_vec;`KS;N;{where xs in in3}];
  };

/ ----- Section 5: Sort / Group / Distinct ----------------------------- /

bench_sort:{[N]
  -1 "=== Sort n=",string[N]," ===";
  `xi set N?100000;
  `xj set N?100000j;
  `xf set N?100000.0;
  `syms set `AAA`BBB`CCC`DDD`EEE`FFF`GGG`HHH;
  `xs set N?syms;
  `xi15 set xi&15;
  B[`sort;`asc;`KI;N;{asc xi}];
  B[`sort;`asc;`KJ;N;{asc xj}];
  B[`sort;`asc;`KF;N;{asc xf}];
  B[`sort;`asc;`KS;N;{asc xs}];
  B[`sort;`distinct;`KI;N;{distinct xi}];
  B[`sort;`distinct;`KS;N;{distinct xs}];
  B[`sort;`group;`KI;N;{group xi15}];
  B[`sort;`group;`KS;N;{group xs}];
  };

/ ----- Section 6: Joins ------------------------------------------------ /

bench_joins:{[N]
  -1 "=== Joins n=",string[N]," ===";
  `syms set `AAA`BBB`CCC`DDD`EEE`FFF`GGG`HHH;
  `big set ([] sym:N?syms; v:N?100.0);
  `ref set ([sym:syms] sector:`tech`fin`tech`tech`con`con`tech`con;
    w:0.1*1+til count syms);
  B[`join;`lj;`tbl;N;{ref lj `sym xkey select avg v by sym from big}];
  B[`join;`ij;`tbl;N;{ref ij `sym xkey select avg v by sym from big}];
  B[`join;`xkey;`tbl;N;{`sym xkey select avg v by sym from big}];
  };

/ ----- Section 7: HDB queries -- diverse workload ---------------------- /

bench_hdb:{[]
  -1 "=== HDB diverse workload ===";
  `base set "/tmp/master_bench_hdb";
  system "rm -rf ",base;
  system "mkdir -p ",base,"/hdb";
  `ndays set 30; `nrows set 500000;
  `syms set `IBM`MSFT`AAPL`GOOG`AMZN`META`NVDA`TSLA`AMD`INTC`QCOM`AVGO`CRM,
    `ORCL`ADBE`NFLX;
  `exchs set `NYSE`NASD`ARCA`BATS`IEX`EDGX;
  `d0 set 2024.01.01;
  writeday:{[bs;syl;exl;nr;dt]
    trade::([]date:nr#dt;sym:nr?syl;price:50.0+nr?200.0;size:100*1+nr?1000;
      side:nr?`B`S;exch:nr?exl);
    .Q.dpft[`$":",bs,"/hdb";dt;`sym;`trade]};
  i:0; do[ndays; writeday[base;syms;exchs;nrows;d0+i]; i+:1];
  system "l ",base,"/hdb";
  `NQ set 100;
  / Each timer name encodes "section,op,type,n" with 30=ndays partitions.
  hdbT:{[op] `$"hdb,",(string op),",KT,30"};
  tick hdbT`Q01_count_by_sym;
  do[NQ;select count i by sym from trade];
  tock hdbT`Q01_count_by_sym;
  tick hdbT`Q02_agg_by_sym;
  do[NQ;select avg price, sum size by sym from trade where date=d0+rand 30];
  tock hdbT`Q02_agg_by_sym;
  tick hdbT`Q03_sym_filter;
  do[NQ;select avg price, max price from trade where sym=rand syms];
  tock hdbT`Q03_sym_filter;
  tick hdbT`Q04_sym_date_point;
  do[NQ;select from trade where date=d0+rand 30, sym=rand syms];
  tock hdbT`Q04_sym_date_point;
  tick hdbT`Q05_max_by_sym_date;
  do[NQ;select max price by sym,date from trade];
  tock hdbT`Q05_max_by_sym_date;
  tick hdbT`Q06_vwap_date;
  do[NQ;select vwap:size wavg price by sym from trade where date=d0+rand 30];
  tock hdbT`Q06_vwap_date;
  tick hdbT`Q07_range_filter;
  do[NQ;select from trade where date=d0+rand 30, price>200];
  tock hdbT`Q07_range_filter;
  tick hdbT`Q08_dual_group_by;
  do[NQ;select sum size by side, sym from trade where date=d0+rand 30];
  tock hdbT`Q08_dual_group_by;
  tick hdbT`Q09_in_filter;
  do[NQ;select from trade where date=d0+rand 30, sym in 3?syms];
  tock hdbT`Q09_in_filter;
  `ref set ([sym:syms]
    sector:`tech`fin`tech`tech`con`con`tech`con`fin`fin`tech`tech`tech,
      `tech`tech`con;
    weight:0.01*1+til count syms);
  tick hdbT`Q10_lj_ref;
  do[NQ;ref lj `sym xkey select avg price by sym from trade
    where date=d0+rand 30];
  tock hdbT`Q10_lj_ref;
  };

/ ----- MAIN ------------------------------------------------------------ /

args: $[count .z.x; .z.x; ()];
do_micro: not `HDB_ONLY in `$args;
do_hdb:   not `MICRO_ONLY in `$args;

run_micro:{
  -1 "-- MICROBENCH --";
  {bench_arith   x} each 1000 10000 100000 1000000;
  {bench_compare x} each 1000 10000 100000 1000000;
  {bench_reduce  x} each 1000 10000 100000 1000000;
  {bench_where   x} each 100000 1000000;
  {bench_sort    x} each 10000 100000 1000000;
  {bench_joins   x} each 10000 100000;};
if[do_micro; run_micro[]];
if[do_hdb;   bench_hdb[]];

/ ----- Output ---------------------------------------------------------- /
r: profile[];
-1 "-- RESULTS (",string[count r]," timers) --";
host: $["m" = (string .z.o)[0]; "mac"; "lin"];
csv_path: `$":/tmp/benchResults_",host,".csv";
csv_path 0: csv 0: r;
-1 "Saved: ",string csv_path;
show r;
exit 0
