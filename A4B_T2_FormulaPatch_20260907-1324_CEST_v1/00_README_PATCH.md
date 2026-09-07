# A4B Turn-2 Formula / Mechanism Retrofit Patch

**Pack:** `A4B_T2_FormulaPatch_20260907-1324_CEST_v1`  
**Date:** 2026-09-07 13:24 CEST  
**Lane:** A4/A4B — Deep Time & Civilizational Futures  
**Scope:** cumulative formula/mechanism backfill through Turns 1–2; no source-chat re-mining; no count promotion.

## Why this patch exists

The cumulative Turn-2 A4 pack preserved equations and mechanism chains inside the paper/reasoning ledgers but omitted the dedicated formula/mechanism sidecar required by the successor handover. This patch repairs that packaging omission without rebuilding the full Turn-2 pack.

The structure follows the peer formula-sidecar convention:
- stable formula/mechanism IDs;
- derivation status labels;
- human-readable Markdown;
- canonical LaTeX;
- machine-readable registry;
- novel / non-novel / rejected tracking;
- provenance, variables, assumptions, failure conditions, proof obligations and carry-forward actions.

## Status vocabulary

- `SOURCE-EXPLICIT` — equation/relation explicitly present in source text.
- `SOURCE-DERIVED` — relation/chain reconstructed from source reasoning without claiming a literal source equation.
- `FORMALIZATION-CANDIDATE` — mathematical formalization proposed to operationalize a source-derived mechanism.
- `ILLUSTRATIVE` — notation/model useful for screening but not a source claim.
- `REJECTED` — model explicitly rejected or superseded by the reasoning chain.

## Turn-2 provenance warning

Turn-2 chats `005:084`, `005:088`, `005:064`, `006:042`, `006:043` remain `CONTROL-DEEP / RAW-REOPEN`, not canonical raw-exhausted. Therefore no Turn-2 object in this retrofit is labelled `SOURCE-EXPLICIT`. Exact raw paragraph reconstruction remains a promotion gate.

## Count lock

- Confirmed new 937 rows: **+0**
- Active 937 holds: **15**
- Confirmed new 104 papers: **+0**
- Strong provisional paper kernel: **PBEC = +1 provisional**
- Merge/branch paper structures: **4**

This patch changes packaging and formal traceability only.

## Files

1. `00_README_PATCH.md`
2. `01_FORMULA_MECHANISM_T01-T02.md`
3. `02_FORMULA_MECHANISM_T01-T02.tex`
4. `03_FORMULA_REGISTRY_T01-T02.json`
5. `04_NOVELTY_NONNOVEL_REJECTED.md`
6. `05_T2_PATCH_TRACKER.md`

## Integration rule

Merge these sidecars into the existing cumulative Turn-2 A4 pack. Do not replace the original conversation, 937, 104, provenance, or paragraph trackers. This is an additive retrofit.