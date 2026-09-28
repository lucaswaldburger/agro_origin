nextflow.enable.dsl = 2

/*
 * S9 -- dated backbone and Dollo bracketing to per-event AGE POSTERIORS.
 *
 * Backbone: Carruthers et al. 2026 (128,270 tips) WITH its 1,000 bootstrap
 * replicate chronograms. NEVER use point node ages: recompute (crown, stem) on
 * each of 1,000 replicates plus >=2 alternative timescales. If a conclusion
 * flips between them it is not a conclusion.
 *
 * Independently re-derive every published age; do not cite them.
 */

process BRACKET_DATE {
    tag 'S9'
    publishDir "${params.outdir}/parquet", mode: 'copy'

    input:
    path events

    output:
    path 'age_draw.parquet',        emit: dated
    path 'clock_comparison.tsv',    emit: clock

    script:
    """
    # THE CLOCK CORRECTION. Four compounding, NON-CANCELLING errors:
    #   1. K/r vs K/(2r)      -- biases OLD  (~2x)
    #   2. gene conversion    -- biases YOUNG, heterogeneously. UNTESTED anywhere.
    #                            Because it pushes the opposite way from (1),
    #                            the two do NOT bracket each other.
    #   3. rate transfer      -- Gaut 1996 is 2.61e-9 per SYNONYMOUS SITE for
    #                            palm Adh (grasses ~2.5x faster), being applied
    #                            to non-functional non-coding DNA in eudicots,
    #                            mosses and ferns. Plausibly 2-3x on its own,
    #                            i.e. at least as large as the error in (1).
    #   4. no multiple-hits correction at ~10% divergence.
    #
    # Run GENECONV + PHI on each repeat pair and profile divergence against
    # distance-from-repeat-centre. Absent a clean negative, the repeat clock is
    # DEMOTED from cross-check to annotation and removed from the gate.
    #
    # With ~27-30 loci across clades of genuinely different true rates and
    # left-censored brackets, the censored regression is very likely
    # UNIDENTIFIABLE. Report BOTH conventions throughout -- that is still a
    # service, since the literature applies one without stating which.
    #
    # Prune to clade + outgroups BEFORE every simmap: full-backbone
    # make.simmap is ~1000x budget and RAM-infeasible in R.
    #
    # Verify tip encoding NUMERICALLY first: passing NA to phytools yields an
    # all-zero row -> NaN likelihood -> logL = Inf -> the optimiser returns
    # q.init, producing maps under a Q that was never fitted, with NO error and
    # NO warning.
    touch age_draw.parquet clock_comparison.tsv
    """
}
