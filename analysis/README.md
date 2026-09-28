# Analysis

Downstream of the Nextflow pipeline. Reads the Parquet lake under `/mnt/data/agro/parquet`.

| Script | Stage | Purpose |
|---|---|---|
| `clock.R` | S9 | Re-derive published cT-DNA ages under one stated convention; GENECONV/PHI gene-conversion test |
| `bracketing.R` | S9 | Dollo-constrained stochastic mapping to per-event gain-time posteriors |
| `biogeobears.R` | S10 | Ancestral range estimation — **secondary**, behind an information gate |
| `replay.py` | S14 | Specification-curve replay over the stored hit table |

**The replay harness is the point of the permissive single pass.** Because S5 stored every hit with
full covariate context, every stricter threshold is a `<1 s` Parquet filter — so Arm A's half of the
sensitivity analysis is *exact replay* over thousands of specifications for **under 100 CPU-h**.
Only the Bayesian dating needs an emulator.
