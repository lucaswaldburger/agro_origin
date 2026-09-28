#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

/*
 * agro_origin -- a junction-proven fossil record of bacterial DNA in plant genomes
 *
 * Stage numbering follows docs/research-program.md §2. Ordering principle:
 * run the decisive cheap tests first. S1 (moss/fern refutation) and S4 (decoy
 * operating point) can each terminate or redirect the program before any
 * expensive stage is committed.
 */

include { ACQUIRE_CENSUS; ACQUIRE_FCS_PRIOR   } from './modules/acquire.nf'
include { MOSS_FERN_NULL; BUILD_QUERYSET      } from './modules/screen.nf'
include { PERMISSIVE_SCREEN; DECOY_OPERATING_POINT } from './modules/screen.nf'
include { EXCLUSION_CASCADE                   } from './modules/cascade.nf'
include { JUNCTION_PROOF; GRADED_ABSENCE      } from './modules/junction.nf'
include { DEFINE_EVENTS                       } from './modules/event.nf'
include { BRACKET_DATE                        } from './modules/date.nf'
include { TI_RI_SUBSTRATE; VIR_CONCORDANCE    } from './modules/armB.nf'

params.stage        = 'S1'      // earliest stage to run
params.census_taxon = 33090     // Viridiplantae
params.outdir       = '/mnt/data/agro'

workflow {

    // --- S0: freeze references, pin checksums ------------------------------
    census   = ACQUIRE_CENSUS( params.census_taxon )
    fcs      = ACQUIRE_FCS_PRIOR()

    // --- S1: moss/fern refutation. Ships first: workstation-days, zero reads.
    //     Standalone Matters Arising; does not depend on anything downstream.
    MOSS_FERN_NULL( file("${projectDir}/../resources/queryset/panel.tsv") )

    // --- S2: query set, decay ladder, p_det surface ------------------------
    qs       = BUILD_QUERYSET()

    // --- S3: pilot on eight known-carrier genera ---------------------------
    //     GATE: conversion rate of KNOWN true positives to Tier 1. This is the
    //     gating feasibility number for half the program and is unmeasurable
    //     before now.
    pilot    = PERMISSIVE_SCREEN( census.pilot_accessions, qs )

    // --- S4: decoy operating point -----------------------------------------
    //     GATE: if no operating point exists where decoy hits/Gbp < 0.1x
    //     true-DB hits/Gbp, the statistical detector has no usable regime and
    //     the project converts entirely to the upper-bound arm.
    DECOY_OPERATING_POINT( pilot, qs )

    // --- S5 onward require the 1 TiB-RAM host; see configs/bigmem.config ----
    hits     = PERMISSIVE_SCREEN( census.all_accessions, qs )
    clean    = EXCLUSION_CASCADE( hits, fcs )
    proven   = JUNCTION_PROOF( clean )
    absence  = GRADED_ABSENCE( proven )
    events   = DEFINE_EVENTS( proven, absence )
    dated    = BRACKET_DATE( events )

    // --- Arm B --------------------------------------------------------------
    substrate = TI_RI_SUBSTRATE()
    VIR_CONCORDANCE( substrate, dated )
}
