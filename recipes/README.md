# XTriples Recipes

This folder collects XTriples configurations files for redundant tasks
required in many projects.

## Extracting from TEI-XML

### Named Entities

- `recepies/tei/lincs-entities.xml`: extracts [LINCS
  annotations](https://lincsproject.ca/docs/explore-lod/understand-lincs-data/application-profiles-main/sources-metadatag)
  from from TEI. This generates n-triples for every named entity
  encoded with elements <persName>, <placeName>, <eventName>,
  <orgName>, or <rs> and linked with `@ref`. The value of `@ref` is
  used as entity URI. If URIs point to a local registry file, use an
  additional recipe to extract triples from it describing these
  entities. ![LINCS Class
  Diagram](https://lincsproject.ca/assets/images/application-profile-sources-annotation-(c-LINCS)-2ac3c9df793f833fa710f30aad8c2378.png)

