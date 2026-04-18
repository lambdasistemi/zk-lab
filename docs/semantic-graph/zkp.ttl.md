# Turtle source

The canonical source for the semantic graph lives at
[`data/rdf/zkp.ttl`](https://github.com/lambdasistemi/zk-lab/blob/main/data/rdf/zkp.ttl).
The graph-browser auto-discovers it through
[`data/config.json`](https://github.com/lambdasistemi/zk-lab/blob/main/data/config.json);
chapter-filtered views live in
[`data/queries.json`](https://github.com/lambdasistemi/zk-lab/blob/main/data/queries.json)
as SPARQL queries tagged as views.

## Working with the file

- **Standard ontologies only** — `rdf`, `rdfs`, `owl`, `skos`,
  `dcterms`, `foaf`, `prov`, `bibo`. Custom terms land under
  `zkp:` and are kept minimal; prefer reuse.
- **Every chapter is a `skos:ConceptScheme`.** A node's membership
  is asserted via `skos:inScheme ch:<Chapter>`. This is what the
  chapter filters key on.
- **Every citation resolves.** Every node that points to a paper,
  person, or institution carries a `foaf:page` with a working URL.
  Unverifiable claims do not make it into the graph.
- **Edges are typed.** Use `zkp:builtOn`, `zkp:dependsOn`,
  `zkp:displacedBy`, `zkp:mitigates`, `zkp:inducedBy`, or a
  standard predicate. Avoid untyped `rdfs:seeAlso` for structural
  relationships.

## Contributing

Adding a node:

1. Give it an IRI under `zkp:`.
2. Type it with `zkp:Concept` (or a subclass).
3. Attach it to exactly one chapter via `skos:inScheme`.
4. Write a `dcterms:description` of 2–4 sentences.
5. Cite: `foaf:page`, and where applicable `dcterms:creator`,
   `dcterms:issued`, `dcterms:title`.
6. If it relates to existing nodes, add typed edges.

The constitution's *"steal, always cite"* principle applies:
borrow freely, but every claim has a source.
