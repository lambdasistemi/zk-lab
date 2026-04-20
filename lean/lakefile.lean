import Lake
open Lake DSL

package «zk-lab» where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩
  ]

-- Mathlib4 is added in Phase 3 when the first real theorem lands.
-- For the Phase 1 skeleton we keep the lakefile offline-buildable so
-- it fits inside a nix sandbox without network access.

@[default_target]
lean_lib «ZKLab» where
