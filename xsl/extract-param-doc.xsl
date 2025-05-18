<?xml version="1.0" encoding="UTF-8"?>
<!-- Extract Triples based on the configuration passed in as source from document passed in as parameter

The output format is NTriples
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtriples="https://xtriples.lod.academy/"
    exclude-result-prefixes="#all" version="3.0" default-mode="eval-xtriples">

    <xsl:output method="text"/>

    <xsl:import href="xtriples.xsl"/>
    <xsl:import href="collection.xsl"/>

    <xsl:param name="source-uri" as="xs:string" required="true"/>

    <xsl:param name="source" as="node()" select="doc($source-uri)"/>


    <xsl:mode name="eval-xtriples" on-no-match="deep-skip"/>

    <xsl:global-context-item as="document-node(element(xtriples))" use="required"/>

    <xsl:template mode="eval-xtriples" match="document-node(element(xtriples))">
        <xsl:variable name="config" select="."/>
        <!--
            The extraction has to be applied to each resource unnested from the document.
            Albeit this stylesheet ignores <collection>, the first resource/@uri is evaluated.
        -->
        <xsl:variable name="statements" as="xs:string*">
            <xsl:for-each select="xtriples:resources(/xtriples, $source)">
                <xsl:call-template name="xtriples:extract">
                    <xsl:with-param name="config" select="$config"/>
                    <!-- albeit this stylesheet ignores <collection>, the first resource/@uri is evaluated -->
                    <xsl:with-param name="resource" select="."/>
                    <xsl:with-param name="resource-index" select="position()"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="xtriples:serialize($statements)"/>
    </xsl:template>

</xsl:stylesheet>
