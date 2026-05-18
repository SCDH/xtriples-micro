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
