# A junction-proven fossil record of bacterial DNA in plant genomes

## Context

### The question

Agrobacterium transfers a segment of its Ti/Ri plasmid (T-DNA) into plant nuclear genomes. It is
usually discussed as a laboratory technique, but it is a natural process that has left fossils:
**cellular T-DNA (cT-DNA)**, ancient insertions fixed or segregating in naturally transformed plant
lineages. This project reads those fossils at scale, asks whether *other* bacteria have done the same
thing, and uses the dated insertions to put a clock on the transfer system itself.

### What has already been done

The census this project originally set out to perform **has been published**. Liu H, Wang W, Li J,
He Y, Cao S, Hu Z, Liu Y, Hao J, Yan Y, Otten L, Chen K (2026), *Embryophyte-wide detection of
natural Agrobacterium-mediated horizontal gene transfer reveals an ancient role for mini T-DNAs*,
**Plant J 127(4):e71087** ([10.1111/tpj.71087](https://doi.org/10.1111/tpj.71087), PMID 42606503,
PMC13480146) screened all public land-plant WGS *and* SRA and reported **2,614 naturally transgenic
species** (2,452 angiosperms, 5 gymnosperms, **82 mosses, 75 ferns**), **149 cT-DNA maps**, and a
claim that **"mini T-DNAs"** carrying a single opine-synthase gene are the **ancestral** T-DNA type.

Their entire stated false-positive control is one sentence: *"we only retained DNA sequences coding
for T-DNA proteins."* That is a homology filter, not a contamination control — and §3 below shows it
is **non-discriminating precisely in the clades where the disputed claim lives**.

**The opportunity is not the census. It is coordinates, junction proof, contamination adjudication,
and time.** Arm A is deliberately *replication with rigour*; the plan says so rather than claiming
priority it does not have.

### The four deliverables

| # | Deliverable | Why it is open |
|---|---|---|
| **1** | **Corrected timeline of natural transformation** | The field's clock is wrong in several compounding, *non-cancelling* ways. |
| **2** | **Validated census + contamination adjudication** | 2,614 species from protein homology alone is the failure mode that produced the tardigrade affair. |
| **3** | **The moss/fern verdict** | The only claimed pre-spermatophyte cT-DNAs, hence the only route to depth. Cheap, sharp, falsifiable — and it ships first. |
| **4** | **Dated T-DNA cargo phylogeny + a bound on non-Agrobacterium bacterial HGT** | Nobody has dated the system; nobody has put a calibrated upper bound on other donors. |

### The clock problem

Published cT-DNA ages nearly all use one method: cT-DNAs are typically partial **inverted repeats**,
identical at integration, so divergence between the arms is an internal clock. Divergence is
converted with "the plant rate," 6.5×10⁻⁹ subs/site/yr. Four problems, and **they do not cancel**:

1. **Factor of two (biases OLD).** *Camellia* CaTA: 9.7% divergence → reported "~15 Myr". But
   0.097 / 6.5×10⁻⁹ = 14.9 Myr = *K/r*, not *K/(2r)*. The standard convention gives **~7.5 Myr**.
   Matveeva 2025 flagged this for *Camellia*; **whether it propagates to *Diospyros*** (Otten et al.
   2025, Plant J 122(3):e70202, PMID 40359552 — "3–12 Mya", same method, same constant) is
   unresolved.
2. **Gene conversion between the repeat arms (biases YOUNG).** Concerted evolution resets intra-locus
   divergence, heterogeneously, worse for older loci. **Untested anywhere.** Because it pushes the
   opposite way from (1), the two errors do **not** bracket each other.
3. **Wrong rate, wrong lineage, wrong site class (2–3×, possibly larger than the error being
   corrected).** The constant traces to Gaut et al. 1996 *PNAS* 93:10274 (PMID 8816790):
   **2.61×10⁻⁹ per *synonymous site* per year for palm *Adh***, grasses ~2.5× faster. It is being
   applied to **non-functional non-coding DNA in eudicots, mosses and ferns.**
4. **No multiple-hits correction** at ~10% divergence.

**Honest deliverable:** with ~27–30 loci spanning clades of genuinely different true rates and
left-censored brackets, a censored regression is very likely **unidentifiable**. The realistic output
is a **uniform arithmetic re-derivation under one stated convention with order-of-magnitude
intervals** — plus the first gene-conversion test on cT-DNA arms — **not** a newly calibrated rate.
Both conventions get reported throughout, which is itself a service, since the literature currently
applies one without saying which.

### The verified data landscape

Measured live on 2026-09-24, independently reproduced by an adversarial verification pass.

| Resource | Reality |
|---|---|
| NCBI Viridiplantae current assemblies | **10,349** (Embryophyta 9,711; eudicots 6,880; monocots 2,092; gymnosperms 72; **mosses 268, ferns 33**, liverworts 100, hornworts 5) |
| Chromosome/Complete | 5,381 |
| **Carrying any NCBI annotation** | **1,123 (10.8%)** — the pipeline must call its own ORFs |
| Total sequence | **12.418 Tbp** → ~3.73 TB gzipped |
| One best assembly per species (4,099 spp.) | **1.46 TB** — the only Tier-1 target that fits a workstation |
| Ensembl Plants r63 | 267 genomes; **261 already in NCBI** — adds gene models, ~zero new sequence |
| SRA/ENA Viridiplantae | **~2.85–2.98M samples**; **319,619 (11.2%) georeferenced** |
| Assembly `lat_lon` usable | 571 (5.5%) NCBI-style + 1,933 (18.7%) ENA-style, **disjoint** → 24.2% |

Three consequences:

- **SRA is the real corpus.** Most species with a Liu detection have no assembly.
- **A parsing trap that discards the wild-collected genomes.** ENA-style
  `geographic location (latitude)/(longitude)` carry **no `harmonized_name`**, so a parser keyed on
  `harmonized_name == "lat_lon"` drops 77% of georeferenced plant genomes. Georeferencing is an
  **ID-join problem**: PRJEB6180 (3K Rice) has no country/lat/lon at all; PRJNA273563 (1001G) has
  lat/lon on **zero** of 1,135; PRJNA532579 (wild *Helianthus*) has both on 1,527/1,527 and is the
  reference-quality testbed.
- **Ascertainment, quantified.** China 24.5%, USA 17.6%, UK 16.6%; Africa + South America under 4%.
  Bimodal by submitter (Sanger 98.9% georeferenced; Iridian Genomes 0/646).

**Free contamination prior.** Every assembly ships `<asm>_fcs_report.txt` naming
`prok:a-proteobacteria` intervals. Bulk: `fcs_summary_genbank.txt.gz` (52.7 MB) +
`fcs_details_genbank.txt.gz` (475 MB, 52.8M rows) — **530 MB and ten minutes instead of a 464 GiB
resident database.** But FCS-GX is a **prior, never a verdict**: it explicitly ignores intra-kingdom
chimeras **below 10 kbp — exactly our size class** — and its database has not been rebuilt since
**2023-01-24**, so every bacterium described since is invisible to it.

### The compute reality — verified on this machine

**8 cores, 15 GB RAM, no GPU.** `/` is **100% full** (838 MB of 150 GB); `/mnt/data` has **860 GB**.
Installed: `blastn`, `tblastn`, `R`, bare `python3`, `pigz`, `curl`. Absent: diamond, hmmer, mmseqs2,
minimap2, miniprot, seqkit, bedtools, samtools, datasets, nextflow, aws — and numpy, pandas,
biopython, scipy, pyarrow, duckdb, torch.

**Say plainly that the workstation tier is not met rather than quietly renting a bigger node.** S0,
the moss/fern refutation and the anchorability gate are genuinely workstation-class. The first
analytical stage needs a **1 TiB-RAM host**, because FCS-GX's database must be RAM-resident and a
512 GB workstation is 476 GiB — below requirement once OS and page cache are counted, squarely in
the ~10,000× penalty regime. Conterminator + MMseqs2 does not restore the tier either.

### Locked decisions

| Decision | Choice |
|---|---|
| **Positioning** | Re-validate and extend; Liu's calls are a candidate set. |
| **Goals** | All four deliverables on shared infrastructure. |
| **Data** | Three tiers: all assemblies **+ SRA**; georeferenced panels; GBIF fallback. |
| **Genome LM** | Targeted, behind a failable benchmark (§6). |
| **Compute** | S0/S3 on this box; 1 TiB-RAM host from the first analytical stage. |
| **Validation** | **Computational only.** No wet lab, no herbarium. |
| **Deliverable** | Staged program **and** executable repo scaffold. |
| **Horizon** | 30 months, both arms, staged publications. |

---

## 1. The thesis

A cellular T-DNA is an **ichnofossil of a phenotype**: a dated, junction-proven, orthologous
chromosomal event whose age is a hard minimum on the existence of a T-DNA-transferring bacterium —
*requiring no assumption about bacterial sequence evolution*. That sentence survives every bad
outcome.

**Pre-registered headline:** a clock-free minimum age for the transformation phenotype, **plus** a
measured detection function `p_det`, **plus** a posterior on the **unobserved deep fossil record**.

**Not claimed:** a date for the origin of *vir*/T4SS. cT-DNA is by definition the sequence *inside*
the 25-bp borders; *vir* lies outside and is never transferred. **The most quotable version of the
original title claim is not deliverable**, and the plan says so in the abstract. *vir* is answered by
a concordance test, or — with low prior — by a border read-through fossil.

Two further constraints on Arm B, both classic fossil-calibration errors:

- A cT-DNA insertion bounds the **stem of the cargo lineage**, not the **crown of the plasmid clade**.
- With every calibration in one shallow horizon (≤12 Myr, ≤7.5 Myr post-correction), no epoch or
  time-dependent-rate model is identifiable and every deep node is prior-dominated. **A root age must
  not be printed.**

---

## 2. Staged program

Ordering principle: **run the decisive cheap tests first.** The two highest-prior-of-being-true
results (the moss/fern refutation and the contamination adjudication) are primary aims, not stop
conditions.

| Stage | What | Compute | Gate | Output |
|---|---|---|---|---|
| **S0** | Freeze refs (checksum-pinned; FCS-GX at build `2023-01-24`, never `latest`), pre-register, **quarterly** scoop audit | trivial, this box | — | Pre-registration |
| **S0.5** | **Day-one power/identifiability gate.** Needs only K, fossil depth, tree depth — in hand by day 2 | **<200 CPU-h, this box** | *Sets scope.* If root coverage <90%, Arm B's deliverable becomes the minimum-age statement + unobserved-record posterior, and the 60–150k CPU-h grid is descoped **before** commitment | `power_identifiability_day1.md` |
| **S1** | **Moss/fern refutation (§3)** — ships as a standalone Matters Arising | **workstation-days, zero reads** | Pre-registered REFUTED / SUPPORTED / UNRESOLVED rule | **Paper 0, month 1–2** |
| **S2** | Query set QS-A…QS-F + rate-stratified decay ladder + `p_det` surface + **LM benchmark (§6)** | ~3,000 CPU-h + <2 GPU-days | GO if recall ≥0.80 @20 My, ≥0.50 @50 My **and decoys yield zero passes** | The `p_det` surface — reusable by any ancient-HGT study |
| **S3** | **Pilot: 8 known-carrier genera** → junction-proven, bracket-dated locus cards | ~1,500 CPU-h, 120 GB streamed — **this box** | GO only if the pilot recovers truth-set loci through the **production streaming path**. **Gate on the conversion rate of known true positives to Tier 1** — this is the gating feasibility number for half the program and is unmeasurable until now | First junction-proven locus-card corpus |
| **S4** | **Decoy operating-point test** | ~2,000 CPU-h | **If no operating point exists where decoy hits/Gbp < 0.1× true-DB hits/Gbp, the statistical detector has no usable regime and the project converts entirely to the upper-bound arm** — a legitimate outcome | Decoy-calibrated FDR curve |
| **month 4** | **Decision-theoretic gate** | — | **If measured Tier-1 sensitivity implies a bound looser than the pre-registered minimum useful value, descope to Paper 0 + the null-track resource and stop.** Making this call at month 4 rather than month 12 is worth more than any methodological improvement in this plan | — |
| **S5** | Tier-1 permissive census — one expensive pass, stored exhaustively, replayed forever | 15–60k CPU-h, 3.73 TB streamed; **1 TiB-RAM host** | GO on S3 throughput; marginal-yield checkpoints *during* the stage | `locus_hit.parquet` — permanent replayable artefact |
| **S6** | Twelve-gate exclusion cascade (§4) + contamination adjudication | ~5,000 CPU-h + FCS burst node | GO if ≥60% of re-detected Liu species survive **and** spike-ins survive ≥95% | Attrition table; **Paper 1** |
| **S7** | Junction proof from **unassembled reads** + four-level graded absence | ~20,000 CPU-h, 30–60 TB transient — **run in-region (AWS us-east-1)** | **Absolute gate for Arm B.** One false "80 My" fossil poisons the timetree | `junction_evidence.parquet` |
| **S8** | **Events, not loci**: cargo **AND** site orthology must agree | ~2–3k CPU-h | Species:event inflation 5–20× (Liu's 2614/149 = 17.5×); κ ≥0.7 | `insertion_event.parquet` |
| **S9** | Dated backbone (Carruthers 2026, 128,270 tips, **1,000 replicate chronograms**) + Dollo bracketing | ~15,000 CPU-h | Routes agree within 2× for ≥60% of two-route events. **Repeat clock excluded from the gate until its gene-conversion test passes** | `age_draw.parquet`; **Paper 2** |
| **S10** | **WHERE**: Tier-2 allele frequency at real coordinates *primary*; DEC *secondary*; ascertainment atlas *promoted* | ~1,500 CPU-h | Report geography only if it survives a balanced subsample **and** a phylogenetic permutation null (a species-level test rejects at **51.2%** under a pure null) | Allele-frequency maps; atlas |
| **S11** | Arm B substrate + **the *vir* verdict** (9,747 Rhizobiaceae assemblies, 0.059 Tbp) | ~10–20k CPU-h | **The only test of *vir*.** If T-DNA↔*vir* concordance is at free-reassortment expectation, the calibration is dead and that is the result | Cargo + VirB4 + backbone trees with concordance factors |
| **S12** | Fossil placement (EPA-ng posterior, nestedness gate, LBA diagnostics) + detection-conditioned dating | 60–150k CPU-h **or control scope only** | Publish a root age only if posterior HPD ≪ prior-only, coverage ≥90%, stable across the grid. **Most likely: do not print one** | Dated cargo chronology + identifiability audit |
| **S13** | Cargo repertoire evolution + mini-T-DNA test on a dated tree + **read-through hunt** | ~3,000 CPU-h | Ancestrality verdict only if stable across evidence strata. If it flips when low-evidence records are excluded, the honest result is "not currently testable" | `vir_fossil.tsv` or a quantitative upper bound |
| **S14** | Uncertainty budget, specification curve, red team, negative register | **Arm A replay <100 CPU-h** | **Resource abort: no dated catalogue by month 18 → stop and write** | Negative-results register; provenance bundle |

---

## 3. The moss/fern refutation — runs first, costs workstation-days

This is the cheapest decisive result in the program, it needs **no reads, no 1 TiB node, and no
corpus freeze**, and the scoop window on a trivially reproducible critique of a just-published paper
is weeks, not months. Three components:

**(1) The chance-homology null, as a full distribution.** Cucumopine synthase is **Pfam PF18631**, a
Pictet-Spenglerase domain shared with actinomycete and fungal enzymes. Rebuild the complete PF18631
set from UniProt, blastp *Rhizobium rhizogenes* Cus (**Q9FAF7**, 320 aa) against all of it, and
publish the identity distribution **by donor lineage**. Verified anchors:

- ***Mycena alexandri*** — a moss and litter agaric — encodes a protein **58.8% identical** to
  Agrobacterium Cus at **E = 2.8×10⁻¹⁴¹**, *a better match than any fern protein*.
- ***Microvirga puerhi*** reaches **87.7%**.
- **A0A6I4MBU2** sits in ***Actinomadura physcomitrii* LD22(T)** — an endophytic actinomycete
  **isolated from moss** (*Physcomitrium sphaericum*).

This alone establishes that Liu's stated safeguard cannot separate a moss endophyte from a moss mini
T-DNA.

**(2) The corpus-arithmetic lever.** Liu report cT-DNA in **75 fern species**; GenBank holds **28
fern assemblies across 21 binomials**. 75 > 21, so the fern signal **cannot rest on assemblies** — it
is necessarily SRA-derived, from Polypodiopsida read pools (4,481 runs, 1,166 species, 86% Illumina)
that are overwhelmingly low-coverage skims of field-collected material: the most bacteria-contaminated
data class in plant genomics.

Then the **taxid-misfiling trap**, verified in session: seven GCA records filed under *Azolla* taxids
are 4.70–4.87 Mb at 38.5% GC — the *Nostoc azollae* cyanobiont, not a fern. And it generalises beyond
ferns and beyond cyanobionts: **GCA_965284325.1**, filed under tax_id 1291455 *Aquilegia reuteri* (a
eudicot), has `assembly_name = NI281-mx-bin04` — a metagenome bin — **4,044,082 bp in one contig at
38.5% GC, at assembly_level COMPLETE GENOME**, i.e. sitting in the highest-contiguity stratum every
Tier-1 cohort draws from. One in 1,000 records, so ~5 expected in the 5,067-record embryophyte
chromosome/complete set.

**(3) The decisive physical test on the published inputs.** Pull the deposited repository (7,163
FASTA, of which **7,149 are Git-LFS pointers** — requires `git lfs`, not raw fetch), re-run the
published method on the published inputs, then push the identical hit set through the cascade and
publish attrition species by species. Survivors must clear: ≥2 kb unique plant flank on **both**
junctions; ≥5 junction-spanning long reads from **≥2 independent DNA extractions** (not two libraries
off one prep, which share the contaminant and the chimera-forming steps); presence in ≥2 independent
accessions from independent labs; a clean colinear empty site in a congener **whose scaffold N50
exceeds the query length** — check this *before* aligning, since a 41 kb query cannot be anchored in
an N50 = 16,242 bp assembly; and Hi-C anchoring where available. **This bar already exists in the
clade** — Marchant et al. anchored the *Ceratopteris* chromosome-9 aerolysin array by Hi-C to prove
it was host and not contaminant.

**Pre-registered decision rule.** **REFUTED** if (a) ≥50% of reported hits fall within the identity
range spanned by the moss-associated non-Rhizobiaceae flora, **and** (b) zero of the ≥20 best-powered
candidates yields a junction-spanning read from an independent extraction. **SUPPORTED** if ≥1
candidate clears all five physical gates — which would overturn the dicot-bias assumption.
**UNRESOLVED** (the modal outcome) if read evidence cannot support the test either way.

**The statistic is fixed in advance and is per lineage, never per species:** ~157 species collapse to
roughly **30–50 independent lineages**, so the rule of three gives **≤3/40 ≈ 7.5%**, not 3/157 ≈
1.9%. That discipline is the difference between an honest correction and an overclaim in the opposite
direction.

Separately pre-register a **reproduction gate**: if the published method on the published deposit
does not recover ≥80% of the reported moss/fern hits, the claim is unauditable from its own deposit —
reported neutrally as a data-availability finding, not an accusation.

---

## 4. The exclusion cascade

Twelve gates, cheapest first, **ahead of all scoring**. Each is an alternative explanation with a
near-certain likelihood ratio, never a weak channel a bit score can outvote. Abbreviated:

| Gate | Test | Note |
|---|---|---|
| **G0 Provability** | Assembly must be Tier 1/2: contig N50 ≥1.115 Mb at P=0.90 for insert + 2×20 kb flanks; ≥1 linked run from ≥2 **independent DNA extractions**; ≥1 comparator for the empty-site test | **A candidate is never reported from a genome that could not have proven it.** Tier 4 genomes are in neither numerator nor denominator |
| **G1 Organellar descent** | Stratified **by donor divergence bin, never summed over bases** | Highest-volume gate. NUPTs are 0.02–0.70% of nuclear genomes (3.29% in *Moringa*); the Arabidopsis chr2 NUMT alone is **641 kb at 99.933%**. A bases-summed gate passes at 99% while every divergent NUMT sits in the residual — and a NUMT past ~15–25% divergence is invisible to both aligners while its alphaproteobacterial protein signal survives easily |
| **G2 Promiscuous mobile domain** | HUH/Rep, DDE transposase, RT, integrase with no flanking bacterial context | **Run the detector on UNMASKED sequence.** Masking deletes the highest-prior true positives: a 120-aa 100%-identity hit at E=1.47e-91 collapses to an 8-aa E=2.5 hit under `-lcase_masking` and vanishes under hard-masking. Repeat annotation is a post-hoc covariate BED, never an edit |
| **G3 Contamination cartography** | Blobplot GC×coverage disjoint from host mode; discordant coverage across independent libraries (the Koutsovoulos 2016 tardigrade signature) | **Must be stratified by assembly tier** — the <200 kb rule can never fire on chromosome-level assemblies, so unstratified attrition is confounded with assembly quality and will be misread as biology |
| **G4 Database artefact** | Same block at high identity in a bacterial assembly — check **both** directions | Symmetric hits are artefacts |
| **G5 EGT** | **Called per genome phylogenetically, never projected from Arabidopsis** | EGT sits at the **base** of a monophyletic Archaeplastida clade, carries spliceosomal introns and a transit peptide; genuine HGT is **nested inside** extant bacterial diversity, lineage-patchy, intron-free. **Physical anchoring has zero power here** — an EGT passes every junction gate cleanly — so this gate cannot be deferred past the trees |
| **G6 Flank** | ≥2 kb unique plant-assignable sequence on both junctions | Relaxation must report the measured junction FPR increase, never absorb it |
| **G7 Decoy-matched score** | **Two** decoys: an ecology-broken statistical decoy, and an **ecologically-plausible-contaminant** decoy built by taxid lineage from plant endophytes | **The disagreement between them is the diagnostic, not their average.** Concordance-FDR ≫ decoy-FDR means the residue is contamination, not statistics |
| **G8 Ku & Martin 70% rule** | CDS ≥70% aa identity to a prokaryotic homolog → **mandatory physical proof**, not auto-reject | A genuinely recent transfer is indistinguishable from a contaminant by homology alone; state that limit openly |
| **G9 Physical junction from unassembled reads** | **The single stand-alone veto.** Junction 31-mers in ≥2 independent extractions; k-mer-baited local reassembly in which the junction is a **simple unbranched path**, not a bubble | k=31 because 31-mer chance occurrence in ~700 Gbp is ~3×10⁻⁷ vs ~0.32 at k=21. A contaminant contig's junction is an assembly chimera, so its junction k-mers exist in **zero** libraries |
| **G10 Independent material** | ≥2 accessions, independent extractions, independent labs | The one signal separating a resident insert from an endophyte tracking the source population |
| **G11 Empty site** | Insert + 20 kb flanks onto every congener; **check comparator N50 first** | Converts a locus into a dated event. **Caveat:** an ancient genuine HGT fixed before every sampled crown has no empty site anywhere — exactly like an EGT — so the surviving class is biased toward young, contiguous insertions and the headline must say so |
| **G12 Donor topology** | Donor call at the **deepest rank the data supports and no deeper** | `iqtree3 -z constraints -zb 10000 -au` (**`-au` does nothing without `-zb`**). Test the fungal alternative explicitly — nicotianamine synthase in plants is overwhelmingly a fungal story. **Alphaproteobacterial affinity alone can never yield a genus-rank call** |

**Bidirectional control harness**, run end to end and reported in the same tables: known-real loci
recovered; planted contaminants caught at a measured rate; **KJ599825** (the *N. sylvestris* empty TA
site — a NEGATIVE misfiled as a positive in at least one secondary source) called **ABSENT**; decoys
yielding zero passes.

**A contaminant spike-in family is mandatory.** The standard spike-in ladder implants segments at
random single-copy loci *in assemblies* — which is (a) exactly where real ancient inserts do **not**
survive, and (b) an object that **cannot fail the junction gates, because it is not in the reads at
all**. Without contaminant spike-ins the calibration corpus contains no object exercising the
dominant failure mode.

---

## 5. The non-Agrobacterium arm

**The honest prior: there is no confirmed case of a non-Agrobacterium bacterium inserting a
contiguous DNA segment into a plant nuclear genome.** What exists is *gene-level* interkingdom HGT
inferred from phylogeny — >800 genes claimed across Viridiplantae (Mariault et al. 2025, Plant Cell
37:koaf195) — of which a 2025 systematic re-analysis retained only **29.3% (343/1,170 candidates from
35 papers)**: Aguirre-Carvajal & Armijos-Jaramillo, *Ecol Evol* 15(12):e72653, PMID 41426636.

**The EGT background dominates everything.** ~4,500 Arabidopsis nuclear genes (~18%) are of
cyanobacterial/plastid ancestry (Martin et al. 2002, PNAS 99:12246). Flux is ongoing and measurable:
1 cpDNA transposition per ~16,000 tobacco pollen grains (Huang, Ayliffe & Timmis 2003, Nature 422:72).

**The decisive cautionary control is in the exact clade of interest.** Vuruputoor et al. 2024, *G3*
14:jkae104, PMID 38781445: the *Physcomitrellopsis africana* ONT dataset was **~12% microbial**;
after filtering, **only 2 HGT genes survived**, and **98 of 273 published *P. patens* candidates were
absent from its congener.**

**Best-supported individual cases** (multi-line evidence, functional data) — the positive controls
for this arm: TAL transaldolase from Actinobacteria with gained introns and a rice phenotype (Yang et
al. 2015, New Phytol 206:807); PYL/ABA receptors from soil bacteria pre-dating the
Zygnematophyceae–embryophyte split; GRAS transcription factors; nicotianamine synthase (≥8
independent acquisitions, dated 437–400, ~275 and ~210 Ma); and the only strong crop case — three
bacterial **CSP-I cold-shock-protein** genes in the Triticeae ancestor, functionally complementing an
*E. coli csp* quadruple mutant (Wang et al. 2025, Nat Plants 11:761).

**Corrective results to cite:** Orobanchaceae HGT is plant→plant (106 transfers, **zero** bacterial);
fern neochrome came from hornworts; *Parasponia* nodulation is parallel loss, not HGT; the
"chlamydial partner" claim collapsed under better models (Domman et al. 2015, Nat Commun 6:6421).

**The deliverable is a calibrated upper bound, and the bound must be stated narrowly:**

> Physically anchored non-Rhizobiaceae bacterial insertion occurs at a rate below Z **per independent
> lineage**, in the high-contiguity read-linked stratum, for donors resembling GTDB R232, at ages
> under ~40–50 Myr, for **bacteria-restricted gene families**.

Every one of those qualifiers goes in the abstract. **A zero count is never reported as "other
bacteria have not inserted DNA into plant genomes."**

---

## 6. The genome-LM layer

**Verdict: the two-model Evo 2 tag-conditioned log-likelihood-ratio design is unsound and should be
dropped outright, not repaired.** Seven specific reasons, all verified:

1. OpenGenome2 tags are **all-uppercase with no species prefix**, and are **not document prefixes** —
   they are re-injected inside the stitched stream every 131,072 characters, so a prompt-prefix design
   is out of distribution by construction.
2. `evo2.utils.make_phylotag_from_gbif` fills `d__` from GBIF and produces OOD tags for plants.
3. **Only the prokaryotic half of the training taxonomy is GTDB**; eukaryotic tags are NCBI-derived,
   so a "GTDB lineage string" is not a coherent conditioning axis across the two domains being
   compared. The intended Agrobacterium tag is also wrong at order rank (training used *Rhizobiales*,
   not *Hyphomicrobiales*).
4. **Repeat-masking policy of the eukaryotic training data is a first-order threat**: if the model
   learned masked-vs-unmasked statistics, an LLR on plant genomic DNA measures **masking state, not
   origin**.
5. **Exact-assembly leakage on the pilot set** — *Physcomitrium patens* GCF_000002425.4 **is in
   OpenGenome2**, and the moss arm is precisely where the contested claim lives.
6. The shipped API returns sequence-reduced scores only; per-token logits need an unbudgeted custom
   forward pass.
7. The quoted throughput (2.4×10⁴ nt/s on a 7B model) implies ~336 TFLOP/s ≈ **93% MFU — physically
   impossible**. Realistic is 5–10k nt/s, so **every LM figure in circulation is 3–5× optimistic**.

**What survives: a two-sided single-model surprisal pair**, used as an anomaly *track* and a
re-scorer on windows classical detectors already flagged — **never as the detector**. **PlantCAD2**
(plant-only, so high surprisal *is* the "not-plant" signal, no tag required) paired with a
prokaryote-only **masked** LM such as **Minerva-MLM** (650M, 4k/8k context, pip-installable, and
masked — so pseudo-perplexity per position is native and the autoregressive logit problem does not
arise). Two single-domain models sidestep every defect above. Honest caveat: a prokaryotic LM on
plant nuclear DNA is OOD in the opposite direction, so its surprisal must be **calibrated
empirically, not assumed**.

**The benchmark that settles it** — pre-registered, month 1, **<2 GPU-days**, on assemblies verified
absent from OpenGenome2 `species_metadata.csv`. Measure **partial AUC at FPR ≤ 1×10⁻⁴** — the only
regime that matters at ~2.9×10¹⁰ candidate windows — for five scorers at **matched compute**:
DIAMOND `--fast` bitscore; a tetranucleotide/IVOM compositional baseline; PlantCAD2 surprisal;
prokaryote-MLM surprisal; the fused scorer.

**Funded only if the LM adds ≥0.05 pAUC over the best classical baseline AND does so specifically in
the ≥20% amino-acid-divergence bins where DIAMOND is collapsing** — adding recall where DIAMOND
already works is worth nothing here. Two mandatory controls: **soft-masked and hard-masked copies of
the same true positives as a paired set** (if the model separates masked from unmasked more strongly
than bacterial from plant, the design is dead on the spot), and the ecologically-plausible-contaminant
sequences as negatives (if it cannot separate a moss endophyte from a moss mini T-DNA, it adds
nothing over the protein screen it was meant to rescue).

Three findings from the project's own methodology doc that constrain this: continued pretraining
**improved interaction heads while reducing Jacobian performance**, so one readout cannot validate
the other (§5.5); **LM loss is not a confidence measure** (r = −0.002, p = 0.96), so there is no cheap
intrinsic triage (§5.5); and **embedding space reflects composition and phylogeny** (§11.8) — a
cT-DNA that has spent 30 My at the plant rate *has plant composition*, so remote-homology rescue must
be scored against a composition-matched decoy drawn from the **same host genome**, or it measures GC
content.

**Also deleted: the "fingerprint discovery of homolog-free cT-DNA families" track.** A locus card
exists only because an alignment hit fired; a family with no recognizable homolog produces no hit.
That track can only find unannotated segments *adjacent to already-recognized cargo* — a legitimate
but much smaller claim. And **categorical-Jacobian fingerprinting is not scannable at any scale here**
(>1.5 h/sequence optimized ⇒ ~4,500 H100-h for even 10³ cards): cap it at **≤50 hand-chosen loci**.

**Pre-registered acceptable outcome:** the LM fails the benchmark, we run alignment-only, and we
publish the curve. *The field is currently buying Evo 2 on vibes; a measured negative is a
contribution.*

---

## 7. Honest limitations

- **The contamination floor is the same order as the target signal.** Post-curation RefSeq still
  carries ~0.018% contaminant bases and GenBank ~0.16%, heavy-tailed — roughly **100 kb–2 Mb per
  plant assembly against a 25 kb cT-DNA.** Only cohort-level bounds and individually anchored loci
  are defensible. **This belongs in the abstract, not the discussion.**
- **The bound may refute nothing.** With Tier 1 at 800–1,500 assemblies collapsing to a few hundred
  independent lineages, rule-of-three gives a per-lineage bound around ~1% — compatible with *both*
  the ~7% angiosperm cT-DNA extrapolation *and* the 343-gene iHGT residue. A bound that excludes no
  existing claim is technically publishable and scientifically inert. **Hence the month-4
  decision-theoretic gate.**
- **The two nulls are not independent of the product they calibrate.** If the decoy-FDR curve has no
  usable operating point, the decoy column of the attrition figure is degenerate precisely where its
  argument lives. Several nominally independent fallbacks share this common cause.
- **Tier-1 yield is a single point of failure for three arms at once** (dated Ti/Ri phylogeny,
  corrected timeline, HGT bound) — all draw on the same scarce product.
- **Read *type*, not read availability, is the real denominator, and it is unmeasured.** Tier 1
  effectively requires HiFi/ONT, but most legacy cT-DNA-bearing taxa (*Nicotiana*, *Linaria*,
  *Ipomoea*, older *Diospyros*) are Illumina-era submissions.
- **The corpus is systematically depleted of exactly our signal.** `purge_dups` removes the shorter of
  two aligning contigs when both fall under the read-depth cutoff — precisely the signature of a
  **heterozygous insertion allele at ~0.5×**. Flaggable and auditable on ~10 genomes; not correctable
  corpus-wide.
- **The clock error is two-sided and probably unresolvable** (§Context).
- **No root age is identifiable**, and stem-vs-crown misplacement is the classic calibration error.
- **The origin of *vir*/T4SS cannot be dated by this program.**
- **The ancestral location of any transfer event is not recoverable.** Carriers are domesticates whose
  native ranges are anthropogenically rewritten.
- **Ascertainment cannot be undone, only described.** ~12.5% of the reference universe is structurally
  absent from every seed-plant megatree; the honest junction-proof denominator is **~2,000–2,100
  species-representative assemblies**, not ~4,000. That number goes in the abstract.
- **Arm A is replication, not discovery, and the incumbent holds priority.**

---

## 8. Repo scaffold

```
agro_origin/
  workflow/          Nextflow DSL2; one module per stage
    modules/         acquire · screen · cascade · junction · event · date · armB
  resources/
    queryset/        QS-A pTi/pRi plasmids · QS-B seed proteins · QS-C per-subfamily HMMs
                     QS-D border models · QS-E decoys (statistical + ecological) · QS-F read-through
    vector/          UniVec 10.0 with its 10,777 biological intervals masked first
    truth/           known cT-DNA loci · KJ599825 negative · spike-in ladder + contaminant spike-ins
    manifest/        SHA-256 per dependency · FCS-GX pinned at build 2023-01-24 · census pull dates
  configs/           workstation.config | bigmem.config (1 TiB) | awsbatch.config (us-east-1)
  analysis/          bracketing · simmap · BioGeoBEARS · replay harness
  parquet/           locus_hit · veto · junction_evidence · absence_proof · insertion_event · age_draw
  docs/              pre-registration · staged program · negative-results register
  papers/            (existing dossier)
```

All work under `/mnt/data/agro/` — `/` is full.

---

## 9. Verification

**Bootstrap (day 1).** `mkdir -p /mnt/data/agro/{ref,work,parquet,cards,logs}`; export `TMPDIR`,
`PIP_TARGET`, `XDG_CACHE_HOME` under it; install micromamba to `/mnt/data` and create the environment
there (`ncbi-datasets-cli diamond hmmer blast miniprot mmseqs2 minimap2 seqkit bedtools samtools
duckdb python=3.11 numpy pandas pyarrow biopython scipy nextflow`). Pin every version into the S0
manifest.

**End-to-end checks, in order:**

1. **Census reproduces** — paginated `datasets summary genome taxon 33090 --assembly-version current`
   → `total_count = 10,349`, median ≈555 Mbp, Σ = 12.418 Tbp. (A single 1,000-report page is
   Chromosome/Complete only and biases the median to 674 Mbp.)
2. **Contamination prior loads** — pull both FCS files, checksum them ourselves (NCBI ships none and
   regenerates daily), and **reproduce the moss-vs-angiosperm 7.4× contaminated-base ratio** before
   trusting anything that rests on it.
3. **Clock correction demonstrated** — re-derive *Camellia* CaTA from 9.7% divergence under K/2r with
   a Jukes–Cantor correction and a lineage-appropriate rate; test whether it moves the *Diospyros*
   ages; run GENECONV + PHI on the repeat arms. **Day three, and the first publishable output.**
4. **Moss/fern null reproduces** — blastp Q9FAF7 against the full PF18631 set and recover the
   *Mycena alexandri* 58.8% / E = 2.8×10⁻¹⁴¹ hit and the *Microvirga puerhi* 87.7% hit.
5. **Truth set recovered** — *Nicotiana* TA–TD, *Linaria*, *Ipomoea* IbT-DNA1/2 through the streaming
   path, as an end-to-end regression, not a unit test.
6. **Negatives stay negative** — KJ599825 called ABSENT; decoys yield zero passes; non-carrier panels
   yield no cT-DNA; composition-matched nulls reproduce the empirical FDR.
7. **Spike-ins survive the cascade at ≥95%**, including the contaminant spike-in family.
8. **`simmap` tip encoding verified numerically on synthetic data first** — passing `NA` to
   `phytools::make.simmap` yields an all-zero tip row → NaN likelihood → `logL = Inf` → the optimiser
   returns `q.init`, producing maps under a Q that was never fitted, **with no error and no warning**.
9. **Replay works** — every stricter threshold must be a <1 s Parquet filter over `locus_hit.parquet`.

---

## 10. Decisions still yours

1. **The title.** Accept demoting the T-DNA↔*vir* cross-brace to a labelled sensitivity (recommended)
   — the paper then cannot be titled "the origin of the *vir* system".
2. **Minimum viable N for Arm B.** Stacked gates plausibly land the calibration set at **N ≈ 10–25,
   all ≤30 My**, against a projection of 150–600 events. Recommended threshold **N = 25**, with a
   pre-committed fallback below it.
3. **The minimum useful bound**, pre-registered at S0 — this is what the month-4 gate tests against.
4. **Where S7 runs** — in-region (AWS us-east-1, free ingress, ~10× throughput, ~$3–8k) versus 2–6
   months of transatlantic streaming at ENA's measured 10.4 MB/s.
5. **Compete or collaborate.** Liu, Otten and colleagues hold the census, the species list, the SRA
   accessions and the 7,163-file repository, and the four things this program adds are their obvious
   next step. Worth deciding in week 1.
6. **Scale.** Full 30-month program, or an 18-month descope delivering Paper 0, the null-track
   resource, the contamination adjudication, the `p_det` surface and the pilot dated catalogue. Both
   are defensible; the middle is not.
