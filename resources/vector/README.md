# Transgene and vector screen (G6 layer)

Four layers, with the **topology veto decisive**.

1. **UniVec build 10.0** — *not* UniVec_Core. Build 10.0 carries **240 segments from 67 plant binary
   vector accessions**; Core carries 24.
   **Mask UniVec's 10,777 annotated biological intervals FIRST**, or the screen rejects genuine plant
   and Agrobacterium sequence.
2. **Whole binary vector backbones** — pBIN19, pCAMBIA series, pGreen, pPZP, pBI121; ColE1 / pVS1 /
   pRK2 origins.
3. **Explicit markers** — CaMV 35S, NOS promoter/terminator, `nptII`, `hpt`/`hph`, `bar`/`pat`,
   `gus`/`uidA`, `gfp`, Cre/lox, FLP/FRT; borders in engineered (perfect-consensus) form.
4. **Backbone-beyond-border topology** — decisive. Sequence outside the borders is **always**
   contamination and can never be natural cT-DNA.

Plus a lab/breeding-line blacklist on BioSample/cultivar metadata, and taxid traps **357 / 358 / 359**
including current renamings (a genus-string filter silently misses reclassified entries).

Sequences are fetched via `resources/manifest/`, never committed — see `.gitignore`.
