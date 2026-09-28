# Paper dossier — coevolutionary / genome-language-model discovery

Reference notes on three connected papers. The deep methodology write-up is in
**[coevolutionary-discovery-methodology.md](coevolutionary-discovery-methodology.md)**;
this file holds identity, provenance, resources and the citation caveats.

---

## The lineage

All three share one substrate. **OMG/gLM2** is the root; **Gaia** and **Minerva** are
independent descendants that exploit different properties of the same model.

```
  OMG corpus (3.1T bp) ──► gLM2 650M  (mixed-modality genome LM, Tatta Bio, Aug 2024)
                                │
            ┌───────────────────┴────────────────────┐
            │                                        │
   contrastive fine-tune                   continued pretraining
   on 2.3M AFDB clusters                   +1.2M steps, OMG 25% + GlobDB 75%
            │                                        │
       gLM2_embed                              Minerva-MLM (650M)
            │                                        │
    ┌───────┴────────┐                    ┌──────────┴──────────┐
    │ Gaia           │                    │ Minerva             │
    │ context-aware  │                    │ coevolutionary      │
    │ protein search │                    │ interaction maps    │
    │ (Nov 2024 →    │                    │ (Sept 2026)         │
    │  Sci Adv 2025) │                    │                     │
    └────────────────┘                    └─────────────────────┘
      retrieval axis:                       discovery axis:
      "what is this protein,                "what non-coding structure
       what does it live next to?"           is here, and is it new?"
```

A second thread runs underneath: the **categorical Jacobian** method
(Zhang, Wayment-Steele, Brixi, Wang, Kern & Ovchinnikov, *PNAS* 121(45) e2406285121, 2024).
gLM2 ships a reference implementation of it; Minerva generalizes it into fingerprinting and
benchmarks its optimizations against that exact notebook. **Sergey Ovchinnikov** co-authored
both the categorical Jacobian paper and OMG; **Garyk Brixi** co-authored the categorical
Jacobian paper and is co-first author of Minerva. JGI co-authors (**Antonio Pedro Camargo**,
**Simon Roux**, **Natalia Ivanova**, **Nikos Kyrpides**) recur across all three.

---

## 1. Minerva (2026)

**Coevolutionary mining of prokaryotic non-coding elements with a genome language model**

