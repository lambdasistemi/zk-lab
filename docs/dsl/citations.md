# Citations

This page is the single place where the zk-lab codebase records what it
borrowed, from whom, and why. Every downstream file that lifts a
formulation, diagram, definition, or snippet of code from elsewhere
links back to an entry here.

## Why

Constitution principle 7a, *Steal, always cite*:

> We freely take from existing materials — explanations, diagrams,
> definitions, phrasings, code — whenever doing so produces better work
> than reinventing. In exchange, every borrowed element carries an
> explicit citation to its source. Uncited borrowing is a bug.

The rule is not decorative. It is how we separate:

- **work this lab did** — experiments, DSL shape, parity enforcement,
  the specific Cardano wiring;
- **work this lab did not do** — the cryptography itself, the hash
  constructions, the formal proofs of underlying systems.

Mixing those two produces dishonest documentation, which this
constitution treats as a bug.

## What a citation must contain

Every borrowed element carries, at minimum:

- **Source**: paper or book (DOI / arXiv id / ISBN) or public
  repository (full URL, including commit SHA if code).
- **Authors** and **year**.
- **What was taken** — one line. "Figure 3's decomposition of the
  range check." "The proof sketch of Lemma 4." "The `hashToCurve`
  helper, line-for-line."
- **Why** — one line. Why was this borrowed instead of reinvented?

Diagrams add "*after X, year*" in the caption. Code adds a file-level
header pointing to the source commit.

## Where citations live

- **Prose / math / diagrams**: inline link to the entry below, in the
  file that uses them.
- **Code**: file-level header comment with the same fields, plus a
  pointer to this page.
- **Per-backend**: each `implementation/<backend>.md` and each
  `experiments/<name>/README.md` carries its own subsection,
  cross-linked from here.

## Registry

The registry is intentionally empty at bootstrap. Entries land per user
story, alongside the code or prose that uses them.

<!-- Each entry below should follow this template:

### <Short name>

- **Source**: <paper / repo URL + commit>
- **Authors / Year**: <authors>, <year>
- **Taken**: <one-line description>
- **Why**: <one-line rationale>
- **Used in**: <list of files/sections in this repo that reference it>

-->

## Enforcement

Reviewers block PRs that:

- add mathematical or cryptographic definitions without a citation;
- include diagrams that are clearly adapted from a published source
  without the "*after X, year*" caption;
- import code without a file-level attribution header.

A missing citation is treated the same as a failing test.
