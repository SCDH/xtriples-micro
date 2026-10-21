# XTriples Recipes

This folder collects XTriples configurations files for redundant tasks
required in many projects.

Recipes are XTriples configurations for documents which are not known
at time of writing the recipe. Thus, the best processor for recipes is
the one, that allows you to choose the
[collection](../README.md#collections) independently from the
configuration: [`extract-param-doc.xsl`](../README.md#extract-doc-paramxsl)

```shell
target/bin/xslt.sh \
	-xsl:xsl/extract-param-doc.xsl \
	-s:RECIPE.xml \
	source-uri=MY-COLLECTION \
	is-collection-uri=true
```

## Extracting from TEI-XML

See [`tei`](tei) folder.


# Shaping JSON-LD

You can make nicely shaped JSON files from extracted RDF triples by
[JSON-LD
framing](https://www.w3.org/TR/json-ld11-framing/#framing). You will
find JSON-LD frames and contexts in the recipe folders. 

Suitable tools for getting nicely shaped JSON from a knowlegde graph
include [Apache Jena RIOT](https://jena.apache.org/documentation/io/)
and [Titanium JSON-LD](https://github.com/filip26/ld-cli).

1. cancatenate the triples extracted with the XTriples recipes
   ```shell
   cat *.n3 > knowledge-graph.n3
   ```
2. convert the resulting knowledge graph from NTriples to JSON-LD using Apache Jena
   ```shell
   java -cp=... jena.riot --out=JSONLD knowledge-graph.n3 > knowledge-graph.json
   ```
3. frame the resulting JSON-LD to the desired JSON using Titanium JSON-LD
   ```shell
   ld-cli frame --input=file:$(realpath knowledge-graph.json) --pretty --explicit file:$(realpath FRAME.jsonld) 
   ```
