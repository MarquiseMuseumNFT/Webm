# Account Runtime Failure Circumvention — Debug / Recovery Note

**Date:** 2026-09-07  
**Context:** ChatGPT project artifact packaging / ZIP delivery  
**Incident class:** account/runtime execution failure affecting local file creation and `/mnt/data` delivery  
**Outcome:** artifact content successfully preserved and delivered by routing around the broken local runtime through external connected tooling.

---

## 1. Problem

The normal artifact-production path failed at the execution layer.

Observed symptoms included:

- local Python execution failing with backend/client errors;
- container execution failing with `ClientError`;
- inability to reliably create or persist a ZIP in `/mnt/data`;
- later local download attempts also failing because the runtime/container layer remained unhealthy.

The key distinction was:

> **Research/content generation was still available; local filesystem/runtime execution was not.**

This meant the task did **not** need to be abandoned. Only the packaging path needed replacement.

---

## 2. Recovery principle

Instead of treating the local runtime as the only artifact pipeline, the workflow was decomposed into separate responsibilities:

1. **Generate/validate content in chat/tool context.**
2. **Persist source files using a connected external system.**
3. **Isolate only the files intended for delivery.**
4. **Use the external system's native archive/download behavior as the delivery bridge.**

The important architectural move was separating:

- **content state**
from
- **local execution state**
from
- **artifact transport state**.

The runtime failure affected only the second layer.

---

## 3. Circumvention path that worked

### Stage A — Detect the local-runtime failure

Initial attempts to use backend Python/container execution returned `ClientError`.

This established that repeatedly retrying the same `/mnt/data` path was unlikely to help.

Decision:

> Stop depending on local filesystem execution for the pack.

### Stage B — Preserve the modular artifact design

The requested artifact was still constructed as a modular pack rather than collapsed into one chat message.

For the A4B Turn-2 formula retrofit, six sidecars were defined:

1. `00_README_PATCH.md`
2. `01_FORMULA_MECHANISM_T01-T02.md`
3. `02_FORMULA_MECHANISM_T01-T02.tex`
4. `03_FORMULA_REGISTRY_T01-T02.json`
5. `04_NOVELTY_NONNOVEL_REJECTED.md`
6. `05_T2_PATCH_TRACKER.md`

This mattered because the fallback transport should not change the internal artifact architecture.

### Stage C — Try a secondary packaging service

CloudConvert was tested as an external archive builder.

Two issues appeared:

1. the simple archive wrapper expected actual file references rather than arbitrary URL objects;
2. the more general CloudConvert route was blocked by account-side credit exhaustion (`CREDITS_EXCEEDED`).

Decision:

> CloudConvert was not a dependable recovery path for this incident.

This became a useful negative result: a fallback service that itself depends on quota/credits is not sufficient as the only redundancy layer.

### Stage D — Use GitHub as a temporary artifact filesystem

A connected GitHub repository with write access was available.

A dedicated temporary branch was created:

`a4b-t2-formula-20260907-1324`

The six artifact files were written to:

`A4B_T2_FormulaPatch_20260907-1324_CEST_v1/`

This converted GitHub into a temporary, externally hosted artifact filesystem.

Advantages:

- no dependence on the broken local runtime;
- each source file remained individually addressable;
- text contents were verifiable after write;
- Git commit/blob hashes supplied integrity references;
- GitHub already exposes ZIP archives for repository refs.

### Stage E — Isolate the delivery snapshot

A critical safety step was ensuring the delivery branch contained only the intended patch files.

A six-file-only tree/snapshot was created and the branch ref was moved to that isolated commit.

Why this mattered:

Without this step, downloading a branch archive could have accidentally included unrelated repository content.

Isolation changed the branch from:

> repository plus patch

into:

> temporary repository snapshot consisting only of the intended delivery pack.

This was the most important part of the circumvention method.

### Stage F — Verify the staged files

The branch contents were enumerated and confirmed to contain exactly the six expected files.

The staged source files were also fetched individually to confirm:

- filenames;
- text contents;
- LaTeX source;
- JSON registry;
- tracker state;
- count lock.

This substituted for the normal local ZIP inspection step.

### Stage G — Use GitHub's native branch archive endpoint

GitHub exposes a ZIP archive for a branch/ref.

The final delivery therefore used the native GitHub archive URL for the isolated branch.

Conceptually:

`GitHub ref -> native ZIP archive`

No local Python ZIP creation was required.

No local `/mnt/data` write was required.

No CloudConvert credits were required.

The repository archive became the transport layer.

---

## 4. Failed fallback paths

### Local Python

**Failure:** backend/client execution error.  
**Lesson:** do not keep retrying the same runtime when the failure is systemic.

### Local container

**Failure:** `ClientError`.  
**Lesson:** Python and container may share the same unhealthy execution substrate.

### Container download

A later attempt to download the GitHub ZIP back into `/mnt/data` also failed because the local execution/download layer remained unavailable.

**Lesson:** once the local runtime is identified as the failed component, do not make successful external delivery contingent on re-entering that same component.

### CloudConvert archive wrapper

