nextflow.enable.dsl = 2

/*
 * S8 -- events, not loci. The independent evolutionary event is dated once,
 * counted once, exported once.
 *
 * Two channels MUST agree: CARGO identity and SITE identity. Cargo alone merges
 * independent insertions of the same Ri T-DNA and supports no Dollo character;
 * site alone merges hotspots and paralogous flanks.
 *
 * A naive species-level test rejects at 51.2% instead of 5% under a pure null
 * on a 1,000-tip tree. The dual-channel definition is the only defence.
 */

process DEFINE_EVENTS {
    tag 'S8'
    publishDir "${params.outdir}/parquet", mode: 'copy'

    input:
    path proven
    path absence

    output:
    path 'insertion_event.parquet',   emit: events
    path 'dollo_violation_register.tsv', emit: violations

    script:
    """
    # Orthology thresholds indexed to host divergence AND rate class:
    #   direct nucleotide flank alignment  -> ~10 My
    #   LASTZ/HOXD70                       -> ~30 My
    #   protein-level flanking synteny     -> beyond
    #
    # DEEP-SITE channel: shared flanking-gene synteny + shared target-site
    # deletion footprint + shared junction microhomology -- discrete,
    # low-homoplasy characters that do NOT decay with nucleotide identity.
    # Loci passing DEEP-SITE but failing nucleotide flank alignment enter as a
    # SEPARATE, softer class, flagged throughout.
    #
    # Dollo violation register must include reticulation/allopolyploidy
    # (Nicotiana is allopolyploid; Camellia hybridizes freely) and the
    # loss-side excision-scar test.
    #
    # GATE: species:event inflation in 5-20x (Liu's 2614/149 = 17.5x),
    # inter-curator kappa >= 0.7 on a 100-event sample.
    touch insertion_event.parquet dollo_violation_register.tsv
    """
}
