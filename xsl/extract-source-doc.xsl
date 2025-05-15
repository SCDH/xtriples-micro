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
        <xsl:call-template name="extract"/>
    </xsl:template>

    <xsl:template name="extract">
        <xsl:context-item as="document-node()" use="required"/>
        <!-- evaluate /xtriples/collection/resource TODO: specs are unclear! -->
        <xsl:variable name="collection" as="node()*">
            <xsl:choose>
                <xsl:when
                    test="matches($config/xtriples/collection/resource/@uri, '^\{') and matches($config/xtriples/collection/resource/@uri, '\}$')">
                    <xsl:variable name="resource-xpath" as="xs:string"
                        select="$config/xtriples/collection/resource/@uri => replace('^\{', '') => replace('\}$', '')"/>
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>xpath for resource </xsl:text>
                        <xsl:value-of select="$resource-xpath"/>
                    </xsl:message>
                    <xsl:evaluate as="node()*" context-item="." xpath="$resource-xpath"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- generate context variables for the advanced configuration -->
        <xsl:variable name="xpath-params" as="map(xs:QName, item()*)" select="
                map {
                    xs:QName('currentResource'): $collection,
                    xs:QName('resourceIndex'): 1
                }"/>
        <xsl:apply-templates mode="statement"
            select="$config/xtriples/configuration/triples/statement">
            <xsl:with-param name="vocabularies" as="element(vocabularies)" tunnel="true"
                select="$config/xtriples/configuration/vocabularies"/>
            <xsl:with-param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"
                select="$xpath-params"/>
        </xsl:apply-templates>
    </xsl:template>

</xsl:stylesheet>
