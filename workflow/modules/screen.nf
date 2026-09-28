nextflow.enable.dsl = 2

/* S1--S5 -- refutation, query set, permissive screen, decoy calibration. */

process MOSS_FERN_NULL {
    tag 'S1 matters-arising'
    publishDir "${params.outdir}/cards/moss_fern", mode: 'copy'

    input:
    path panel

    output:
    path 'pf18631_identity_distribution.tsv', emit: null_dist
    path 'corpus_misfiling_census.tsv',       emit: misfiling
    path 'moss_fern_verdict.md',              emit: verdict

    script:
    """
    # (1) Chance-homology null as a FULL DISTRIBUTION, by donor lineage.
    #     blastp R. rhizogenes Cus (Q9FAF7, 320 aa) against the complete
    #     Pfam PF18631 set. Verified anchors that must be recovered:
    #       Mycena alexandri        58.8% id, E=2.8e-141  (a moss/litter agaric)
    #       Microvirga puerhi       87.7% id
    #       Actinomadura physcomitrii LD22(T)  -- endophyte ISOLATED FROM MOSS
    #
    # (2) Corpus arithmetic: Liu report 75 fern species; GenBank holds 28 fern
    #     assemblies across 21 binomials. 75 > 21, so the fern signal cannot
    #     rest on assemblies. Census the taxid-misfiling trap -- e.g.
    #     GCA_965284325.1 is filed under Aquilegia reuteri (a eudicot) but is
    #     NI281-mx-bin04, a 4,044,082 bp single-contig metagenome bin at
    #     38.5% GC, at assembly_level COMPLETE GENOME.
    #
    # Pre-registered rule: REFUTED / SUPPORTED / UNRESOLVED.
    # The statistic is PER INDEPENDENT LINEAGE, never per species:
    # ~157 species collapse to ~30-50 lineages, so rule-of-three gives
    # <=3/40 ~= 7.5%, not 3/157 ~= 1.9%.
    touch pf18631_identity_distribution.tsv corpus_misfiling_census.tsv moss_fern_verdict.md
    """
}

process BUILD_QUERYSET {
    tag 'S2'
    publishDir "${params.outdir}/ref/queryset", mode: 'copy'

    output:
    path 'qs_*',        emit: queryset
    path 'p_det.tsv',   emit: p_det

    script:
    """
    # QS-A pTi/pRi plasmids   QS-B seed proteins   QS-C per-subfamily HMMs
    # QS-D border models      QS-E decoys          QS-F read-through panel
    #
    # QS-C: the plast superfamily MUST be modelled as separate subfamilies --
    # members share only 20-30% aa identity, and reciprocal-best-hit merges
    # rolB with orf13 and shatters rolC.
    #
    # p_det is measured, RATE-CLASS-STRATIFIED, and frozen BEFORE the search is.
    # A single global rate is wrong by ~20x between Pinus and Brassicaceae, and
    # every real carrier is a slow-evolving woody perennial.
    touch qs_a qs_b qs_c qs_d qs_e qs_f p_det.tsv
    """
}

process PERMISSIVE_SCREEN {
    tag "${accessions.baseName}"
    publishDir "${params.outdir}/parquet", mode: 'copy'

    input:
    path accessions
    path queryset

    output:
    path 'locus_hit.parquet', emit: hits

    script:
    """
    # Run the only genuinely expensive computation ONCE at the permissive
    # extreme and persist EVERY hit with full covariate context. Every
    # downstream threshold then becomes a <1 s Parquet filter.
    #
    # Detector runs on UNMASKED sequence (G2): masking deletes the
    # highest-prior true positives -- a 120-aa 100%-identity hit at E=1.47e-91
    # collapses to an 8-aa E=2.5 hit under -lcase_masking. Repeat annotation is
    # a post-hoc covariate BED, never an edit to the sequence.
    #
    # Write annotations as COLUMNS, never as filters.
    touch locus_hit.parquet
    """
}

process DECOY_OPERATING_POINT {
    tag 'S4 gate'
    publishDir "${params.outdir}/parquet", mode: 'copy'

    input:
    path hits
    path queryset

    output:
    path 'decoy_fdr_curve.tsv', emit: curve

    script:
    """
    # TWO decoys, and the DISAGREEMENT between them is the diagnostic:
    #   (a) ecology-broken statistical decoy -- measures statistical FDR, and is
    #       constitutionally blind to contamination by plausible donors
    #   (b) ecologically-plausible-contaminant decoy, built BY TAXID LINEAGE
    #       from plant endophytes, seed/rhizosphere taxa and litter fungi
    # concordance-FDR >> decoy-FDR means the residue is contamination,
    # not statistics.
    #
    # GATE: if no operating point exists where decoy hits/Gbp < 0.1x true-DB
    # hits/Gbp, the statistical detector has no usable regime and the project
    # converts entirely to the upper-bound arm. That is a legitimate outcome.
    touch decoy_fdr_curve.tsv
    """
}