| | |
|---|---|
| DOI | [10.64898/2026.09.22.753630](https://doi.org/10.64898/2026.09.22.753630) |
| Posted | 23 September 2026, bioRxiv (Bioinformatics) |
| License | CC-BY 4.0 |
| Length | 39 pp main + 51 pp supplement (figs S1–S40, tables S1–S3) |
| Status | Preprint, not peer reviewed |

**Authors** (per PDF): David B. Li\*, Garyk Brixi\*, Alexandra S. Kim, Mateus B. Fiamenghi,
Claudia L. Driscoll, Simone A. Evans, Alex Gao, Natalia N. Ivanova, Nikos C. Kyrpides,
Karl Deisseroth, Max E. Wilkinson, Michael A. Fischbach†, Brian L. Hie†
(\* equal contribution; † correspondence: fischbach@fischbachgroup.org, brianhie@stanford.edu)

**Affiliations:** Stanford (Bioengineering, ChEM-H, Genetics, Mathematics, Biochemistry,
Microbiology & Immunology, Psychiatry, Chemical Engineering, Data Science), Arc Institute,
DOE Joint Genome Institute / LBNL, HHMI, Sloan Kettering Institute / MSKCC,
Chan Zuckerberg Biohub.

**Funding:** Fannie and John Hertz Foundation (D.B.L.); NSF GRFP (G.B.); Chan Zuckerberg
Biohub (M.A.F.); Gates Foundation, CZI, Arc Institute, Schmidt Sciences AI2050, Stanford
Center for Digital Health, Stanford HAI Hoffman-Yee (B.L.H.).

### ⚠️ Citation caveats

1. **Two different abstracts are in circulation.** The bioRxiv landing page and Crossref
   metadata carry an abstract that differs materially from the one in the PDF. The
   metadata version claims *"84.3% of predicted intergenic base-pairing falls outside of
   known annotations"* and says the TwoAYGGAY finding is *"In Pseudomonas"*; the PDF
   abstract has neither figure, says *"hundreds of unannotated regions per bacterial
   genome"*, and localizes the finding to *"Pseudomonadota"*. The PDF main text reports
   **69.5%** of ≥2-hairpin loci as unannotated (a different metric from the 84.3% claim).
   **Quote numbers from the PDF, not from the landing page or Crossref.**
2. **The metadata author list is incomplete.** Crossref lists 12 authors and omits
   **Max E. Wilkinson** (Sloan Kettering), who appears as the 11th author in the PDF. Any
   citation auto-generated from the DOI will be wrong.

### Resources

| | |
|---|---|
| Code | https://github.com/garykbrixi/minerva (Apache 2.0) |
| Install | `pip install minerva-dna` |
| Model (4k ctx) | https://huggingface.co/gbrixi/minerva-mlm |
| Model (8k ctx) | https://huggingface.co/gbrixi/minerva-mlm-8k |
| Eukaryotic RNA | https://huggingface.co/gbrixi/minerva-rinalmo-giga (RiNALMo backbone) |

Package layout: `modeling_minerva.py` (model + heads), `interaction_heads.py`,
`jacobian.py`, `rna_structure.py` (dot-bracket / Vienna / CT export, keeps pseudoknots),
`gene_calling.py` (Pyrodigal), `data.py` (GenBank → mixed tokens), `visualization.py`,
`finetuning.py`, `scripts/finetune.py` (HF Trainer + accelerate, full or LoRA).
Example data ships for both case studies (`TwoAYGGAY_Pseudomonas_fluorescens_SBW25.gb`,
`UG27_systems.gb`). Colab notebooks: loci viewer, RNA structure, fine-tuning.

Dependencies of note: ViennaRNA is pinned with the comment *"RNA structure layout geometry
only; never used to fold"* — structure comes from predicted coevolution, not thermodynamics.

### Headline results

- **Speed:** interaction heads 79 ms/sequence vs ~6 h for the original categorical Jacobian
  at 8,192 tokens (~5 orders of magnitude).
- **Accuracy:** beats prior scalar categorical Jacobian methods on all three benchmarks;
  best method on >84% of individual Rfam families.
- **Scan:** 150 genomes in 100 min on one H100 → 57,787 loci with ≥2 hairpins, **69.5%
  unannotated**; ≥4 hairpins 132× enriched over a composition-matched null (FDR 0.008).
- **TwoAYGGAY (RF01731):** extended architecture (3 extra hairpins, elongated basal stem,
  3′ pseudoknot) confined to Pseudomonadota; 16,086 matches across 1,148 of 1,324
  *Pseudomonas* strains; 68.4% of doublets divergently oriented (2.7× expectation,
  p < 10⁻³⁰⁰).
- **UG27:** new phage-encoded system — RT + two essential accessory proteins + a variable
  array of structurally conserved, sequence-diverse ncRNAs (82,314 units across 14,118
  loci) templating **short 50–100-nt cDNA hairpins**. Experimentally confirmed in five
  systems; cDNA boundaries match conserved motifs found from predicted coevolution.

---

## 2. Gaia (2024 preprint → 2025 journal)

**Preprint:** Gaia: A Context-Aware Sequence Search and Discovery Tool for Microbial Proteins
— [10.1101/2024.11.19.624387](https://doi.org/10.1101/2024.11.19.624387), posted
21 November 2024, CC-BY-NC-ND 4.0.

**⚠️ Cite the journal version instead:**
Jha N., Kravitz J., West-Roberts J., **Lu C.**, Camargo A.P., Roux S., Cornman A., Hwang Y.
*Gaia: An AI-enabled genomic context–aware platform for protein sequence annotation.*
**Science Advances 11, eadv5109 (2025)** —
[10.1126/sciadv.adv5109](https://doi.org/10.1126/sciadv.adv5109),
PMID 40540578, PMC12180486, published 20 June 2025.

The journal version changes the title, **adds Cong Lu** as an author, and is open access.
Affiliations: Tatta Bio (Cambridge, MA) + DOE JGI/LBNL.
Correspondence: yunha@tatta.bio, andre@tatta.bio.

**Funding:** Schmidt Futures (Tatta Bio); DOE Office of Science, contract
DE-AC02-05CH11231 (JGI); DOE Early Career Research Program (S.R.).
Competing interests: Y.H. and A.C. are officers and board members of Tatta Bio, a scientific
nonprofit.

### Resources

| | |
|---|---|
| Web tool | https://gaia.tatta.bio (free) |
| Benchmark code | https://github.com/TattaBio/gaia-benchmark |
| Archive | https://doi.org/10.5281/zenodo.15411484 |
| Model | https://huggingface.co/tattabio/gLM2_650M_embed |
| Database | https://huggingface.co/datasets/tattabio/OG_prot90 |

### Key numbers

85,007,726 protein clusters (90% identity) from 131,744 prokaryotic and viral genomes;
512-dim embeddings; Qdrant + HNSW; 100 neighbors returned by default; context window covers
9.7 ± 3.3 genes. Matches Foldseek accuracy on remote homology at >2 orders of magnitude less
total time; 1–3 orders of magnitude faster than alignment search. Weaker than alignment for
*close* homologs, and degrades on out-of-distribution (eukaryotic) sequences.

---

## 3. OMG / gLM2 (2024)

**The OMG dataset: An Open MetaGenomic corpus for mixed-modality genomic language modeling**

| | |
|---|---|
| DOI | [10.1101/2024.08.14.607850](https://doi.org/10.1101/2024.08.14.607850) |
| Posted | v1 17 August 2024; **v2** is the version linked here |
| License | CC-BY-NC 4.0 (bioRxiv, Systems Biology) |
| Published as | **ICLR 2025** conference paper (camera-ready Feb 2025); also an MLSB 2024 workshop version |

bioRxiv v2 content matches the ICLR camera-ready.

**Authors:** Andre Cornman\*, Jacob West-Roberts, Antonio Pedro Camargo, Simon Roux,
Martin Beracochea, Milot Mirdita, Sergey Ovchinnikov, Yunha Hwang\*
(\* correspondence: {yunha,andre}@tatta.bio)

**Affiliations:** Tatta Bio; DOE JGI/LBNL; EMBL-EBI; Seoul National University;
MIT Department of Biology.

### Resources

| | |
|---|---|
| Code | https://github.com/TattaBio/OMG (preprocessing), https://github.com/TattaBio/gLM2 (inference) |
| OMG dataset | https://huggingface.co/datasets/tattabio/OMG |
| OG subset | https://huggingface.co/datasets/tattabio/OG |
| Protein-only | https://huggingface.co/datasets/tattabio/OMG_prot50 |
| Models | https://huggingface.co/tattabio/gLM2_650M · https://huggingface.co/tattabio/gLM2_150M |
| Categorical Jacobian notebook | `categorical_jacobian_gLM2.ipynb` in the gLM2 repo |
| Additional files | https://zenodo.org/records/14198868 |

### Dataset statistics

| Dataset | CDS | IGS | Total bp | Contigs | Size | Notes |
|---|---|---|---|---|---|---|
| **OMG** | 3.3B | 2.8B | 3.1T | 271M | 1.25 TB | mixed-modality |
| **OG** | 0.4B | 0.3B | 0.4T | 6.2M | 0.16 TB | IMG prokaryotic genomes + taxonomy |
| **OMG_prot50** | 207M | – | – | – | 0.05 TB | 50% identity, singletons removed |

Sources: IMG metagenomes (2023-08-27) 36,273 samples / 182M contigs / 1.70T bp / 1.84B CDS;
IMG genomes 131,744 samples / 6.2M contigs / 0.4T bp / 0.4B CDS; MGnify metagenomes
(2022-11-23) 33,531 samples / 82M contigs / 1.03T bp / 1.03B CDS. Embargoed and restricted
samples excluded.

OMG_prot50 is >3× the sequence diversity of UniRef50 (66M). A September 2024 update extended
gLM2's context from 2,048 → 4,096 tokens and moved to per-nucleotide IGS tokenization.

### Headline results

gLM2 outperforms ESM2 on aggregate DGEB at both parameter scales and keeps scaling with FLOPs
on tasks where ESM2 plateaus (operon pair classification, ModBC paralogy). Comparable to
Nucleotide Transformers on nucleic-acid tasks despite DNA being a small fraction of training
tokens. Underperforms ESM2 on ProteinGym DMS (0.384 vs 0.414 avg Spearman), attributed to
eukaryotic sequences being poorly represented in OMG. Semantic deduplication prunes 49% of the
corpus and improves performance specifically on underrepresented taxa.

First demonstration that a genome LM recovers **protein–protein interface** coevolution from a
single concatenated sequence (2ONK ModBC), matching MSA-based GREMLIN where ESM2 650M and
Evo-1-8k-base detect nothing — the result Minerva generalizes.

---

## Source retrieval notes

bioRxiv aggressively rate-limits automated requests (HTTP 429 via curl and via the URL
fetcher). Text for all three was obtained through a browser session. The Minerva preprint is
recent enough that bioRxiv has not built its full-text HTML — only the abstract and PDF are
served, so the main text, methods and supplement were extracted from the PDFs directly.

Extracted text, the supplementary tables workbook, and cloned repos are kept in this
session's scratchpad rather than committed here, since the three papers carry different and
partly restrictive licenses (CC-BY, CC-BY-NC, CC-BY-NC-ND).
