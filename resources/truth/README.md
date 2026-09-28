# Truth set and controls

The **bidirectional control harness** runs end to end alongside the real analysis and is reported in
the same tables. Without it, "we found no deep insertion" is indistinguishable from detection failure
and is unpublishable.

| File | Role |
|---|---|
| `known_ctdna_loci.tsv` | Positive controls. Must be recovered at the S2-measured recall **through the production streaming path** — an end-to-end regression, not a unit test. |
| `negative_controls.tsv` | Must stay negative. Includes `KJ599825`, the *N. sylvestris* **empty** TA insertion site — a NEGATIVE that is misfiled as a positive in at least one secondary source. |

## Spike-in ladders

Two families are required, and the second is the one everybody forgets.

1. **Decay ladder** — `{1,2,5,10,20,30,50,75,100,150,200}` My × `{neutral, codon}` × 200 reps ×
   **four host rate classes**, full ~25 kb loci with inverted-repeat architecture, flanks, borders
   and realistic indels; spiked into 12 real hosts spanning the **rate** range, not just the size
   range. Pushed through the **byte-identical** production stack.

2. **Contaminant spike-ins — mandatory.** Foreign contigs and artificial chimeric junctions injected
   into the assembly *while absent from or discordant with the matched read set*.

   Why: the decay ladder implants segments at random single-copy loci **in assemblies**, which is
   (a) exactly where real ancient inserts do *not* survive — survivors sit in heterochromatin, are
   TE-colonised, and are subject to gene conversion and biased deletion — and (b) an object that
   **cannot fail the junction gates, because it is not in the reads at all**. Without contaminant
   spike-ins the calibration corpus contains **no object that exercises the dominant failure mode**.

Even with both, the ladder's realism is validated against only ~27–30 published decay trajectories.
