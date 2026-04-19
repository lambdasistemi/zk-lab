# Aiken verifiers

All on-chain verifiers are written in [Aiken](https://aiken-lang.org/),
compiled to Plutus Core (UPLC), and committed as `.plutus` artifacts
alongside their source.

## Layout

```
onchain/
├── aiken.toml
├── lib/
│   ├── groth16/
│   │   ├── types.ak
│   │   └── verify.ak
│   ├── bbs/
│   │   ├── generators.ak
│   │   ├── types.ak
│   │   └── verify.ak
│   └── halo2/       -- if/when feasible
└── validators/
    └── <statement>/
        └── verify.ak    -- binds a verifier to a specific statement
```

## Discipline

- **One validator per statement.** A statement's validator imports
  the relevant backend verifier from `lib/` and adds
  statement-specific binding (nullifiers, context, public inputs).
- **Type-checked end-to-end.** The statement's public inputs are a
  datatype shared between the Haskell DSL, the Aiken validator, and
  the test vectors. Mismatches surface at build, not at runtime.
- **No verifier reuse across unrelated statements.** Copy-paste is
  fine; silent sharing of code between semantically different
  validators is not. Audit clarity beats DRY.

## Budget tracking

Every validator carries a budget table in its `README.md`: CPU
steps, memory units, script size, measured on a pinned Aiken
version and documented corpus of inputs. Regressions in these
numbers are PR-blocking.
