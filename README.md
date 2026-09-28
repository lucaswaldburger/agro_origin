# agro_origin

A junction-proven, contamination-adjudicated fossil record of bacterial DNA in plant genomes.

Agrobacterium transfers a segment of its Ti/Ri plasmid (T-DNA) into plant nuclear genomes. It is
usually discussed as a laboratory technique, but it is a natural process that has left fossils —
**cellular T-DNA (cT-DNA)**, insertions fixed or segregating in naturally transformed plant lineages.
This project reads those fossils at scale, asks whether other bacteria have done the same thing, and
uses the dated insertions to put a clock on the transfer system itself.

## Positioning

The embryophyte-wide census already exists: **Liu et al. 2026**, *Plant J* 127(4):e71087
([10.1111/tpj.71087](https://doi.org/10.1111/tpj.71087)) reported 2,614 naturally transgenic species
— including 82 mosses and 75 ferns — and 149 cT-DNA maps. Their entire stated false-positive control
is one sentence: *"we only retained DNA sequences coding for T-DNA proteins."*

That is a homology filter, not a contamination control, and it is **non-discriminating precisely in
the clades where the disputed claim lives**. What is open is **coordinates, junction proof,
contamination adjudication, and time.**

## Four deliverables

1. **A corrected timeline.** The published inverted-repeat clock has at least four compounding,
   *non-cancelling* errors. `analysis/clock.R` reproduces the discrepancy in three lines of output.
2. **A validated census** behind a twelve-gate exclusion cascade, plus a contamination-adjudication
   report stratified by clade, assembly method, level and submission year.
3. **The moss/fern verdict.** Ships first — it costs workstation-days and needs no reads.
4. **A dated T-DNA cargo phylogeny** and a calibrated upper bound on non-Agrobacterium bacterial HGT.

**Not claimed:** a date for the origin of *vir*/T4SS. cT-DNA is by definition the sequence *inside*
the 25-bp borders; *vir* lies outside and is never transferred.

## Layout

```
workflow/     Nextflow DSL2 pipeline; one module per stage group
configs/      workstation | bigmem (1 TiB) | awsbatch (us-east-1)
resources/    query set, vector screen, truth set and controls, pinned manifest
analysis/     clock correction, Dollo bracketing, biogeography, replay harness
docs/         research program, pre-registration, negative-results register
papers/       method dossier (Minerva / gLM2 / Gaia)
```

## Quick start

```bash
micromamba create -p /mnt/data/agro/env -f environment.yml
cd workflow && nextflow run main.nf -profile workstation
```

**The root filesystem is full** — all work goes under `/mnt/data/agro`. This host has 8 cores, 15 GB
RAM and no GPU, so only S0, S1 and the S3 pilot are workstation-class. Everything from S5 needs a
1 TiB-RAM host, because the FCS-GX database must be RAM-resident. Procurement is a stage-zero blocker
on the critical path.

## Reading order

Start with [docs/research-program.md](docs/research-program.md) — it carries the verified data
landscape, the staged program with its go/no-go gates, the exclusion cascade, and the honest
limitations. Then [docs/pre-registration.md](docs/pre-registration.md) for the decision rules that
are frozen before any data are touched.
