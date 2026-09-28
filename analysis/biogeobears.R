#!/usr/bin/env Rscript
# S10 -- ancestral range estimation. SECONDARY, behind an information gate.
#
# The defensible WHERE is insertion allele frequency at real coordinates in the
# species that actually carry cT-DNA. DEC at the stem node of a PLANT clade,
# over a stem spanning tens of My of continental rearrangement, is dominated by
# that clade's own history and carries no Agrobacterium information.
#
# Three reasons this is demoted:
#   - BioGeoBEARS has NO principled per-area incomplete-sampling parameter;
#     range-dependent sampling is not identifiable from tip ranges alone, so the
#     "correction" is a fixed offset whose effect is itself a sensitivity.
#   - >=5 tips across >=6 TDWG areas is parameter-saturated.
#   - The carriers are DOMESTICATES (Ipomoea batatas, Camellia, Musa, Dioscorea,
#     Juglans, Arachis) whose native ranges are anthropogenically rewritten and
#     actively disputed.
#
# INFORMATION GATE: report DEC results only if posterior range entropy is
# materially below prior entropy AND the stem reconstruction is stable across
# 1,000 chronograms. Otherwise report as flat -- a legitimate pre-registered
# result.
#
# Also report the +J controversy both ways (Ree & Sanmartin 2018 vs Matzke 2022).
#
# And note: a species-level geographic test rejects at 51.2% under a pure null
# on a 1,000-tip tree. A phylogenetic permutation null is mandatory.
