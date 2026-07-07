#!/usr/bin/env python3
"""Reduce two master_compare.q runs to per-op ratios and section geomeans.

Usage:
    l     master_compare.q > l.csv      # L
    <ref> master_compare.q > ref.csv    # reference engine
    python3 compare.py l.csv ref.csv

Only lines of the form "R,section,op,type,n,ms" are read; everything else
on stdout is ignored.  For every op present in both runs it prints
    ratio = ref_ms / l_ms        (ratio >= 1  =>  L is faster on that op)
then a per-section geometric mean and the overall geomean.  Ops where
either side measured under 10 ms total are flagged "~" (timer noise).
"""
import math
import sys

NOISE_MS = 10.0                                                                 # below this, timing is noise
SEC_W = 10                                                                      # shared width of "section" column


def load(path):
    """Return {(section, op, type, n): total_ms} from one run's stdout."""
    out = {}
    with open(path) as f:
        for line in f:
            cols = line.strip().split(",")
            if len(cols) != 6 or cols[0] != "R" or cols[1] == "DONE":
                continue
            try:
                out[tuple(cols[1:5])] = float(cols[5])
            except ValueError:
                pass
    return out


def geomean(xs):
    return math.exp(sum(math.log(x) for x in xs) / len(xs)) if xs else 0.0


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    l, ref = load(sys.argv[1]), load(sys.argv[2])
    keys = [k for k in l if k in ref and l[k] > 0 and ref[k] > 0]
    if not keys:
        sys.exit("no comparable ops (did both runs finish?)")
    print(f"{'section':{SEC_W}s}{'op':22s}{'type':6s}{'L ms':>9s}"
          f"{'ref ms':>9s}{'ref/L':>9s}")
    sections = {}
    for k in sorted(keys):
        lm, rm = l[k], ref[k]
        r = rm / lm                                                             # ref/L: >= 1 means L is faster
        noisy = "~" if min(lm, rm) < NOISE_MS else " "
        print(f"{k[0]:{SEC_W}s}{k[1]:22s}{k[2]:6s}{lm:>9.0f}{rm:>9.0f}"
              f"{r:>8.2f}x{noisy}")
        sections.setdefault(k[0], []).append(r)
    print()
    print(f"{'section':{SEC_W}s}{'ops':>4s}{'geomean ref/L':>15s}")
    for sec in sorted(sections, key=lambda s: -geomean(sections[s])):
        print(f"{sec:{SEC_W}s}{len(sections[sec]):>4d}"
              f"{geomean(sections[sec]):>14.2f}x")
    allr = [r for rs in sections.values() for r in rs]
    print(f"{'OVERALL':{SEC_W}s}{len(allr):>4d}{geomean(allr):>14.2f}x"
          "   (>1 = L faster)")


if __name__ == "__main__":
    main()
