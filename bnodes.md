# BNodes

Handling of [RDF Blank Nodes](https://www.w3.org/TR/n-triples/#BNodes)
aka BNodes may be a bit intricate. However, there are some tricks to
get things done:

1. Use the variable `$resourceIndex` to add a distinguishing name
   part per processed resource. E.g., `<object
   type="bnode">/concat('title-', $resourceIndex)</object>`.

1. Consider carefully about concatenating the NTriples output of
   several runs. If you concatenate NTriples, changes are, that BNode
   names overlap. There may be situations, where you want to exploit
   this.

1. Instead, when you want to avoid such an overlap, then feed your
   NTriples to a native RDF processor like Apache Jena first. It will
   randomize your BNode names. Concatenate after this randomization
   step if overlaps would lead to semantic errors.
