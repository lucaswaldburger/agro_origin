# Query set (QS-A … QS-F)

Built at S2, **frozen and checksummed before the search is run**, never tuned afterwards.

| Part | Contents |
|---|---|
| **QS-A** | ~250 complete pTi/pRi plasmids ≥100 kb. Verified coordinate anchors: `AE007871.2`, `AF242881.1`, `DQ058764.1`, `AB016260.1`, `AP002086.1`, `CP073113.1`, `AJ271050.1` |
| **QS-B** | Curated seed proteins |
| **QS-C** | **Per-subfamily** profile HMMs |
| **QS-D** | Border / overdrive / TSS motif models |
| **QS-E** | Decoys — both statistical and ecological (see below) |
| **QS-F** | Read-through panel: `virE2`, `repABC`, `tra`/`trb`, opine catabolism |

## QS-C: the plast superfamily must be split

Members share only **20–30% amino-acid identity**. Reciprocal-best-hit merges `rolB` with `orf13`
and shatters `rolC`. Model each subfamily separately or the panel is wrong.

## The panel partition

`panel.tsv` partitions every family **DIAGNOSTIC vs WEAK** on frozen priors, set before any data are
touched. **A family hit is never evidence of Agrobacterium origin on family membership alone** — and
that is precisely where the 82 moss / 75 fern records live.

## QS-E: two decoys, and their disagreement is the diagnostic

- **Statistical decoy** — ecology-broken taxa (Halobacteria, Thermococci, deep-sea Aquificae,
  obligate vertebrate pathogens), matched to the true donor DB on GC, genome size, protein-family
  composition and phylogenetic depth. *Deinococcus* excluded as a documented kit/reagent contaminant;
  *Chlamydiia* excluded because it carries real plant-HGT signal.
- **Ecological decoy (D3)** — built **by taxid lineage** from plant endophytes, seed/rhizosphere taxa
  and litter fungi that actually carry the diagnostic domains.

The statistical decoy measures FDR and is constitutionally blind to contamination by plausible
donors; D3 covers that blind spot. **concordance-FDR ≫ decoy-FDR means the residue is contamination,
not statistics.**

Stratify by gene-family: decoy Halobacteria also encode ribosomal and core metabolic families, so a
single threshold biases survivors toward bacteria-restricted accessory genes — and the resulting
bound is a bound on HGT *of bacteria-restricted families*, not on bacteria-to-plant HGT.
