# Coevolutionary discovery with genome language models — methodology

A deep read of the methods in three connected papers:

| # | Short name | What it contributes to coevolutionary discovery |
|---|---|---|
| 1 | **Minerva** (2026) | The discovery framework: type-resolved pairwise interaction maps, genome-scale scanning, family-specific fine-tuning, experimental closure |
| 2 | **Gaia** (2024/2025) | The complementary retrieval axis: genomic *context* conservation as a discovery signal |
| 3 | **OMG / gLM2** (2024) | The substrate: mixed-modality corpus + model that makes non-coding coevolution visible at all |

Full citations and resource links: [README.md](README.md).

---

## 0. The core premise

Functionally coupled positions — two bases in an RNA stem, two residues across a protein
interface, two copies of a repeat — cannot mutate freely. A substitution at one is
compensated at the other, and that compensation accumulates across genomes as a
statistical coupling.

The methodological payoff is a **functionality filter**. Minerva makes this argument
explicitly: many energetically favorable interactions, such as incidental RNA base pairing,
have no functional role. Thermodynamic folding will happily predict them. Coevolutionary
support across diverse genomes will not, because only functionally constrained pairs get
conserved. This is why the Minerva package pins ViennaRNA with the comment that it is used
for *structure layout geometry only, never to fold* — the structure comes from evolution,
not from free energy.

The classical way to read that signal is an MSA plus a Potts/DCA model (GREMLIN, Infernal
covariance models, CMfinder). The bottleneck is the alignment: you must first find and
align enough divergent homologs. That is brutal for structured RNA, where structure is
conserved well past primary sequence, and it needs iterative refinement and manual curation.
Rfam has ~4,000 families after decades of this work.

**The shared thesis of these three papers: a masked language model trained on genomes has
already absorbed those couplings, and you can read them out without ever building an
alignment.** The MLM objective is the reason — predicting a masked nucleotide in a stem
requires knowing its pairing partner, so the training objective directly rewards learning
compensatory structure.

What follows is how each layer of that readout actually works.

---

## 1. The substrate: why mixed-modality tokenization is the enabling decision

You cannot extract non-coding coevolution from a model that cannot see non-coding sequence.
This is the whole reason the OMG/gLM2 design matters downstream.

### 1.1 The representation

A contig becomes an **ordered list of elements**, each either a coding sequence (CDS) or an
intergenic sequence (IGS):

```
<+>MALTKVEKRNRIKRRVRGK<+>aatttaaggaa<->MLGIDNIERVKPGGLELVDRLV
   └── CDS (amino acids) ──┘└ IGS (nt) ┘└──── CDS, minus strand ────┘
```

- **CDS → one token per amino acid.** Compresses 3 bp into 1 token and uses the more
  expressive alphabet.
- **IGS → one token per nucleotide.** Preserves the base-level detail where ncRNA,
  promoters, terminators and binding sites live.
- **`<+>` / `<->` strand markers** prepended to each element.
- Amino acids uppercase, nucleotides lowercase, so the two alphabets never collide in a
  shared vocabulary.

The trade-off being navigated: a pure-nucleotide genome model burns context length on
coding regions (a 4,096-token window would cover ~4 kb); a pure-amino-acid model throws
away intergenic sequence entirely. Mixed modality gets ~10 kb per 4,096 tokens *and* keeps
base-level resolution exactly where the non-coding signal is. gLM2's window holds
9.7 ± 3.3 genes.

This is the design decision that makes everything in Minerva possible.

### 1.2 Corpus construction (OMG)

3.1T bp from JGI IMG (snapshot 2023-08-27) + EMBL MGnify (2022-11-23): 3.3B CDS, 2.8B IGS,
271M contigs, 1.25 TB. Filtering steps, each defending against a specific failure mode that
would inject *false* covariation:

| Step | Rule | Rationale |
|---|---|---|
| Edge-element removal | Drop interrupted CDS at contig ends; if an edge is IGS, drop it *and* the adjacent CDS | Contig edges concentrate gene-calling errors and fragmented ORFs (~1.4B elements removed) |
| Contig length | Drop contigs <2 kb; require ≥7 elements and ≥3 CDS | Enriches for multi-gene context, which is the point |
| Assembly quality | Process element-by-element; if an element is >20% N/X, discard it and **start a new contig** | Preserves high-quality stretches instead of discarding whole contigs (0.004% CDS, 0.2% IGS) |
| Element length | Drop CDS >15,000 aa or IGS >4,000 bp | Flags failed eukaryotic gene calls and alternative genetic codes, which produce low coding density or absurd ORFs |

Derived sets: **OG** (0.4T bp, IMG prokaryotic genomes with taxonomy) and **OMG_prot50**
(207M representatives; 4.2B proteins → MMseqs2 linclust at 0.9 to strip fragments → 0.5 at
90% coverage → singletons dropped). OMG_prot50 is >3× the sequence diversity of UniRef50.

### 1.3 Balancing without taxonomy: genomic SemDeDup

Genomic sequences have wildly variable length, so sequence-identity clustering does not
work as a deduplication strategy, and metagenomic contigs rarely carry taxonomic labels to
balance against. The workaround:

1. Train a 150M gLM2 for 600k steps.
2. Embed the whole corpus — mean-pooled last hidden layer, one vector per example.
3. Prune examples within **2e-3 cosine distance** of each other → removes **49%**.

Example embeddings track taxonomic phylum closely, so pruning in embedding space acts as
taxonomic balancing without taxonomic labels. It raises taxonomic entropy at every rank.
The DGEB aggregate barely moves (0.474 → 0.482) but the gains land specifically on
underrepresented taxa (ArchRetrieval, RpoB archaeal phylogeny), with small regressions on
tasks biased toward overrepresented taxa.

