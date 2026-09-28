#!/usr/bin/env Rscript
# S9 -- the clock correction. The cheapest real result in the program.
#
# Four compounding, NON-CANCELLING errors in the published inverted-repeat clock:
#   1. K/r vs K/(2r)   -- biases OLD (~2x)
#   2. gene conversion -- biases YOUNG, heterogeneously, worse for older loci.
#                         UNTESTED anywhere. Pushes OPPOSITE to (1), so the two
#                         do NOT bracket each other.
#   3. rate transfer   -- Gaut et al. 1996 (PNAS 93:10274, PMID 8816790) reports
#                         2.61e-9 per SYNONYMOUS SITE per year for palm Adh,
#                         grasses ~2.5x faster. The field applies 6.5e-9 to
#                         NON-CODING repeat divergence in EUDICOTS, mosses and
#                         ferns. Plausibly 2-3x on its own.
#   4. no multiple-hits correction at ~10% divergence.

suppressPackageStartupMessages(library(ape))

# Jukes-Cantor correction for multiple hits.
jc69 <- function(p) {
  stopifnot(all(p < 0.75, na.rm = TRUE))
  -3/4 * log(1 - 4/3 * p)
}

#' Age from inverted-repeat arm divergence.
#' @param p     uncorrected proportion of differing sites between the arms
#' @param rate  substitutions per site per year for THIS lineage
#' @param convention "half" for t = K/(2r) (standard, as in LTR dating),
#'                   "full" for t = K/r (what the cT-DNA literature appears to use)
#' @param correct_multiple_hits apply Jukes-Cantor
repeat_age <- function(p, rate, convention = c("half", "full"),
                       correct_multiple_hits = TRUE) {
  convention <- match.arg(convention)
  K <- if (correct_multiple_hits) jc69(p) else p
  denom <- if (convention == "half") 2 * rate else rate
  K / denom
}

# --- Reproduce the discrepancy -------------------------------------------------
# Camellia CaTA: 9.7% arm divergence, reported as "~15 Myr".
p_cata    <- 0.097
rate_lit  <- 6.5e-9   # the constant as used in the literature

cat("Camellia CaTA, literature rate 6.5e-9:\n")
cat("  t = K/r,  no JC  :", round(repeat_age(p_cata, rate_lit, "full", FALSE)/1e6, 1), "My",
    " <- reproduces the published ~15 My\n")
cat("  t = K/2r, no JC  :", round(repeat_age(p_cata, rate_lit, "half", FALSE)/1e6, 1), "My",
    " <- standard convention\n")
cat("  t = K/2r, with JC:", round(repeat_age(p_cata, rate_lit, "half", TRUE)/1e6, 1), "My\n")

# TODO S9:
#  - propagate LINEAGE-SPECIFIC rates (every real carrier is a slow-evolving
#    woody perennial; conifer nuclear rates are ~an order of magnitude lower)
#  - test whether the same correction moves the Diospyros ages (Otten 2025),
#    which use the same method and the same constant
#  - GENECONV + PHI on each repeat pair; profile divergence against
#    distance-from-repeat-centre. Absent a clean negative, the repeat clock is
#    DEMOTED from cross-check to annotation and removed from the S9 gate.
#  - report BOTH conventions throughout: with ~27-30 loci across clades of
#    genuinely different true rates and left-censored brackets, the censored
#    regression is very likely UNIDENTIFIABLE. The honest deliverable is an
#    arithmetic correction with order-of-magnitude intervals, not a new rate.
