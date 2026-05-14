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


## Customization

There are strategies for making recipes **customizable**, i.e.,
providing them in a way so that it is possible to use them without
touching their code but also to adapt them for your special
requirements at the same time.

- [XInclude and XML Catalog](#xinclude-and-xml-catalog)
- [XPath Functions in Utility Libraries](#xpath-functions-in-utility-libraries)
- [Named Entity Resolution](#named-entity-resolution)

### XInclude and XML Catalog

The XInclude strategy allows to replace an element of an XTriples XML
configuration file by an other customized element. It uses
`<xi:include>` and `<xi:fallback>` elements of the
[XInclude](https://en.wikipedia.org/wiki/XInclude)
[spec](https://www.w3.org/TR/xinclude/).

#### Example

```xml
<xtriples xmlns:xi="http://www.w3.org/2001/XInclude">
  <configuration>
    <xi:include href="local-vocabularies.xml" xpointer="vocabularies">
      <xi:fallback>
        <vocabularies>
          <vocabulary prefix="prs" uri="http://edition.com/entities/person#"/>
          <vocabulary prefix="plc" uri="http://edition.com/entities/place#"/>
          <vocabulary prefix="org" uri="http://edition.com/entities/org#"/>
          <vocabulary prefix="evt" uri="http://edition.com/entities/event#"/>
        </vocabularies>
      </xi:fallback>
    </xi:include>
    <vocabularies>
      <vocabulary prefix="crm" uri="http://www.cidoc-crm.org/cidoc-crm/"/>
	  <!-- ... fixed vocabularies ... -->
    </vocabularies>
    <triples>
	  <!-- ... statements ... -->
	</triples>
  </configuration>
  <!-- ... collection ... -->
</xtriples>
```

This makes the namespace-bindings of the prefixes `prs`, `plc`, `org`,
and `evt` customizable. They are defined in a fallback element of an
XInclude element. An XInclude-aware XML-Parser must try to replace the
`<xi:include>` element with an element with the ID `vocabularies` in
the file `local-vocabularies.xml`. Only if this file or element is not
found, it will replace the `<xi:include>` with the contents of the
`<xi:fallback>` element. Thus: the four vocabularies in the fallback
are the default prefix bindings, but they are customizable.

In addition, you do not have to provide the `local-vocabularies.xml`
directly, i.e., you do not have to provide a file with the relative
path `./local-vocabularies.xml`, but you can use an [XML
Catalog](https://www.oasis-open.org/committees/entity/spec-2001-08-06.html)
to rewrite this path (SystemID or URI). The following XML catalog file
redirects any URIs or file paths ending with `local-vocabularies.xml`
to a file named `myvoc.xml` **relative to the catalog file**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE catalog PUBLIC "-//OASIS//DTD Entity Resolution XML Catalog V1.1//EN" "http://www.oasis-open.org/committees/entity/release/1.1/catalog.dtd">
<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">

  <!-- rewrites any URIs and paths ending with local-vocabularies.xml to myvoc.xml -->
  <systemSuffix systemIdSuffix="local-vocabularies.xml" uri="myvoc.xml"/>
  <uriSuffix uriSuffix="local-vocabularies.xml" uri="myvoc.xml"/>

</catalog>
```

Note: `mvvoc.xml` is a path relative to the catalog file. It may
contain this customized prefix binding:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xtriples [
   <!ATTLIST vocabularies xml:id ID #IMPLIED>
   <!ATTLIST subject xml:id ID #IMPLIED>
]>
<?xml-model href="../../schema/xtriples.rng"?>
<xtriples>
    <configuration>
        <vocabularies xml:id="vocabularies">
            <vocabulary prefix="ent" uri="http://liederhandschrift.uni-heidelberg.de/entitaeten/"/>
            <vocabulary prefix="prs" uri="http://liederhandschrift.uni-heidelberg.de/entitaeten/person#"/>
            <vocabulary prefix="plc" uri="http://liederhandschrift.uni-heidelberg.de/entitaeten/place#"/>
            <vocabulary prefix="org" uri="http://liederhandschrift.uni-heidelberg.de/entitaeten/org#"/>
            <vocabulary prefix="evt" uri="http://liederhandschrift.uni-heidelberg.de/entitaeten/event#"/>
            <vocabulary prefix="typ" uri="http://liederhandschrift.uni-heidelberg.de/entitaeten/type#"/>
        </vocabularies>
    </configuration>
</xtriples>
```

Note the `DOCTYPE` fragment. It's old-fashioned, but it allows
XInclude-aware parsers like Xerces to find the element with the
`xml:id` vocabularies. Xerces does not evaluate `xml:id` as an ID, nor
does it recognise schema-based IDs, but [only DTD-based
IDs](https://xerces.apache.org/xerces2-j/faq-xinclude.html).

Using this *XInclude + XML Catalog* strategy requires you to switch on
XInclude-processing for the XSLT processor (`-xi` switch) and
providing it with an XML catalog (`-catalog` parameter):

```shell
target/bin/xslt.sh \
	-xsl:xsl/extract-param-doc.xsl \
	-s:RECIPE.xml \
	source-uri=MY-COLLECTION \
	is-collection-uri=true \
	-xi \
	-catalog:my-catalog.xml
```

### XPath Functions in Utility Libraries

A recipe can call an XPath function from the non-standard namespace
(`fn`) which is defined in a utility library. Since the utility
library is only linked when running the extraction process, it can be
replaced with a customized implementation.

#### Example

This statement uses the `utils:prefix` XPath function, that takes one
argument:

```xml
<statement>
  <condition>/exists(function-lookup(xs:QName('utils:prefix'), 1))</condition>
  <subject type="bnode">/concat('quote', $resourceIndex)</subject>
  <predicate prefix="oa">prefix</predicate>
  <object type="literal">/utils:prefix(.)</object>
</statement>
```

Because it would be best practice for generic recipes, to work even
when a non-standard utility function is not available, the statement
is only produced when [looking up the
function](https://www.saxonica.com/documentation12/index.html#!functions/fn/function-lookup)
succeeds. Note, that `fn:function-available(...)` [is **not**
available when processing XPath
expressions](https://www.w3.org/TR/xpath-functions-30/) from XTriples.

Providing the library with your implementation is done with the
`libraries` (or `libraries-csv`) static stylesheet parameter, which
takes an absolute path (or a path relative to the stylesheet):

```shell
target/bin/xslt.sh \
	-xsl:xsl/extract-param-doc.xsl \
	-s:recipes/tei/lincs-entities.xml \
	source-uri=MY-COLLECTION \
	is-collection-uri=true \
	libraries=$(realpath ../myutils.xsl)
```

This example uses [`realpath`](https://linux.die.net/man/1/realpath)
for making an absolute path from a relative path.

### Named Entity Resolution

This again uses a native XML technology for making a recipe
customizable: [named
entities](https://www.w3.org/TR/xml/#sec-references).

#### Example

```xml
<statement>
  <subject type="bnode">/concat('quote', $resourceIndex)</subject>
  <predicate prefix="oa">prefix</predicate>
  <object type="literal">&prefix;</object>
</statement>
```

You can then have [entity
declarations](https://www.w3.org/TR/xml/#sec-entity-decl) like
`<!ENTITY prefix "/my super elaborated XPath expression">` either
internally or in an external file.

This technique is super powerful, but we haven't used it so far. It
works as long as your XML processing environment is not hobbled by
security restrictions.