*Relevance to coevolution:* near-duplicate genomes are the classic way to fool a
covariation estimator — they inflate apparent conservation and add no independent
evolutionary evidence. Embedding-space pruning is a label-free way to attack that.

### 1.4 gLM2 training

MLM objective, **30% masking** on both CDS and IGS tokens, cross-entropy on masked tokens
only. Two scales:

| | dim | heads | layers | context | lr | batch | tokens |
|---|---|---|---|---|---|---|---|
| gLM2-150M | 640 | 10 | 30 | 4096 | 1e-3 | 128 | 315B |
| gLM2-650M | 1280 | 20 | 33 | 4096 | 1e-3 | 128 | 315B |

AdamW (0.9, 0.95), weight decay 0.1, no dropout, 1k warmup then cosine decay to 10%,
bfloat16, RoPE, SwiGLU, RMSNorm, FlashAttention-2.

### 1.5 Continued pretraining into Minerva-MLM

Minerva does **not** train from scratch. It initializes from gLM2 650M, keeps the
mixed-modality tokenization, and continues pretraining for ~1.2M steps (>1.3T tokens,
~3.4 Tb) on a mixture of **25% OMG + 75% GlobDB r226**.

| Hyperparameter | Minerva-MLM | Minerva-MLM-8k |
|---|---|---|
| Parameters / layers / heads / dim | 650M / 33 / 20 / 1280 | same |
| Context | 4,096 | 8,192 |
| RoPE base | 10,000 | 20,000 |
| Peak LR | 4e-4 | 1e-4 |
| Warmup steps | 2,000 | 4,000 |
| Masking probability | 0.3 | 0.3 |
| Effective batch (tokens) | 524,288 | 524,288 |
| Initialization | gLM2 650M | Minerva-MLM |
| Training steps | 1,200,000 | 620,000 |

**The loss-weighting detail is the methodologically interesting one.** Under uniform
prediction, expected cross-entropy is log(20) for amino acids and log(4) for nucleotides.
The principled correction is to weight nucleotide loss by log(20)/log(4) ≈ **2.16**. In
practice that was insufficient — nucleotide loss plateaued or rose while aggregate loss kept
improving, i.e. the model was quietly trading away nucleotide modeling for protein modeling.
They raised the nucleotide weight empirically to **4.16**.

That is a direct intervention to force the model to learn the non-coding statistics that the
entire downstream discovery program depends on. (Note: fine-tuning reverts to 2.16.)

Motivation for the longer context: long intergenic regions are enriched for ncRNAs.

---

## 2. Extraction mechanism A — the categorical Jacobian

