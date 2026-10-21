# XTriples Recipes for Extracting from TEI-XML

## Customization

Two strategies for making the recipes customizable are used: 

- [XPath Functions in Utility
  Libraries](../../customization.md#customization): The function
  library [`recipes/tei/utils.xsl`](tei/utils.xsl) adds function which
  some optional features of the following recipes require. The library
  can be replaced by your
  [customization](../../customization.md#customization). Usage:
  ```shell
  target/bin/xslt.sh ... libraries=$(realpath recipes/tei/utils.xsl)
  ```
- [*XInclude + XML Catalog* customization
  strategy](../../customization.md#customization): The recipes include
  from `local.xml`.

## JSON-LD

You can make nicely shaped JSON files from extracted RDF triples by
[JSON-LD
framing](https://www.w3.org/TR/json-ld11-framing/#framing). There are
JSON-LD frames in the `frames` folder.

- `frames/map.jsonld`: make a JSON file for representing an edition on
  a geographic map (OSM etc.). This is shapes triples extracted from a
  places file and from linked places throughout the edition which go
  into a concordance of place mentions, and into a set of links for
  jumping into the edition. See extraction recipes for [named
  entities](#named-entities) below!

Suitable [JSON-LD
context](https://www.w3.org/TR/json-ld11/#the-context) files are
located in the `context` folder. They are also made available via
gitlab pages. See also: [suitable
tools](../README.md#shaping-json-ld).

# Recipes

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
[LINCS'
annotations](https://portal.lincsproject.ca/docs/explore-lod/understand-lincs-data/application-profiles-main/sources-metadata#annotations)
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
Diagram](https://portal.lincsproject.ca/img/documentation/application-profile-sources-annotation-(c-LINCS).png)

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


## DTS

The DTS recipes allow for customizing the URIs of DTS Resources by
optionally providing unary XPath functions to the XTriples processor:

1. `dts:id($context as node())` is preferred over
2. `utils:relative-path($context as node())` (implemented in
   [`recipes/tei/utils.xsl`](tei/utils.xsl)), which is again preferred
   over
3. the default, which just uses the absolute file URI.

The recipes help generating the
[collection.json](https://github.com/SCDH/seed-xc/blob/main/doc/dts-records.md#collectionjson)
file required for [SEED
DTS](https://github.com/SCDH/seed-xc/tree/main/dts). Note, that in
contrast to DTS Resources which are targeted by the following recipes,
DTS collections are not represented by TEI-XML files.

### Recipes for Resources

The following recipes for information on DTS Resources are
modular. Probably, you will need all of them and have to concatenated
the results.

#### `recipes/tei/dts-basic.xml`

for [basic
properties](https://dtsapi.org/specifications/versions/v1.0/#scheme-for-collection-api-responses)
like `@type` and `title`

#### `recipes/tei/dts-citation-trees.xml`

for [citation tree objects](https://dtsapi.org/specifications/versions/v1.0/#scheme-for-collection-api-responses) like required for the resources in the collection endpoint

#### `recipes/tei/dts-dcterms-template.xml`

for making the [DCTerms metadata](https://dtsapi.org/specifications/versions/v1.0/#scheme-for-collection-api-responses) object

This is only a TEMPLATE, but may help you getting started.

#### `recipes/tei/dts-seed-path.xml`

for making the `seed:location` objects as required for the SEED DTS
[collection.json](https://github.com/SCDH/seed-xc/blob/main/doc/dts-records.md#collectionjson)
file

#### `recipes/tei/dts-extensions-template.xml`

for making the [extensions](https://dtsapi.org/specifications/versions/v1.0/#scheme-for-collection-api-responses) object

This is only a TEMPLATE, but may help you getting started.

### Recipes for the Top Level Collection

#### `recipes/tei/dts-general-template.xml`

This is only a TEMPLATE and needs your additions.

### Recipes for Collection Structures

The following recipes for structuring DTS Collections are rather
mutually exclusive.

#### `recipes/tei/dts-collection-flat.xml`

All resources are contained in the top level collection.

This is only a TEMPLATE, and needs your additions.
