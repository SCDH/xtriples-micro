# Change Log

## dev

- make `<condition>` work

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
