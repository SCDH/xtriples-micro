<?xml version="1.0" encoding="UTF-8"?>
<!-- Extract Triples based on the configuration passed in as source

The output format is NTriples
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtriples="https://xtriples.lod.academy/"
    exclude-result-prefixes="#all" version="3.0" default-mode="eval-xtriples">

    <xsl:output method="text"/>

    <xsl:import href="xtriples.xsl"/>


    <xsl:global-context-item as="document-node(element(xtriples))" use="required"/>

    <xsl:mode name="eval-xtriples" on-no-match="deep-skip"/>

    <xsl:template mode="eval-xtriples" match="document-node(element(xtriples))">
        <xsl:variable name="config" select="."/>
        <!-- there may be multiple collection elements -->
        <xsl:for-each select="/xtriples/collection">
            <xsl:variable name="collection" as="element(collection)" select="."/>
            <xsl:variable name="collection-uri" as="xs:anyURI"
                select="$collection/@uri => resolve-uri(base-uri(.))"/>
            <xsl:message>
                <xsl:text>extracting from collection </xsl:text>
                <xsl:value-of select="$collection-uri"/>
            </xsl:message>
            <xsl:for-each
                select="($collection-uri => collection()) ! xtriples:resources($collection, .)">
                <!-- take only @max resources (not documents) -->
                <xsl:if test="not($collection/@max) or (position() le xs:integer($collection/@max))">
                    <xsl:variable name="statements" as="xs:string*">
                        <xsl:call-template name="xtriples:extract">
                            <xsl:with-param name="config" select="$config"/>
                            <xsl:with-param name="resource" select="."/>
                            <xsl:with-param name="resource-index" select="position()"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="xtriples:serialize($statements)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
