nextflow.enable.dsl = 2

/*
 * S7 -- G9/G10/G11. Physical junction proof from UNASSEMBLED reads.
 *
 * G9 is the single stand-alone veto and the only gate that cannot be traded
 * against any other. The logic: a contaminant contig's host-insert junction is
 * an ASSEMBLY CHIMERA, so its junction k-mers exist in ZERO libraries at any
 * depth, while a real insertion's exist in every library.
 *
 * Budget as bloom-filtered k-mer baiting then local reassembly of matching
 * reads only (~0.3-0.6 CPU-h/accession) -- NOT full-WGS mapping
 * (~100-200 CPU-h/accession). This was the largest unpriced item in every
 * candidate design.
 *
 * RUN IN-REGION (AWS us-east-1). ENA transatlantic is 10.4 MB/s at N=16, which
 * is 9.5 weeks of continuous transfer against a wall with zero slack.
 */

process JUNCTION_PROOF {
    tag 'S7'
    publishDir "${params.outdir}/parquet", mode: 'copy'

    input:
    path candidates

    output:
    path 'junction_evidence.parquet', emit: proven

    script:
    """
    # k=${params.junction_kmer}: 31-mer chance occurrence in ~700 Gbp is ~3e-7,
    # versus ~0.32 at k=21.
    #
    # Require >= ${params.min_junction_reads} spanning reads per side from
    # >= ${params.min_extractions} INDEPENDENT DNA EXTRACTIONS -- not two
    # libraries off one prep, which share the contaminant and the
    # chimera-forming steps.
    #
    # The junction must appear as a SIMPLE UNBRANCHED PATH in a graph we built
    # ourselves -- not a bubble or a tangle.
    #
    # Depth and methylation are COVARIATES that may never fail a candidate alone.
    touch junction_evidence.parquet
    """
}

process GRADED_ABSENCE {
    tag 'S7'
    publishDir "${params.outdir}/parquet", mode: 'copy'

    input:
    path proven

    output:
    path 'absence_proof.parquet', emit: absence

    script:
    """
    # Four levels. ONLY L2/L3 may bound a bracket.
    #   L0  not examined
    #   L1  assembly-absent          (NOT evidence of absence)
    #   L2  read-backed empty site
    #   L3  k-mer-index absent
    #
    # Compute expected spanning-read depth FIRST and emit NO-CALL, never
    # ABSENT, whenever expected < ${params.min_junction_reads}.
    #
    # Logan discards singleton 31-mers per accession, so a Logan miss is a
    # statement about low-abundance sequence, not a proof of zero. Report
    # detection floors, never absolute absence.
    touch absence_proof.parquet
    """
}