The baseline readout, from Zhang, Wayment-Steele, Brixi, Wang, Kern & Ovchinnikov
(*PNAS* 121(45) e2406285121, 2024). gLM2 ships it as
[`categorical_jacobian_gLM2.ipynb`](https://github.com/TattaBio/gLM2/blob/main/categorical_jacobian_gLM2.ipynb).

### 2.1 The computation

In-silico saturation mutagenesis. For a sequence of length `L`:

1. Perturb each position to every other token value.
2. Record the change in the model's per-position output logits everywhere else.
3. Collect into a fourth-order coupling tensor **J** of shape `(L, A, L, A)` — the two
   alphabet dimensions being the input substitution and the output-token response.
4. Symmetrize; mean-center along each alphabet dimension.
5. Reduce to an `L × L` map by **Frobenius norm** over the two alphabet dimensions.
6. Apply **average product correction (APC)**.

Alphabet size `A`: **24** for Minerva-MLM (4 nt + 20 aa in one mixed vocabulary), 20 for
ESM-2, 4 for RiNALMo.

Two perturbation modes:
- **Full substitution** — each nucleotide → the other 3, each amino acid → the other 19.
  Produces the alphabet-resolved blocks required for fingerprinting (§3).
- **Mask-only** — replace each position once with the mask token. Cheaper, but collapses the
  input-substitution axis, so fingerprinting is impossible.

### 2.2 What OMG/gLM2 demonstrated with it

This is where the thesis gets its proof of concept, and it is worth being precise about what
was shown, because Minerva is a direct generalization of it.

**Protein–protein interfaces.** Categorical Jacobian on the concatenated sequence of
2ONK_A (ModC) + 2ONK_C (ModB) recovers inter-protein coevolutionary signal closely matching
what GREMLIN extracts from a paired MSA — *from a single concatenated sequence, no alignment*.
ESM2 650M and Evo-1-8k-base detect none. Validated against 2ONK ground-truth contacts (<8 Å)
and 31 further complexes from Ovchinnikov et al. 2014.

The reason ESM2 fails is structural, not incidental: a protein LM trained on individual
proteins has never seen the two partners in the same context, so there is no mechanism by
which it could have learned a coupling across them. Genomic context is the prerequisite.

**Regulatory syntax in intergenic DNA.** On *E. coli* K-12 236,866–237,087 bp (containing
`aspV`, tRNA-Asp), the Jacobian recovers tRNA secondary structure (validated against PDB
6UGG) plus −35 and −10 sigma-factor binding sites, the σ70 transcription initiation region,
and a rho-independent terminator. It also shows a signal downstream of `aspV` and upstream
of the terminator with **no EcoCyc annotation** — an early instance of exactly the
"unannotated structured element" finding Minerva later industrializes. Reproduced across 23
further intergenic regions containing at least one terminator and one promoter.

**RNA–protein and protein–protein in one locus.** *B. subtilis* 168, 119,848–120,978 bp
(L10 leader RNA + `rplJ` + `rplL`): putative L10-leader↔RplL contacts (an experimentally
evidenced interaction), RplJ↔RplL contacts (a known complex), and coevolution between the
Shine-Dalgarno sequences upstream of the two genes.

So by the end of the OMG paper the signal is demonstrably there for proteins, RNA structure,
and regulatory DNA. What it is not yet is **fast**, or **type-resolved**.

### 2.3 Minerva's optimizations

Three, benchmarked against the original gLM2 notebook implementation:

1. **Batched perturbations** — combine perturbations from multiple positions into larger
   inference batches instead of one forward pass per position.
2. **Modality-restricted substitution** — substitute nucleotide positions only with
   nucleotides, amino-acid positions only with amino acids. For a sequence that is 20%
   nucleotide / 80% amino acid this needs ≈ `0.2L×3 + 0.8L×19 ≈ 15.8L` perturbed sequences
   rather than testing every vocabulary token at every position. Special tokens (BOS, EOS)
   are skipped automatically.
3. **Immediate CPU offload** — move logits/couplings off the GPU per batch so intermediates
   do not accumulate in GPU memory.

Even optimized, this is too slow for genome-scale scanning. Hence §4.

---

## 3. Extraction mechanism B — categorical Jacobian **fingerprinting**

This is Minerva's first conceptual contribution, and the cleanest idea in the three papers.

### 3.1 The insight

Every prior method takes the `A × A` coupling block for a position pair and **collapses it
to a scalar** (Frobenius norm → "how strongly do these two positions interact?"). That
throws away the block's internal structure.

But the internal structure *is* the interaction type:

- **RNA base pairing** → the block encodes a **reverse-complement** rule (A↔U, G↔C).
- **Repetitive motifs** → the block encodes a **matching/identity** rule (A↔A, G↔G).
- **Protein contacts** → the block encodes physicochemical complementarity.

Same scalar magnitude, completely different matrices. So: don't collapse — **classify**.
Treat the block as a fingerprint and compare it to reference patterns.

This converts "position i and j interact" into "position i and j interact **in this specific
way**", which is what turns a contact map into an annotation.

### 3.2 Building the reference fingerprints

Derived from labeled training data only — no held-out evaluation example touches this:

1. For each reference sequence, extract the coupling block for every position pair with an
   APC-corrected Frobenius score **> 4.0** and sequence separation **> 2** (nucleotide pairs)
   or **> 6** (protein pairs).
2. Retain the modality-relevant sub-block: **4 × 4** for nucleotide–nucleotide,
   **20 × 20** for amino acid–amino acid.
3. Pool blocks across reference sequences, flatten to vectors, and hierarchically cluster
   with **cosine distance + average linkage**.
4. **Manually select a dendrogram cut** isolating a cluster enriched for the ground-truth
   interaction type.
5. The **mean block of that cluster** is the reference fingerprint.

Sources per fingerprint:
- **Base pairing** — 8 Rfam families (RF00005, RF00010, RF00023, RF00162, RF00169, RF01854,
  RF02967, RF04183)
- **Repetitive motifs** — the type III toxin–antitoxin training set
- **Protein contacts** — the protein-contact training set

Note the clustering is done **without reference to interaction labels**; labels are used only
afterwards to pick which cluster is which. The structure is discovered unsupervised.

### 3.3 Applying them

For each position pair in a query:

1. Extract and flatten the modality-specific block.
2. Cosine similarity against each compatible reference fingerprint (nucleotide pairs vs
   nucleotide fingerprints only; amino-acid pairs vs protein fingerprints only).
3. Assign to a class if similarity exceeds that class's threshold:

   | Class | Threshold |
   |---|---|
   | RNA base pairing | 0.35 |
   | Repetitive motifs | 0.20 |
   | Protein contacts | 0.07 |

4. Ties → highest raw cosine similarity. Nothing over threshold → an **"other"** channel.

Output: separate base-pairing, repeat, protein and other maps for the same query. The
"other" channel is deliberately retained — it is where interaction types nobody has defined
a fingerprint for would show up.

In the package: `model.get_fingerprints(...)` returns channels
`["basepairing", "repeat", "protein", "other"]`.

### 3.4 Sanity check: the protein fingerprint is a known physical quantity

A genuinely convincing validation. The protein-contact fingerprint was compared against the
**Miyazawa–Jernigan statistical contact potentials** (1996 and 1999) by eigendecomposing each
symmetrized 20×20 matrix and comparing the four leading spectral modes. The dominant
components correspond to amino-acid hydrophobicity, charge, side-chain size, and
residue-specific interactions including cysteine–cysteine.

The model, trained only to predict masked tokens in genomes, independently reconstructed a
statistical potential derived from protein structures. That is strong evidence the
fingerprint is capturing real physics rather than a dataset artifact.

---

## 4. Extraction mechanism C — interaction heads

Fingerprinting is expressive but needs a forward pass per mutation. To scan genomes you need
the signal from **one** forward pass.

### 4.1 Attention heads are already specialized

Extract attention maps from all layers and heads; symmetrize each by averaging with its
transpose; score directly against reference interaction maps. Individual heads turn out to
be specialized:

| Interaction | Best single head | AUPRC |
|---|---|---|
| RNA base pairing | L32 H7 | 0.43 |
| Protein monomer contacts | L33 H5 | 0.38 |
| Repetitive motifs | L33 H18 | 0.38 |

Best-head selection uses the training set only.

### 4.2 Combining heads with a lightweight probe

Following the protein-contact probing literature (Rao et al.), fit **elastic-net logistic
regression** per interaction class, using concatenated symmetrized attention values from
selected layers as features for each eligible position pair.

Grid: inverse regularization `C ∈ {0.01, 0.1, 0.15}`, L1 ratio `∈ {0, 0.5, 1}`, selected to
maximize training-set AUPRC.

| Class | C | L1 ratio |
|---|---|---|
| Protein monomer contacts | 0.01 | 1.0 |
| RNA base pairing | 0.1 | 1.0 |
| Repetitive motifs | 0.15 | 0.0 |

**Layer selection is a real engineering constraint.** Extracting attention requires
instantiating the full attention matrix, which blocks FlashAttention kernels and inflates
memory. Last-six-layer heads are slightly more accurate; **last-two-layer heads** are used
for all genome-scale work and figures.

For combined visualization, each pair is colored by its highest-scoring head, with
base-pairing scores above 0.5 taking precedence.

### 4.3 The speed result that makes genome scanning possible

At 8,192 tokens, per sequence:

| Method | Time |
|---|---|
| Interaction heads | **79 ms** |
| Optimized mask-based categorical Jacobian | >1.5 hours |
| Original categorical Jacobian implementation | ~6 hours |

**~5 orders of magnitude.** This is the difference between interrogating a locus and
scanning a genome.

### 4.4 The resulting division of labor

- **Interaction heads** → primary genome-wide scanning. Supervised, fast, three fixed classes.
- **Jacobian fingerprinting** → locus-level interrogation. Slow, but represents a broader
  unsupervised set of relationships, including the "other" channel.

---

## 5. Benchmark design — how you validate a coevolution predictor

Three benchmarks, two of them new. The design choices matter more than the numbers.

### 5.1 Protein monomer contacts (existing)

Curated subset of the trRosetta training set from PDB. Filtered to prokaryotic origin via
RCSB PDB and NCBI Taxonomy APIs. **118 proteins, 23 train / 95 eval** (20/80), 200–1,024 aa.
Contacts = Cα–Cα within **8 Å**; long-range only, ≥24 residues separation. Proteins supplied
without genomic context.

### 5.2 Conserved RNA base pairing (new) — the careful one

The filtering cascade, because reproducibility here is nontrivial:

1. All **4,178** Rfam families.
2. Taxonomic-domain labels via per-sequence queries against the Rfam MySQL mirror (logic
   adapted from Rfam/rfam-taxonomy), run 2025-05-16, separately for full-alignment and
   seed-alignment hits. A domain is "major" at ≥90% of classified hits, else "mixed".
3. Retain families whose combined `<seed>/<full>` assignment contains Bacteria — including
   "Mixed/Bacteria" and "unclassified sequences/Bacteria" — but **exclude "Bacteria/Eukaryota"**
   so a small bacterial seed can't misrepresent the full alignment. 5S rRNA, tRNA and tRNA-Sec
   included regardless. → **1,093** bacterial families (vs 1,030 strictly Bacteria).
4. Stockholm full alignments for 1,065; seed alignments for the other 28. Five families
   excluded for unretrievable sequences (RF02973, RF02988, RF03073, RF03097, RF03113).
   Require alignment depth ≥10 → **680** curated families.
5. Parse Rfam consensus structure in WUSS notation, keeping **nested and pseudoknotted**
   pairs. Sample ≤10 aligned sequences per family; retrieve each from GenBank **with 7,500 nt
   of flanking sequence on each side**; reverse-complement minus-strand matches. Project
   consensus pairs onto each sequence, dropping any pair where either position aligns to a gap.
6. Require ≥4 reference pairs with ≥3 nt separation. Exclusions: 5 short families (4 of them
   CRISPR direct repeats), RF02541 (5,241 alignment columns > 4,096-token limit), and RF00177
   (~1,980 nt SSU rRNA) from RiNALMo comparisons only.
7. → **673 families, 27 train / 646 held-out eval.**

**The critical design choice: the RNA is evaluated in its native genomic context.** For
Minerva-MLM and gLM2, coding regions in the retrieved flank are called de novo with Pyrodigal
and tokenized as amino acids, while the annotated ncRNA interval is **excluded from ORF
prediction** so it is never translated. Predictions are scored only on nucleotide pairs
within the annotated RNA boundaries.

The benchmark therefore asks: *can a model recover the conserved, family-level base-pairing
architecture of an RNA from a single member sequence, sitting where it actually sits in a
genome?* That is the discovery setting, not the folding setting.

### 5.3 Repetitive DNA motifs (new)

50 loci, 5 classes × 10, with a **disjoint-class** split — evaluation classes are never seen
in training:

- **Train (20):** CRISPR arrays (CRISPR Recognition Tool v1.2 via Geneious Prime), type III
  toxin–antitoxin systems (TADB 3.0 + literature).
- **Eval (30):** REP elements (RepRanger), SsnA-associated non-template-strand repeats,
  TIGR-Tas systems.

Repeat-unit boundaries manually curated; corresponding positions across units are the
positive reference interactions. Scored on pairs within the annotated intergenic region,
excluding separations <6 nt. Evaluated in native genomic context.

### 5.4 Metrics and ablations

Primary metric **AUPRC**, plus AUROC and P@T (T = number of true interactions). For proteins
additionally P@L, P@L/2, P@L/5. Excluded separations: <24 residues (protein), <6 nt (RNA and
repeats). Aggregate = mean across examples.

Deliberate scoping: comparisons are restricted to **zero-shot scoring methods and lightweight
probes**, because benchmarks built from previously characterized interactions are inherently
biased toward known systems. The goal is to measure interaction information *already encoded*
by pretraining, not capacity to fit the benchmark.

Ablations worth copying:

- **Orientation.** Every RNA evaluated forward and reverse-complemented, predictions mapped
  back to original coordinates. In real discovery you don't know the strand.
- **Genomic context.** RNAs evaluated in isolation, and with 500 bp or 2,000 bp flanks
  (truncated to 1,024 / 4,096 tokens). For Minerva the flank uses mixed-modality tokenization;
  for RiNALMo, all nucleotides.

### 5.5 Results, and the honest negative ones

- Both new methods beat prior straight-to-scalar categorical Jacobian methods on all three
  benchmarks. Interaction heads best overall — beating every other method on **>84% of
  individual Rfam families**.
- **ESM-2 beats both genome LMs on protein monomer contacts**, consistent with its exclusive
  protein training.
- Minerva-MLM interaction heads **beat RiNALMo** on base pairing *even under
  RiNALMo-favorable conditions* (isolated RNA, correct orientation). Adding native genomic
  context substantially degrades RiNALMo and slightly *improves* Minerva — the specialized RNA
  model is only better in a setting that discovery never provides.
- Continued pretraining (gLM2 → Minerva-MLM) improved **interaction-head** performance but
  *reduced* Jacobian-based performance — coevolutionary information in internal
  representations and in output probabilities can diverge during training. A useful warning
  against assuming one readout proxies the other.
- **Language-modeling loss is not a confidence measure.** Across models, mean loss did not
  predict interaction performance; within a model, per-sequence base-pairing AUPRC was
  uncorrelated with per-sequence loss (**r = −0.002, p = 0.96**). Do not use perplexity to
  triage predictions.

---

## 6. Fine-tuning as an implicit alignment

The most practically important technique in the paper, and the one that most directly
replaces MSA construction.

### 6.1 The idea

Collect loci from one family, continue training the model on them, and the model internalizes
family-specific couplings — an implicit, learned substitute for a curated MSA. Because it
modifies the underlying model, it improves **both** extraction methods at once.

### 6.2 Configuration

Two strategies:
- **Full-parameter** — lr 5e-5, linear warmup 100 steps, weight decay 0.01.
- **LoRA** — lr 1e-4, no warmup, dropout 0.05, rank ∈ {1, 16, 32}, alpha = 2 × rank, applied
  to all attention projections (`wqkv`, `wo`), feed-forward layers (`w1`, `w2`, `w3`), and
  the LM head.

Defaults: bfloat16 mixed precision, gradient checkpointing, effective batch 16, context
4,096, AdamW, 12,000 steps, HuggingFace Trainer. Nucleotide loss weight **2.16** here (the
principled value), versus 4.16 during continued pretraining.

Datasets are built by taking a 4,096-token window centered on each locus:

| Family | Source | Loci |
|---|---|---|
| DRT2 | JGI/IMG via profile HMM, deduplicated by exact window identity | 13,034 |
| UG27 | Four databases, deduplicated at 100% identity across all three proteins | 2,549 |
| TwoAYGGAY | RF01731 cmsearch on PGDB r22.1 complete genomes, E ≤ 0.01 | 6,884 |

### 6.3 Data efficiency — the striking result

Validated on **DRT2**, a phage-defense system with cryo-EM structures (PDB 9C0I, 9C0J) for
ground truth. Reference base pairs extracted with the Python implementation of FR3D, 2023
geometric cutoffs, retaining only cis Watson-Crick/Watson-Crick pairs.

The base model predicts several hairpins but misses a pseudoknot involving the 3′ hairpin.
Fine-tuning on 13,034 loci recovers it — and **the pseudoknot emerges with as few as 200 loci**.

For **UG27** it is more extreme: the pseudoknot emerges after fine-tuning on **10 loci**
(~60 array units), and survives even with **rank-1 LoRA**. Subsets of 10–1,000 loci train for
2,000 steps; a single locus for 100 steps; full datasets for 12,000.

Compute: rank-1 LoRA fits within the 16 GB of an NVIDIA T4, i.e. a free Colab session.

**Implication:** the alignment-free claim holds even for family-specific adaptation. You need
tens of homologous loci, not a curated alignment of hundreds.

### 6.4 The trade-off — and the mitigation

Fine-tuning **sharpens RNA secondary structure but attenuates repeat and ORF signals**. Seen
consistently across DRT2, TwoAYGGAY and UG27. The prescribed workaround is simple and should
be standard practice: **always compare base-model and fine-tuned predictions** rather than
replacing one with the other.

### 6.5 Emergent codon periodicity (an unsupervised bonus)

The protein-covariation interaction head and Jacobian fingerprinting both reveal a repeating
**three-nucleotide pattern** across open reading frames — codon periodicity — read off DNA,
by a model never trained to detect it. Unlike the RNA-structure signal, it does **not**
improve with fine-tuning, indicating it is learned during general pretraining.

Practical application: in loci mistokenized as DNA because of annotation errors, extending
the annotated protein to the nearest in-frame start codon at the boundary of the periodic
signal recovered full-length ORFs matching RefSeq proteins at **100% identity by BLASTp**.
The coevolutionary map is thus also a gene-calling correction tool.

This is the general lesson: the maps capture relationships beyond the three classes the heads
were trained on, which is why the "other" channel matters.

---

## 7. Scaling to genomes

### 7.1 The scan

**150 bacterial genomes** — 116 from the hCom2 synthetic human gut community, 25 pathogens
and select agents, 9 model organisms. By phylum: Bacillota 70, Bacteroidota 41,
Pseudomonadota 20, Actinomycetota 13, plus Campylobacterota, Thermodesulfobacteriota,
Verrucomicrobiota and Deinococcota.

Annotation with **mettannotator v1.5.0** (fast mode, Bakta v1.11.4 as gene caller, Nextflow +
Singularity), which bundles InterProScan, eggNOG-mapper, antiSMASH, GECCO, Pseudofinder,
AMRFinderPlus, CRISPRCasFinder, dbCAN, Infernal, tRNAscan-SE and QUAST, plus DefenseFinder.
Consolidated into annotated GenBank files used both for downstream analysis and for
tokenization.

Execution: tile each tokenized genome into **4,096-token chunks with stride 2,048** (50%
overlap), run the three last-two-layer interaction heads. **100 minutes on a single H100**,
plus 31 minutes writing output. 266–1,740 chunk maps per genome.

Storage: sparse H5, uint16, retaining only values above a per-head threshold (0.1 for repeat
and base-pairing, 0.5 for protein). Masking predictions inside coding regions brings the total
to **~18 GB — 6% of what maps including coding contacts would require.**

### 7.2 Aggregation: from maps to ranked loci

An intergenic region = the complete nucleotide sequence between adjacent annotated CDSs. For
each, count off-diagonal predictions above threshold (**0.9 base-pairing, 0.5 repeats**).
Because of tile overlap, a region can appear in several tiles — the tile with the **highest
interaction count** is taken as representative. A region counts as annotated if it overlaps
any existing annotation.

Validation that the ranking is meaningful: CRISPR loci carry the strongest repetitive-motif
signal, rRNAs the highest base-pairing signal, tRNA regions both. Intergenic regions flanking
nucleic-acid-interacting proteins (including transposases) are enriched — tested by assigning
interactions within 500 bp up/downstream of each CDS to that protein and comparing against
background with a one-sided Mann-Whitney U test.

Also visualized as **one-dimensional genome tracks** (per-position interaction counts, rolling
mean of 21 nt) and as **UMAP of mean-pooled final-layer embeddings** of the top 10% most
structured regions (1,280-dim, nucleotide tokens only, L2-normalized; n_neighbors=15,
min_dist=0.3). The UMAP groups CRISPR loci, rRNAs and group II introns — but also reflects
GC content and phylogeny, which is why embedding-based discovery alone is judged insufficient
without further post-training or decomposition.

### 7.3 The null model — the step that makes the numbers credible

Raw counts of "unannotated structured loci" are meaningless without a background. Following
the RMARK3 approach:

1. Pick 5 genomes.
2. Fit a **25-state HMM** to each genome's intergenic sequences by Baum-Welch.
3. Generate a paired null genome in which **every intergenic region is replaced by an
   equal-length sequence emitted by that HMM** — composition matched, structure destroyed.
4. Run the identical Minerva pipeline on the null.
5. Fold enrichment = real / null; empirical FDR = null / real.

| Threshold | Fold enrichment | Empirical FDR |
|---|---|---|
| ≥2 hairpins | 14× | 0.07 |
| ≥4 hairpins | **132×** | **0.008** |

A hairpin is defined as **≥5 contiguous anti-diagonal base-pairing interactions above 0.9**;
a multi-hairpin locus groups hairpins within 50 nt.

### 7.4 The headline finding

| Criterion | Loci | Unannotated |
|---|---|---|
| ≥2 neighboring hairpins (stems ≥5 bp) | 57,787 | 40,175 (**69.5%**) |
| ≥4 hairpins | 9,044 | **41.1%** |

Hundreds of uncharacterized structured loci per genome, including complex multi-hairpin
elements.

---

## 8. From a prediction to a searchable family

A contact map is not a discovery. The step that converts it into something you can search
genomes with is a **Minerva-guided covariance model bootstrap** — and this is where the LM
and classical comparative genomics compose rather than compete.

The loop, as run for both case studies:

1. **Predict.** Run interaction heads over candidate loci.
2. **Fine-tune** on the family to sharpen structure (§6).
3. **Define unit boundaries manually**, guided by the repetitive-motif and base-pairing
   interactions — for UG27 the repeat interactions are what reveal that the region is an
   *array* of units at all.
4. **Seed alignment**, hand-curated using the predicted structure as the guide. This is the
   step that is normally impossible for sequence-diverse families.
5. **`cmbuild` / `cmalign` / `cmsearch`** (Infernal) — expand to homologs, search databases.
6. **Iterate**: realign new hits, inspect structure conservation, refine.
7. Visualize with **R2R**.

Two refinements worth noting:

- **Model multiplicity.** A single covariance model could not capture UG27 diversity, so a
  *second* model was built for a clade whose units lack the pseudoknot. Overlapping matches
  between the two models are resolved by lower E-value (threshold 0.01).
- **Strand artifacts.** Weaker antisense partial hits overlapping a stronger opposite-strand
  hit by >50% of their length are removed.

**Why this matters methodologically:** in both case studies, Minerva's contribution was not
detecting a *new signal* so much as making an *alignment tractable* that conventional methods
could not build — because for TwoAYGGAY the Rfam model missed lineage-specific extensions, and
for UG27 the units are so sequence-diverse that only short discontinuous motifs are conserved.
Neither was apparent from conventional sequence dotplots.

---

## 9. The complementary axis — Gaia and context conservation

Gaia is not a coevolution method. It belongs here because it exploits the *same underlying
gLM2 property* — genomic-context awareness — along an orthogonal discovery axis: retrieval.

### 9.1 Building the retrieval model

Two-stage fine-tune of gLM2_650M into **gLM2_embed**:

1. **Domain adaptation.** Fine-tune gLM2_650M on the UniRef50 train split for 1 epoch (AdamW,
   lr 1e-4 cosine decay, batch 256). Reduces train/test mismatch, since gLM2 was pretrained on
   contigs rather than individual proteins.
2. **Structure alignment.** Train a **linear projection on mean-pooled, frozen** gLM2
   representations, maximizing cosine similarity between proteins in the same structural
   cluster. 2.3M AlphaFoldDB structural clusters, **InfoNCE** contrastive loss, batch
   **32,768** (large, to maximize in-batch negatives), 30,000 steps, lr 1e-4, weight decay 0.1.

Two deliberate choices: representations come from the **middle layer**, not the last (better
transfer, consistent with DGEB findings); and output dimensionality is **512 vs 1,280 hidden**
(2.5× smaller), for vector-search scalability.

The result is a single embedding that simultaneously carries **sequence + structure + genomic
context** — structure via the contrastive objective, context via gLM2 pretraining.

### 9.2 The index

**OG_prot90**: all CDS from the OpenGenome dataset (131,744 prokaryotic and viral genomes from
INSDC, retrieved via IMG/M), clustered with MMseqs2 `--min-seq-id 0.9 -c 0.9` →
**85,007,726 centroids**. Served from a **Qdrant** vector database using **HNSW** approximate
nearest-neighbor search with cosine similarity; 100 neighbors returned by default.

Functional annotation is a separate CLIP-style model aligning ESM2 representations with text
annotations encoded by `dmis-lab/biobert-v1.1`, trained on Swiss-Prot (5 epochs, batch 6,000
pairs, lr 1e-4, ESM2 frozen). Each OG_prot90 protein gets a precomputed annotation from its
nearest Swiss-Prot embedding.

### 9.3 Benchmarks, including the honest trade-off

- **BacArch BiGene** — 256 expert-curated homolog pairs between *E. coli* K-12 and
  *Sulfolobus acidocaldarius* DSM 639, validated by ≥2 of 5 criteria (UniRef annotations,
  genome context, HMM annotations, Foldseek similarity). Gaia matches Foldseek accuracy with
  **>2 orders of magnitude** less total time (search + database creation). BLASTp and MMseqs2
  perform poorly on phylogenetically distant homologs.
- **Sequence sensitivity** — 1,200 random OG_prot90 sequences, CD-HIT `-c 0.5 -n 2`, keeping
  666 with a non-self hit at 75% identity / 70% reciprocal coverage. Recall = whether the best
  non-self BLASTp hit appears in the first K retrievals.
- **Context sensitivity** — 3,000 proteins; context = 5 genes upstream + 5 downstream; two
  proteins homologous at >50% identity and >50% coverage; a retrieval is correct if >7 of 10
  context genes are homologous.
- **Structure** — SCOPe-40 2.01, 2,207 sequences, top-30 retrieval, recall against the query's
  structural family.

The trade-off is stated plainly: embedding search is **less sensitive than alignment for close
homologs**, but 1–3 orders of magnitude faster, and approaches Foldseek on structure **without
predicting any structures**. It also degrades on out-of-distribution sequences (tested on
eukaryotic UniRef50 held-out data).

### 9.4 Why context retrieval is a discovery mechanism

Both case studies make the same methodological point — *the query protein's own sequence and
structure are uninformative; its neighbors are not.*

**Phage tail protein.** Query: an uncharacterized protein from *Pseudomonas vancouverensis*
LMG 20222. BLASTp against nr → "hypothetical proteins". Foldseek on the ESMFold **monomer** →
a meaningless spread (kinesin-like protein, Mediator subunit 21, a lectin). Gaia instead
returns hits sitting in **prophage-like genomic contexts** (corroborated by IMG's independent
prophage prediction), annotates the best hit as "major tail fiber protein S", and — via
co-occurring-gene analysis across the 100 retrieved contexts — surfaces the
diversity-generating retroelement protein **Avd** among the top co-occurring genes. Follow-up:
AlphaFold3 predicts a trimer (ipTM 0.68, pTM 0.71), and Foldseek on the **trimer** finds a
*Pseudomonas* phage pyosin tail fiber (PDB 6CU2), sharing only a C-terminal lectin-like domain
but forming a tail of very similar length.

The methodological lesson is sharp: **structural search failed on the monomer and succeeded on
the oligomer**, and it was genomic context that justified building the oligomer in the first
place.

**Siderophore BGC.** Query: QbsK, a CoA transferase-ligase from the quinolobactin cluster
(MIBiG BGC0000925). The quinolobactin BGC contains no IucC condensation domain — the primary
signal antiSMASH uses to call siderophores — so rule-based tools miss it, and the query enzyme
class is ubiquitous and non-specific, so sequence/structure search is uninformative. Gaia
retrieves putative siderophore loci across large phylogenetic distances: *Pseudomonas
flavescens* (same genus, 36–55% identity) and *Nocardia amamiensis* (different phylum), sharing
TonB-dependent transporters homologous to the quinolobactin receptor, salicylate ligase and
methylase proteins, and metal-specific ABC transporters.

**Composability with Minerva.** The two answer different questions over the same substrate:

- *Minerva:* "what non-coding structure or interaction is in this region, and is it new?"
- *Gaia:* "what is this protein, and what does it reliably live next to?"

Minerva flags an unannotated structured intergenic locus; Gaia identifies and contextualizes
the proteins flanking it. The UG27 workflow is effectively this pattern executed by hand.

---

## 10. Closing the loop experimentally — UG27

Worth documenting because it is the template for validating a purely computational
coevolutionary prediction, and because the prediction was **not** what the field expected.

**Prediction.** Interaction heads showed multiple neighboring hairpins linked by
repetitive-motif interactions — a structured **array of ~150-nt units**. Fine-tuning added a
basal hairpin per unit plus a pseudoknot. The Minerva-guided alignment revealed short conserved
motifs inside an asymmetric internal loop bracketing the central stem, despite negligible
primary-sequence conservation. Final tally: **82,314 ncRNA units across 14,118 loci**, unit
lengths clustering at 149 and 167 nt with a ~135-nt pseudoknot-less population. AlphaFold3
predicted the three proteins (RT + sORF + bORF) form a complex.

**Test.** All five UG27 systems found in the hCom2 genomes (all resident in integrated
prophages) were cloned into a T7 expression plasmid, expressed in *E. coli* BL21(DE3), DNA
purified, and analyzed by denaturing PAGE and strand-specific DNA sequencing.

**Result.**

- **Short 50–100-nt ssDNA products** from all five — *not* the long concatemeric products
  reported for other class-2 Unknown Group reverse transcriptases, which is what the authors
  expected going in.
- Abolished by the RT active-site mutation **YSDD → YSAA**.
- Sequencing mapped the cDNAs **precisely to the central hairpins** of the ncRNA units across
  all five loci.
- **The cDNA boundaries coincide with the conserved motifs the Minerva-guided alignment had
  identified** — reverse transcription starts at a conserved AUC within an
  `AUCNNNNNNNUANAG` motif and terminates after a conserved `UUYA` motif on the opposite side
  of the central hairpin.
- Deleting *either* accessory ORF abolished production → all three proteins required.
- Controls: RT-inactive samples showed roughly uniform plasmid coverage and recovered the
  endogenous *E. coli* Ec86 retron product, confirming the ssDNA capture worked.

That fourth point is the one that closes the loop: features inferred purely from predicted
coevolution turned out to be the **biochemical boundaries** of the reverse-transcription
reaction.

What remains unknown: the biological role of the cDNA products. No obvious sequence
complementarity to phage or bacterial genomes was found, leaving open whether they recognize
nucleic-acid structures, bind proteins, or act by another mechanism.

---

## 11. Limitations and failure modes

Stated by the authors, and worth internalizing before building on any of this:

1. **Short context windows.** 4,096 tokens ≈ 10 kb; 8,192 ≈ 20 kb. Long-range genomic
   interactions are out of reach.
2. **Protein contacts are weaker than specialized models.** ESM-2 wins on monomers. Use the
   right model per interaction type.
3. **RNA–protein interactions remain hard** — arguably the most consequential gap, since
   ribonucleoprotein systems are the discovery target.
4. **Amino-acid tokenization of CDS blocks nucleotide-level features inside coding regions.**
   Structured RNAs embedded within coding sequence cannot be modeled simultaneously with the
   protein. (This is the cost of the design decision in §1.1, and the UG27 scan had to work
   around it: one locus had a CDS annotation overlapping three ncRNA matches, which was
   removed and the region retokenized as nucleotides.)
5. **Fine-tuning trades signals against each other** (§6.4).
6. **Loss is not confidence** (§5.5) — there is no cheap intrinsic triage signal.
7. **Benchmarks are biased toward known biology** by construction, which is why the authors
   restrict comparisons to zero-shot methods and lightweight probes.
8. **Embedding space reflects composition and phylogeny**, not just function — so UMAP-style
   embedding clustering is not sufficient for family discovery on its own.
9. **Manual steps remain** in the critical path: dendrogram cuts for fingerprints, repeat-unit
   boundary curation, seed-alignment construction.

---

## 12. Practical recipe

Synthesizing into an order of operations for applying this:

1. **Choose the model for the interaction type.** Mixed-modality genome LM for anything
   involving non-coding sequence or cross-gene relationships; a protein LM for monomer
   contacts; note that specialized RNA LMs lose their advantage the moment genomic context is
   present.
2. **Scan with interaction heads.** 79 ms/sequence makes whole genomes cheap. Tile with 50%
   overlap; keep the highest-scoring tile per region. Store sparsely and mask coding regions
   (~16× saving).
3. **Aggregate per intergenic region** at 0.9 (base-pairing) / 0.5 (repeats), and rank.
4. **Build a composition-matched null** with per-genome HMMs over intergenic sequence. Report
   fold enrichment and empirical FDR. Without this the unannotated-locus counts are not
   interpretable.
5. **Sanity-check the ranking against known biology** — CRISPR should top the repeat signal,
   rRNA the base-pairing signal. If it doesn't, the pipeline is broken.
6. **Interrogate candidate loci with Jacobian fingerprinting**, including the "other" channel.
   Slow but type-resolved and broader.
7. **Fine-tune on tens to thousands of homologous loci** — rank-1 LoRA on a T4 suffices — and
   **always diff against the base model**, since fine-tuning sharpens structure at the cost of
   repeat and ORF signals.
8. **Bootstrap a covariance model** from the predicted structure: manual unit boundaries →
   hand-curated seed → `cmbuild`/`cmalign`/`cmsearch` → iterate. Build multiple models if the
   family has structural subclades.
9. **Characterize the genomic neighborhood** with context-aware retrieval (Gaia) on the
   flanking proteins; check oligomeric structure predictions when monomer search is
   uninformative.
10. **Test.** Conserved motifs identified from coevolution are strong candidates for functional
    boundaries — in UG27 they were the exact start and stop of reverse transcription.
