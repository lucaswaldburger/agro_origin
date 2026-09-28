nextflow.enable.dsl = 2

/*
 * S11--S12 -- Arm B. The Ti/Ri substrate and the vir verdict.
 *
 * STRUCTURAL CONSTRAINT, stated in Arm B's opening paragraph: cT-DNA is by
 * definition the region INSIDE the 25-bp borders; vir/T4SS lies outside and is
 * never transferred. A dated cT-DNA calibrates T-DNA CARGO gene trees ONLY.
 *
 * Two classic fossil-calibration errors to avoid:
 *   - an insertion bounds the STEM of the cargo lineage, not the CROWN of the
 *     plasmid clade
 *   - with every calibration in one shallow horizon (<=12 Myr, <=7.5 Myr
 *     post-correction), no time-dependent-rate model is identifiable and every
 *     deep node is prior-dominated. A ROOT AGE MUST NOT BE PRINTED.
 */

process TI_RI_SUBSTRATE {
    tag 'S11'
    publishDir "${params.outdir}/ref/armB", mode: 'copy'

    output:
    path 'ti_ri_typed.tsv',      emit: typed
    path 'cargo_alignments/',    emit: alignments

    script:
    """
    # 9,747 Rhizobiaceae assemblies, 0.059 Tbp, ~20 GB gz -- 0.5% of Arm A.
    # Not a compute problem.
    #
    # Type plasmids by MODULE ARCHITECTURE (repABC, vir regulon, borders, opine
    # catabolism) -- never by submitter replicon name (pTi-named complete
    # records span 2,850 bp to 1,007,991 bp; ~30% unnamed) and never by
    # annotation keyword (virD4 is a generic T4CP).
    #
    # Align with MACSE v2 -- the only production aligner that scores nucleotides
    # through AA translation while allowing internal stops and frameshifts.
    # PRANK translates frame 1 without error checking; MAFFT has no codon model;
    # both silently convert a frameshifted cT-DNA into noise.
    #
    # Run GARD on every alignment and split at accepted breakpoints.
    mkdir -p cargo_alignments
    touch ti_ri_typed.tsv
    """
}

process VIR_CONCORDANCE {
    tag 'S11 vir verdict'
    publishDir "${params.outdir}/parquet", mode: 'copy'

    input:
    path substrate
    path dated

    output:
    path 'concordance_report.tsv', emit: verdict

    script:
    """
    # THIS GATE DELIVERS THE VIR VERDICT AND IS THE ONLY TEST OF IT.
    #
    # Build cargo gene trees, a VirB4/T4SS tree with a NESTED OUTGROUP LADDER
    # (in-genus MPF_T co-residents -> protein-secretion MPF_T exaptations ->
    # other MPF classes -> VirD4/T4CP), and a chromosomal backbone tree.
    # State plainly that the deepest rooting is weak at 48-69% support.
    #
    # Quantify discordance with gCF/sCF and AU.
    #   iqtree3 -s aln -z constraint_trees.nwk -zb 10000 -au
    #   NOTE: -au does NOTHING without -zb, which supplies the RELL replicates.
    #
    # If gene concordance between T-DNA regions and the vir regulon is at or
    # near free-reassortment expectation, the vir calibration is DEAD and that
    # is reported as the result.
    #
    # Do NOT restrict calibration transfer to families that already track the
    # backbone -- that preselects for the hypothesis under test.
    touch concordance_report.tsv
    """
}
