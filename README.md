# XTriples as a Micro Service

This is an implementation of [XTriples](https://xtriples.lod.academy/)
that works outside of the eXist-db.

When deployed in the famous SEED XML Transformer, it gives you a
lightwight microservice implementation of XTriples, where you can send
a single XML document to and get RDF triples in return. It can also be
run locally using an XSLT processor like Saxon and can then be used to
extract RDF triples from arbitrary collections of XML documents on the
local disk.

## Getting started

### Microservice

TODO

### Running locally

#### Tooling

This project comes with a fully reproducible
[tooling](https://github.com/scdh/tooling) environment that installs
all tools needed for running and testing in a sandbox. You only need a
Java development kit (JDK) installed. On debian-based systems, you can
install it with `sudo apt install openjdk`.

To set up the tooling environment, clone this repository, `cd` into
your working copy and run:

```
./mvnw package  # Linux
```

or

```
mvnw.cmd package   # Windows
```

This will download Saxon-HE etc. and generate wrapper files, that set
up the classpath for using them.

After running the command above, the wrapper scripts are in
`target/bin/`. Here's a wrapper to Saxon-HE:

```
target/bin/xslt.sh -?
```


#### Extracting RDF Triples

There are XSLT stylesheets, that do the work of evaluating an XTriples
configuration file and applying it to XML documents.

##### `xsl/extract-doc-param.xsl`

[`xsl/extract-doc-param.xsl`](xsl/extract-doc-param.xsl) takes a
configuration as source document and applies it to an XML document
referenced by the `source-uri` stylesheet parameter.

```
target/bin/xslt.sh -xsl:xsl/extract-param-doc.xsl -s:test/gods/configuration.xml source-uri=$(realpath test/gods/1.xml)
```

The output should look like this:

```
<https://xtriples.lod.academy/examples/gods/1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person>  .
<https://xtriples.lod.academy/examples/gods/1> <http://www.w3.org/2000/01/rdf-schema#label> "Aphrodite"@en  .
<https://xtriples.lod.academy/examples/gods/1> <http://www.w3.org/2000/01/rdf-schema#label> "Ἀφροδίτη"@gr  .
<https://xtriples.lod.academy/examples/gods/1> <http://www.w3.org/2000/01/rdf-schema#seeAlso> <http://en.wikipedia.org/wiki/Aphrodite>  .
```

## State of implementation

BNodes not yet working!

## Specs

This is a full implementation of the [XTriples
spec](https://xtriples.lod.academy/documentation.html).

In addition to the spec this implementation adds the following
features:

1. In addition to ISO 639 language identifiers, `object/@lang` can also
   evaluate XPath expressions, that return such language
   identifiers. This feature is handy for projects that set up language
   in their XML documents.




## Output: NTriples

There's only one output format: NTriples. In a microservice
architecture, converting to other formats is done in a converter
service. NTriples is the RDF serialization of choice, because the
response bodies of multiple request can simply be concatenated into
one graph.
