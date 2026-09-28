nextflow.enable.dsl = 2

/*
 * S6 -- the twelve-gate exclusion cascade (docs/research-program.md §4).
 *
 * Gates are HARD VETOES, cheapest first, AHEAD OF ALL SCORING. Each is an
 * alternative explanation with a near-certain likelihood ratio -- never a weak
 * channel that a bit score can outvote.
 *
 * Attrition MUST be logged per gate, per clade, STRATIFIED BY ASSEMBLY TIER.
 * Unstratified attrition is confounded with assembly quality and will be
 * misread as biology (e.g. the G3 <200 kb rule can essentially never fire on
 * chromosome-level assemblies).
 */

process EXCLUSION_CASCADE {
    tag 'S6'
    publishDir "${params.outdir}/parquet", mode: 'copy'

    input:
    path hits
    path fcs_prior

    output:
    path 'veto.parquet',           emit: veto
    path 'attrition_table.tsv',    emit: attrition
    path 'clean_candidates.parquet', emit: clean

    script:
    """
    # G0  Provability      contig N50 >= ${params.tier1_contig_n50_mb} Mb; >=2 independent DNA
    #                      extractions; >=1 comparator for the empty-site test.
    #                      A candidate is NEVER reported from a genome that could
    #                      not have proven it. Tier 4 genomes are in neither
    #                      numerator nor denominator.
    # G1  Organellar       Stratified BY DONOR DIVERGENCE BIN, never summed over
    #                      bases. A bases-summed gate passes at 99% while every
    #                      divergent NUMT sits in the residual. NUMTs past
    #                      ~15-25% divergence are invisible to both aligners
    #                      while their alphaproteobacterial protein signal
    #                      survives easily.
    # G2  Mobile domain    HUH/Rep, DDE transposase, RT, integrase with no
    #                      flanking bacterial context. Taxonomic discrimination,
    #                      NOT masking.
    # G3  Contamination    Blobplot GC x coverage; discordant coverage across
    #                      independent libraries (Koutsovoulos 2016 signature).
    #                      PLOT STRATIFIED BY ASSEMBLY TIER.
    # G4  DB artefact      Check BOTH directions; symmetric hits are artefacts.
    # G5  EGT              Called PER GENOME PHYLOGENETICALLY, never projected
    #                      from Arabidopsis. EGT sits at the BASE of a
    #                      monophyletic Archaeplastida clade, has spliceosomal
    #                      introns and a transit peptide; genuine HGT is NESTED
    #                      INSIDE extant bacterial diversity, lineage-patchy,
    #                      intron-free. Physical anchoring has ZERO power here,
    #                      so this gate cannot be deferred past the trees.
    # G6  Flank            >= ${params.min_flank_kb} kb unique plant-assignable, BOTH junctions.
    # G7  Decoy score      Per gene-family stratum, against BOTH decoys.
    # G8  Ku & Martin      >= ${params.ku_martin_identity} aa identity routes to MANDATORY PHYSICAL
    #                      PROOF, never auto-reject.
    touch veto.parquet attrition_table.tsv clean_candidates.parquet
    """
}
