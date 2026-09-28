# Pre-registration

Written at **S0**, before any data are touched. Nothing below is tuned afterwards.

## Frozen before the search

- **Family priors and the DIAGNOSTIC/WEAK partition** — `resources/queryset/panel.tsv`
- **`p_det`**, measured, rate-class-stratified, from in-silico spike-ins pushed through the
  **byte-identical** production stack
- **Detection thresholds** — `workflow/nextflow.config`
- **The minimum useful bound** (see the month-4 gate below)

## Pre-registered decision rules

### S1 — moss/fern verdict

- **REFUTED** if (a) ≥50% of reported hits fall within the identity range spanned by the
  moss-associated non-Rhizobiaceae flora, **and** (b) zero of the ≥20 best-powered candidates yields
  a junction-spanning read from an independent extraction.
- **SUPPORTED** if ≥1 candidate clears all five physical gates.
- **UNRESOLVED** — the modal outcome — if read evidence cannot support the test either way.

The statistic is **per independent lineage, never per species**: ~157 species collapse to ~30–50
lineages, so rule-of-three gives ≤3/40 ≈ **7.5%**, not 3/157 ≈ 1.9%.

**Reproduction gate:** if the published method on the published deposit does not recover ≥80% of the
reported moss/fern hits, the claim is unauditable from its own deposit — reported neutrally as a
data-availability finding, not an accusation.

### S0.5 — power and identifiability

Sets scope; does not stop the program. If simulated root coverage at the achievable K and depth is
<90%, Arm B's deliverable becomes the minimum-age statement plus the thinned-ψ posterior on the
unobserved deep record, and S12's dating grid is descoped **before** it is committed.

### S4 — decoy operating point

If no operating point exists where decoy hits/Gbp < 0.1× true-DB hits/Gbp, the statistical detector
has no usable regime and the project converts entirely to the upper-bound arm. **A legitimate
outcome, not a failure.**

### Month 4 — decision-theoretic gate

If measured Tier-1-eligible sensitivity implies an upper bound **looser than the pre-registered
minimum useful value**, descope to Paper 0 plus the null-track resource and stop.

*Making that call at month 4 instead of month 12 is worth more than any methodological improvement
in this program.*

### Month 18 — resource abort

If no dated catalogue exists, stop and write.

## Pre-registered acceptable negatives

Each of these is a result, not a failure, and each is written up:

- All LM channels fail their nulls → run alignment-only and publish the curve.
- The *vir* concordance test lands at free-reassortment expectation → the *vir* calibration is dead.
- Survivors reach zero at the flank gate → skip to adjudication and write the bound paper.
- The censored regression cannot discriminate *K/r* from *K/(2r)* → report both conventions
  throughout.

## What a null does not license

A zero count is **never** reported as "bacteria other than Agrobacterium have not inserted DNA into
plant genomes." It is reported as a **rate bound per independent lineage** over an explicitly stated
denominator, with the sensitivity curve that makes it quantitative and the detection window named.
