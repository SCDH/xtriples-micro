# Change Log

## 0.5.1

- fix issue #2: testing for number literals in `statement/@repeat`
  that are lower 1

## 0.5.0

- allows to use own functions in XPath expressions in the
  `<configuration>` section

## 0.4.1

- fixes a bug when processing a `<collection>` with a Saxon URI
  collection and no unnesting of resources from `resource/@uri`

## 0.4.0

- make `<condition>` work
- make `@repeat` on `<statement>` work and provide `$repeatIndex`
  variable
- support `@datatype` attribute on `<object>`
- fix handling of boolean condition in `<statement>`
- `<collection>`
  - support link based resource crawling
  - support literal resource crawling
  - introduce stylesheet parameter `is-collection-uri`
	- set it to `false` for getting full compatibility collection evaluation
	- when set to `false`, *XPath based resource crawling with
      resources spread over multiple files* is supported
- fix document type association for oxygen framework

## 0.3.1

- make default namespace work, and there by extending the reference
  implementation, see [README](readme.md#implementation-of-the-specs).

## 0.3.0

- support namespaces

## 0.2.1

- fix how XPath expressions are evaluated
- support bnodes
- systematic testing with examples from original processor

## 0.2.0

- implements evaluation of `<collection>` in
  `xsl/extract-collection.xsl`
- evaluate `collection/@max` correctly
- fix `$resourceIndex` variable
- Oxygen framework
  - add transformation scenarion for extracting from collection of XML
    sources
  - add catalog that redirects to local schema

## 0.1.0

Initial release with

- implementation of specs in XSLT, except
  - bnodes
  - `object/@datatype`
  - processing of `<collection>` still unclear
- SEED package
- Oxygen framework
  - transformation scenarios
  - validation scenarios
  - schema
  - templates
