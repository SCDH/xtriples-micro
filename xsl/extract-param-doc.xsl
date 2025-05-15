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

    <xsl:template mode="eval-xtriples" match="document-node(element(xtriples))">
        <!-- evaluate /xtriples/collection/resource TODO: specs are unclear! -->
        <xsl:variable name="collection" as="node()*">
            <xsl:choose>
                <xsl:when
                    test="matches(/xtriples/collection/resource/@uri, '^\{') and matches(/xtriples/collection/resource/@uri, '\}$')">
                    <xsl:variable name="resource-xpath" as="xs:string"
                        select="/xtriples/collection/resource/@uri => replace('^\{', '') => replace('\}$', '')"/>
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>xpath for resource </xsl:text>
                        <xsl:value-of select="$resource-xpath"/>
                    </xsl:message>
                    <xsl:evaluate as="node()*" context-item="$source" xpath="$resource-xpath"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$source"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="xpath-params" as="map(xs:QName, item()*)" select="
                map {
                    xs:QName('currentResource'): $collection,
                    xs:QName('resourceIndex'): 1
                }"/>
        <xsl:apply-templates mode="statement" select="/xtriples/configuration/triples/statement">
            <xsl:with-param name="vocabularies" as="element(vocabularies)" tunnel="true"
                select="/xtriples/configuration/vocabularies"/>
            <!-- generate context variables for the advanced configuration -->
            <xsl:with-param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"
                select="$xpath-params"/>
        </xsl:apply-templates>
    </xsl:template>

</xsl:stylesheet>
