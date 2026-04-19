# Semantic graph

This is the lab's living ontology of zero-knowledge: concepts,
people, papers, protocols, deployments, and — crucially — the
cultural and practical forces that shape them.

It is written in **Turtle (RDF 1.1)** using standard ontologies:

| Ontology | Purpose |
|----------|---------|
| `rdf` / `rdfs` / `owl` | Core RDF Schema and OWL class hierarchy |
| `skos` | Concept schemes; one scheme per chapter |
| `dcterms` | Titles, descriptions, creators, dates, references |
| `foaf` | People and their pages |
| `prov` | Provenance of claims and artifacts |
| `bibo` | Bibliographic records (papers, books) |
| `gb:` | [graph-browser][gb] node / edge annotations |

The graph is published through the
[graph-browser][gb] with **per-chapter filters**. Each chapter is a
`skos:ConceptScheme`; the browser exposes a filter to restrict the
view to a single chapter, or to traverse across chapters.

## Chapters

Three SKOS concept schemes, each a viewpoint onto the same graph:

- **[Culture](culture.md)** — history, communities, social and
  political forces. Who built what, when, why, and what it
  displaced.
- **[Abstractions](abstractions.md)** — the mathematical layer:
  interactive vs non-interactive proofs, soundness, extractors,
  arithmetizations, commitments, setups.
- **[Real-life challenges](challenges.md)** — what breaks when
  zero-knowledge meets the world: ceremony governance, quantum
  threat, regulation, auditability, prover hardware, UX.

## Source

The graph follows the
[graph-browser][gb] data convention:

- **Turtle file:** [`data/rdf/zkp.ttl`][ttl] — the canonical data.
- **graph-browser config:** [`data/config.json`][config].
- **SPARQL views:** [`data/queries.json`][queries] — one entry per
  chapter, plus cross-cutting views (mitigations, cross-chapter
  edges).

Everything citable — every page, every paper, every person — has a
`foaf:page` pointing to a primary source. We take freely; we cite
always.

[ttl]: https://github.com/lambdasistemi/zk-lab/blob/main/data/rdf/zkp.ttl
[config]: https://github.com/lambdasistemi/zk-lab/blob/main/data/config.json
[queries]: https://github.com/lambdasistemi/zk-lab/blob/main/data/queries.json

## How to read the graph

Three entry points:

1. **Read it as prose.** The chapter pages summarize the scheme
   they filter on.
2. **Browse it interactively.** The graph-browser deep-links into
   any node via the `?node=` query string, with filters applied
   per chapter.
3. **Query it.** SPARQL queries under `queries.json` power custom
   views; run them in-browser against the local Oxigraph store.

[gb]: https://lambdasistemi.github.io/graph-browser/
