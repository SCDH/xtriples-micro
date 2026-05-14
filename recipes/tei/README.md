# XTriples Recipes for Extracting from TEI-XML

## Customization

The function library [`recipes/tei/utils.xsl`](tei/utils.xsl) adds
function which some optional features of the following recipes
require. The library can be replaced by your
[customization](../README.md#customization). Usage:

```shell
target/bin/xslt.sh ... libraries=$(realpath recipes/tei/utils.xsl)
```

The recipes also make use of the [*XInclude + XML Catalog*
customization strategy](../README.md#customization).

## Named Entities

### `recipes/tei/lincs-entities.xml`

```shell
target/bin/xslt.sh \
	-xsl:xsl/extract-param-doc.xsl \
	-s:recipes/tei/lincs-entities.xml \
	source-uri=MY-COLLECTION \
	is-collection-uri=true \
	libraries=$(realpath recipes/tei/utils.xsl)
```

[`recipes/tei/lincs-entities.xml`](tei/lincs-entities.xml) extracts
[LINCS
annotations](https://lincsproject.ca/docs/explore-lod/understand-lincs-data/application-profiles-main/sources-metadatag)
from from TEI. It generates a structure of RDF statements for every
named entity tagged with elements `<persName>`, `<placeName>`,
`<eventName>`, `<orgName>`, or `<rs>` and linked with `@ref`. The
statements represent a CIDOC-CRM-aligned [Web
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



### `recipes/tei/cordh-places.xml`

```shell
target/bin/xslt.sh \
	-xsl:xsl/extract-param-doc.xsl \
	-s:recipes/tei/cordh-places.xml \
	-xi \
	source-uri=MY-EDITION/places.xml
```

[`recipes/tei/cordh-places.xml`](tei/cordh-places.xml) extracts geo
information from a registry of places into the simple CIDOC-CRM-based
[cordh pattern for spatial
coordinates](https://docs.cordh.net/modelling/#spatial-coordinate).

The extracted triples from place entries like this

```xml
<place xml:id="Adams_Peak" type="pow" subtype="pilgrimage_site">
  <placeName><hi rend="ul">Adam's Peak</hi></placeName>
  <location cert="high">
    <geo>6.809444, 80.499722</geo>
  </location>
  <desc type="short">Adam's Peak is a mountain and pilgrimage site in central Sri
  Lanka</desc>
  <idno type="URI" xml:base="https://en.wikipedia.org/wiki/">Adam%27s_Peak</idno>
</place>
```

look like this:

```n-triples
<http://edition.org/places#Adams_Peak> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.cidoc-crm.org/cidoc-crm/E53_Place> . 
<http://edition.org/places#Adams_Peak> <http://www.w3.org/ns/locn#geometry> _:geo11 . 
_:geo11 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2003/01/geo/wgs84_pos#Point> . 
_:geo11 <http://www.w3.org/2003/01/geo/wgs84_pos#lat> "6.809444"^^<http://www.w3.org/2001/XMLSchema#float> . 
_:geo11 <http://www.w3.org/2003/01/geo/wgs84_pos#log> "80.499722"^^<http://www.w3.org/2001/XMLSchema#float> . 
```

The extraction is robust against minor encoding issues like a comma
between the coordinates components.

Open Question: Should lat/long be typed as float or as string? 

The URI for the place is customizable by our [customization
pattern](#customization).


