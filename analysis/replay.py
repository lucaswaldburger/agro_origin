#!/usr/bin/env python3
"""S14 -- specification-curve replay.

The entire justification for S5's permissive single pass: because every hit was
stored with full covariate context, each stricter threshold is a <1 s Parquet
filter. Arm A's half of the sensitivity analysis is EXACT REPLAY over thousands
of specifications for under 100 CPU-h -- no recomputation.

Any headline that moves by more than its own stated uncertainty across the
curve is demoted from claim to observation.
"""
from pathlib import Path
import itertools

import duckdb

PARQUET = Path("/mnt/data/agro/parquet")

# Each axis is a threshold that was deliberately NOT baked into the screen.
GRID = {
    "min_flank_kb":       [1, 2, 5, 10],
    "min_junction_reads": [2, 3, 5],
    "min_extractions":    [1, 2],
    "max_evalue":         [1e-3, 1e-5, 1e-10],
    "min_identity":       [0.25, 0.30, 0.35],
}


def specifications():
    keys = list(GRID)
    for combo in itertools.product(*(GRID[k] for k in keys)):
        yield dict(zip(keys, combo))


def replay(con, spec):
    return con.execute(
        f"""
        SELECT count(*) AS n_events
        FROM read_parquet('{PARQUET}/locus_hit.parquet') h
        JOIN read_parquet('{PARQUET}/junction_evidence.parquet') j USING (locus_id)
        WHERE h.flank_kb          >= ?
          AND j.spanning_reads    >= ?
          AND j.n_extractions     >= ?
          AND h.evalue            <= ?
          AND h.pct_identity      >= ?
        """,
        [spec["min_flank_kb"], spec["min_junction_reads"], spec["min_extractions"],
         spec["max_evalue"], spec["min_identity"]],
    ).fetchone()[0]


if __name__ == "__main__":
    con = duckdb.connect()
    for spec in specifications():
        print(spec, replay(con, spec))
