# An XTriples Processor for Micro Services and Local Usage

This is an implementation of a [XTriples](https://xtriples.lod.academy/)
processor that works without an eXist-db.

XTriples? In XTriples, instead of writing specialized programs in
XSLT, XQuery, Python, etc. for extracting RDF triples from XML
documents, we write configuration files containing selectors. These
config files are evaluated by an XTriples processor, which returns RDF
triples. Here's an example of such a configuration file:

```
<?xml-model uri="https://xtriples.lod.academy/xtriples.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<xtriples>
    <configuration>
        <vocabularies>
            <vocabulary prefix="gods" uri="https://xtriples.lod.academy/examples/gods/"/>
            <vocabulary prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
            <vocabulary prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>
            <vocabulary prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
        </vocabularies>
        <triples>
            <statement>
                <subject prefix="gods">/@id</subject>
                <predicate prefix="rdf">type</predicate>
                <object prefix="foaf" type="uri">Person</object>
            </statement>
            <statement>
                <subject prefix="gods">/@id</subject>
                <predicate prefix="rdfs">label</predicate>
                <object type="literal" lang="en">/name/english</object>
            </statement>
            <statement>
                <subject prefix="gods">/@id</subject>
                <predicate prefix="rdfs">label</predicate>
                <object type="literal" lang="gr">/name/greek</object>
            </statement>
            <statement>
                <subject prefix="gods">/@id</subject>
                <predicate prefix="rdfs">seeAlso</predicate>
                <object type="uri">/concat("http://en.wikipedia.org/wiki/", $currentResource/name/english)</object>
            </statement>
        </triples>
    </configuration>
    <collection uri="https://xtriples.lod.academy/examples/gods/all.xml">
	   ...
    </collection>
</xtriples>
```

While the original XTriples processor requires an eXist database and
applies a configuration only on the fixed set of XML files contained
in it, the implementation at hand runs outside of a database, e.g., on
a local set of documents. It can also be deployed on the famous SEED
XML Transformer. This deployment gives you a lightweight microservice,
where you can send a single XML document and a config file to and get
RDF triples in return.

## Getting started

### Microservice

TODO

### Oxygen

This project offers an Oxygen framework, that assists writing XTriples
configuration files and also provides transformation scenarios for
applying a configuration to a single or a collection of
documents. Installation is as simple as using the following
installation link in the installation dialog found in **Help** ->
**Install New Addons**:

```
https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/xtriples-micro/descriptor.xml
```

There are als transformation scenarios in
[`xtriples.scenarios`](xtriples.scenarios) for extracting triples from
your currently visited source file edited with any other
framework. You can [import these
scenarios](https://www.oxygenxml.com/doc/versions/27.1/ug-editor/topics/import-export-global-scenarios.html)
to your project.

### Command Line

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

The following section about the transformations for extracting RDF
triples with XTriple configurations always provides examples of local
usage.

## Extracting RDF Triples

There are XSLT stylesheets, that do the work of evaluating an XTriples
configuration file and applying it to XML documents.

### `extract`

[`xsl/extract.xsl`](xsl/extract.xsl) extracts
from an XML document given as source by applying a configuration
passed in via the stylesheet parameter `config-uri`.


```shell
target/bin/xslt.sh -xsl:xsl/extract.xsl -s:test/gods/1.xml config-uri=$(realpath test/gods/configuration.xml)
```

The output should look like this:

```ntriples
<https://xtriples.lod.academy/examples/gods/1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://xmlns.com/foaf/0.1/Person>  .
<https://xtriples.lod.academy/examples/gods/1> <http://www.w3.org/2000/01/rdf-schema#label> "Aphrodite"@en  .
<https://xtriples.lod.academy/examples/gods/1> <http://www.w3.org/2000/01/rdf-schema#label> "Ἀφροδίτη"@gr  .
<https://xtriples.lod.academy/examples/gods/1> <http://www.w3.org/2000/01/rdf-schema#seeAlso> <http://en.wikipedia.org/wiki/Aphrodite>  .
```

If you your result is polluted with debug messages, you can append `2>
/dev/null` to silence them. They are printed to stderr.

#### Passing the configuration, not a URI

There are situations, where it is simpler to pass the configuration as
a string to the stylesheet instead of providing a URI. E.g., when the
stylesheets are deployed on a web service, it would be inconvenient,
to first put the configuration at some aceissible location, where the
service can get it from. The stylesheets therefore provide some means
of passing the configuration directly

Unfortunately, passing the configuration as a XML string to a
stylesheet parameter does not work due to escaping problems. So we
need some kind of encoding/decoding mechanism.


##### base64 encoded string

The cleanest solution is passing the configuration as a base64 encoded
string using the `config-b64` stylesheet parameter:

```shell
target/bin/xslt.sh -xsl:xsl/extract.xsl -s:$(realpath test/gods/1.xml) config-b64=$(cat test/gods/configuration.xml.b64)
```

Or without an intermediate base64 file:

```shell
target/bin/xslt.sh -xsl:xsl/extract.xsl -s:$(realpath test/gods/1.xml) config-b64=$(base64 -w 0 test/gods/configuration.xml)
```


Probably, you will get an error message `decoding of base64 encoded
strings not available`, because the because the function
[`bin:decode-string`](https://www.saxonica.com/documentation12/index.html#!functions/expath-binary/decode-string)
from the binary extension package is not available on Saxon-HE.



##### array of codepoints

When decoding base64 encoded files using
[`bin:decode-string`](https://www.saxonica.com/documentation12/index.html#!functions/expath-binary/decode-string)
is not an option, because the binary EXPath package is not available,
then passing the configuration as an array of integers representing
unicode codepoints is the resort. You can pass such an array to the
`config-codepoints` stylesheet parameter. Note the `?` in front of the
parameter `?config-codepoints=...`, that makes Saxon interpret the
value as an XPath expression.

```shell
target/bin/xslt.sh -xsl:xsl/extract.xsl -s:$(realpath test/gods/1.xml) ?config-codepoints=$(cat test/gods/configuration.xml.json)
```

You generate such an array of codepoints using the
`xsl/to-codepoints.xsl` stylesheet:

```
target/bin/xslt.sh -xsl:xsl/to-codepoints.xsl -it input=$(realpath test/gods/configuration.xml)
```


### `extract-doc-param.xsl`

[`xsl/extract-doc-param.xsl`](xsl/extract-doc-param.xsl) takes a
configuration as source document and applies it to an XML document
referenced by the `source-uri` stylesheet parameter.

```shell
target/bin/xslt.sh -xsl:xsl/extract-param-doc.xsl -s:test/gods/configuration.xml source-uri=$(realpath test/gods/1.xml)
```

The output should look like this:

```ntriples
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
