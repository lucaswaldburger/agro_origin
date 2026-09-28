#!/usr/bin/env Rscript
# S9 -- Dollo bracketing to per-event age posteriors.

suppressPackageStartupMessages({ library(ape); library(phytools) })

# CRITICAL, and it fails SILENTLY.
# Passing NA to phytools::make.simmap yields an all-zero tip row -> NaN
# likelihood -> logL forced to Inf -> an objective the optimiser cannot move ->
# maps returned under a Q that was NEVER FITTED, with no error and no warning.
# Verify tip encoding numerically on synthetic data BEFORE any real run.
encode_tip <- function(state, p_det = NA_real_) {
  switch(state,
    present          = c(0, 1),            # junction-proven
    absent_proven    = c(1, 0),            # L2/L3 read-backed or k-mer absent
    underpowered     = c(1, p_det),        # graded; L0/L1 may NOT bound a bracket
    stop("unknown tip state: ", state))
}

# Dollo constraint: GAIN FREE, LOSS FREE, RE-GAIN ZERO.
# q10 = 0 is biologically FALSE -- cT-DNAs are lost by segmental deletion, the
# same decay the pipeline exists to detect -- and truncates every bracket young.
dollo_Q <- function() matrix(c(NA, NA, 0, NA), 2, 2,
                             dimnames = list(c("absent","present"), c("absent","present")))

# PRUNE to carrier clade + sister outgroups before EVERY simmap.
# make.simmap on the full 128,270-tip Carruthers backbone x 1,000 replicates
# x 1,000 maps is ~1000x budget and RAM-infeasible in R.
prune_for_event <- function(tree, carriers, outgroups) {
  keep <- c(carriers, outgroups)
  ape::keep.tip(tree, intersect(keep, tree$tip.label))
}

# NEVER use point node ages. Recompute (crown, stem) on each of 1,000 replicate
# chronograms plus >=2 alternative timescales. If a conclusion flips between
# them, it is not a conclusion.
