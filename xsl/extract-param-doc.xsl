<?xml version="1.0" encoding="UTF-8"?>
<!-- Extract Triples based on the configuration passed in as source from document passed in as parameter

The output format is NTriples
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtriples="https://xtriples.lod.academy/"
    exclude-result-prefixes="#all" version="3.0" default-mode="eval-xtriples">

    <xsl:output method="text"/>

    <xsl:import href="xtriples.xsl"/>

    <xsl:param name="source-uri" as="xs:string" required="true"/>

    <xsl:param name="source" as="node()" select="doc($source-uri)"/>


    <xsl:mode name="eval-xtriples" on-no-match="deep-skip"/>

    <xsl:global-context-item as="document-node(element(xtriples))" use="required"/>

    <xsl:template mode="eval-xtriples" match="document-node(element(xtriples))">
        <xsl:call-template name="xtriples:extract">
            <xsl:with-param name="config" select="."/>
            <xsl:with-param name="resource" select="$source"/>
            <xsl:with-param name="resource-index" select="1"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