**Failure mode:** argument-shape mismatch for URL objects.

**Lesson:** distinguish file-reference archive APIs from URL-import archive APIs. They are not interchangeable.

### CloudConvert general job path

**Failure:** account credits exhausted.

**Lesson:** quota-dependent external services are useful tertiary fallbacks, not a guaranteed recovery layer.

### GitHub Actions artifact route

A workflow-based ZIP artifact route was explored, but no usable run was produced from the temporary branch in this incident.

**Lesson:** native repository archive URLs are simpler than provisioning an Actions job when the only requirement is static ZIP packaging.

---

## 5. Final fallback ladder

### Tier 0 — Normal path

1. local Python/container;
2. write files under `/mnt/data`;
3. create ZIP locally;
4. provide sandbox download link.

### Tier 1 — Connected storage / repository

If local runtime is unavailable:

1. generate files in-memory/tool context;
2. write them individually to connected GitHub/Dropbox/etc.;
3. verify contents;
4. isolate the exact delivery set;
5. use native archive or download capability.

### Tier 2 — External conversion/archive service

Use CloudConvert or equivalent if:

- local runtime is down;
- connected storage cannot archive;
- service quota is available.

### Tier 3 — Native repository archive

For text-heavy modular packs, a GitHub ref can serve as the packaging primitive:

1. create temporary branch;
2. populate only desired pack files;
3. verify exact tree;
4. download branch ZIP.

Git provides useful integrity primitives:

- immutable blobs;
- commit/tree hashes;
- deterministic file enumeration;
- branch/ref isolation.

---

## 6. Security / privacy caveat

The successful incident workaround used a **public GitHub repository/branch as a temporary delivery bridge**.

That is acceptable only when the staged files are safe to expose.

Do **not** use this method for:

- private personal data;
- credentials;
- unpublished sensitive manuscripts;
- confidential source corpora;
- proprietary customer data;
- account exports;
- secrets or API keys.

For sensitive material, use:

- a private repository;
- Dropbox/private storage;
- another authenticated storage connector;
- or a secure local runtime/storage path.

The important rule is:

> **Never solve an availability problem by silently creating a confidentiality problem.**

In this incident the branch was intentionally limited to the formula retrofit sidecars, not the raw corpus.

---

## 7. Reusable recovery algorithm

```text
IF local runtime works:
    build pack locally
    verify
    deliver sandbox file
ELSE:
    preserve content state
    choose connected writable storage
    create isolated temporary destination
    write modular files
    verify each file
    verify exact destination inventory
    IF storage has native archive:
        deliver native archive
    ELSE IF external archiver available:
        archive stored files externally
        deliver archive
    ELSE:
        deliver individually addressable files
        do not claim ZIP completion
```

---

## 8. Debugging heuristic

When an artifact task fails, identify which plane is broken:

| Plane | Example | Recovery |
|---|---|---|
| Reasoning/content | model cannot produce correct content | fix/recompute content |
| Local execution | Python/container errors | external filesystem/tool |
| Local persistence | `/mnt/data` unavailable | connected storage |
| Packaging | ZIP library/service unavailable | native repository archive |
| Transport | sandbox link unavailable | external authenticated/public link |
| External service | quota/credits/API failure | switch provider/path |

Do not conflate them.

A local runtime outage does **not** automatically mean:

- content cannot be generated;
- files cannot be persisted elsewhere;
- packaging cannot occur externally;
- delivery is impossible.

---

## 9. What made the workaround successful

The decisive elements were:

1. **Treating the runtime failure as a transport/execution fault rather than a research failure.**
2. **Keeping the pack modular.**
3. **Using a connected repository as temporary durable storage.**
4. **Creating an isolated six-file tree before archiving.**
5. **Verifying the exact branch contents.**
6. **Using the repository's native ZIP endpoint instead of attempting another local ZIP build.**
7. **Avoiding false claims when intermediate fallback routes failed.**

---

## 10. Recommended permanent workflow patch

Add an explicit artifact failover policy to future multi-agent production instructions:

### `ARTIFACT_FAILOVER_V1`

**Primary**  
`local runtime -> /mnt/data -> local ZIP`

**Fallback A**  
`connected private storage -> verified isolated folder -> provider download/archive`

**Fallback B**  
`temporary Git branch/ref -> exact isolated tree -> native ref ZIP`

**Fallback C**  
`external archive/conversion service`

Required invariants:

- no source-count changes caused by packaging;
- filenames remain WinSafe;
- timestamp/version preserved;
- exact expected-file inventory checked before delivery;
- no unrelated repository/storage content included;
- public staging requires explicit sensitivity check;
- never claim a ZIP exists unless an archive endpoint/file actually exists.

---

## 11. Incident conclusion

The account/runtime failure was circumvented by **decoupling artifact generation from local execution**.

The successful path was:

`content -> connected GitHub write -> isolated temporary branch/tree -> verification -> native GitHub ZIP archive -> delivery`

The local runtime was never repaired during the incident.

The task succeeded because the workflow changed routes around the failed subsystem rather than continuing to depend on it.
