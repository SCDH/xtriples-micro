<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT module provides components for evaluating <collection>.

This is only a module and should be imported by some calling stylesheet.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xtriples="https://xtriples.lod.academy/" xmlns:err="http://www.w3.org/2005/xqt-errors"
    exclude-result-prefixes="#all" version="3.0">


    <xsl:function name="xtriples:resources">
        <!-- evaluate /xtriples/collection/resource -->
        <xsl:param name="collection" as="element(collection)?"/>
        <xsl:param name="document" as="document-node()"/>
        <xsl:choose>
            <xsl:when
                test="matches($collection/resource/@uri, '^\{') and matches($collection/resource/@uri, '\}$')">
                <xsl:variable name="resource-xpath" as="xs:string"
                    select="$collection/resource/@uri => replace('^\{', '') => replace('\}$', '')"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>xpath for resource </xsl:text>
                    <xsl:value-of select="$resource-xpath"/>
                </xsl:message>
                <xsl:evaluate as="node()*" context-item="$document" xpath="$resource-xpath"
                    namespace-context="xtriples:namespaces($collection/ancestor::xtriples)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$document"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>




</xsl:stylesheet>
