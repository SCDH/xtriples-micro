<?xml version="1.0" encoding="UTF-8"?>
<!-- Extract Triples from the source document based on the configuration passed in as parameter

The output format is NTriples
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtriples="https://xtriples.lod.academy/"
    exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="text"/>

    <xsl:import href="xtriples.xsl"/>

    <xsl:param name="config-uri" as="xs:string" required="true"/>

    <xsl:param name="config" as="node()" select="doc($config-uri)"/>


    <xsl:mode name="eval-xtriples" on-no-match="deep-skip"/>

    <xsl:template match="document-node()">
        <xsl:call-template name="xtriples:extract">
            <xsl:with-param name="config" select="$config"/>
            <xsl:with-param name="resource" select="."/>
            <xsl:with-param name="resource-index" select="1"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
