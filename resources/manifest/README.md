# Reference manifest and freeze policy

Five of the largest dependencies are **mutable in place** and four ship **no checksum**. Every
reference is pinned here with a SHA-256 we compute ourselves, and every fetch is verified against it.

| Dependency | Hazard |
|---|---|
| **FCS-GX database** | Exists only at an undated `latest` prefix and **vanishes on rebuild**. Pin `all.manifest`, build `2023-01-24T16:18:22`, 464.3 GiB. Not rebuilt since — every bacterium described in the last ~3.7 years is invisible to it. It also explicitly **ignores intra-kingdom chimeras below 10 kbp**, which is exactly our size class. **A prior, never a verdict.** |
| **`assembly_summary_genbank.txt`** | Regenerates **daily**, no checksum. 10,097 data rows, **38 columns**. |
| **FCS report bulk files** | Regenerate daily, no checksum. `fcs_summary` 52.7 MB; `fcs_details` 475 MB / 52,784,075 rows. |
| **gzip access points** | Invalidated by **any** upstream re-release or suppression. Pin a SHA-256 per assembly and verify per fetch. NCBI `*_genomic.fna.gz` are single-member plain gzip (`FLG=0x00`), **not BGZF**, so htslib cannot seek them. |
| **NCBI census** | Grows ~3,000 assemblies/yr. Re-run quarterly and record the pull date. |

`dependencies.tsv` is the machine-readable pin list.
