# XTriples Recipes

This folder collects XTriples configurations files for redundant tasks
required in many projects.

Recipes can best be run like so:

```shell
target/bin/xslt.sh \
	-xsl:xsl/extract-param-doc.xsl \
	-s:RECIPE.xml \
	source-uri=/path/to/MY-COLLECTION.xml \
	is-collection-uri=true
```

## Extracting from TEI-XML

### Named Entities

#### `recipes/tei/lincs-entities.xml`

```shell
target/bin/xslt.sh \
	-xsl:xsl/extract-param-doc.xsl \
	-s:recipes/tei/lincs-entities.xml \
	source-uri=/path/to/MY-COLLECTION.xml \
	is-collection-uri=true \
	libraries=$(realpath recipes/tei/utils.xsl)
```

[`recipes/tei/lincs-entities.xml`](tei/lincs-entities.xml) extracts
[LINCS
annotations](https://lincsproject.ca/docs/explore-lod/understand-lincs-data/application-profiles-main/sources-metadatag)
from from TEI. It generates a structure of RDF statements for every
named entity encoded with elements `<persName>`, `<placeName>`,
`<eventName>`, `<orgName>`, or `<rs>` and linked with `@ref`. The
statements represent and [Web
Annotation](https://www.w3.org/TR/annotation-model/#selectors) for
every occurrence of such elements.

The value of `@ref` is used as entity URI. If URIs point to a local
registry file, use an additional recipe to extract triples from it
describing these entities.

Here's the LINCS class diagram: ![LINCS Class
Diagram](https://lincsproject.ca/assets/images/application-profile-sources-annotation-(c-LINCS)-2ac3c9df793f833fa710f30aad8c2378.png)

When functions of [`recipes/tei/utils.xsl`](#utils) are available, the
recipe
- adds additional `oa:prefix` and `oa:suffix` context to the exact quote
- turns absolute file paths to relative paths


#### Utils

The function library [`recipes/tei/utils.xsl`](tei/utils.xsl)
adds functions some optional features of the following recipes
require. Usage:

```shell
target/bin/xslt.sh ... libraries=$(realpath recipes/tei/utils.xsl)
```
