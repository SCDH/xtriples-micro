<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT module provides components for evaluating <vocabularies>.

This is only a module and should be imported by some calling stylesheet.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtriples="https://xtriples.lod.academy/"
    exclude-result-prefixes="#all" version="3.0">

    <!--
        Returns an element which carries all the namespace declarations
        from the <vocabularies> section of the XTriples configuration.

        The element can be used to set the namespaces for XPath
        processing with <xsl:evaluate>.
    -->
    <xsl:function name="xtriples:namespaces" as="node()">
        <xsl:param name="config" as="element(xtriples)"/>
        <xsl:choose>
            <xsl:when test="
                    every $v in $config/configuration/vocabularies/vocabulary
                        satisfies $v/@prefix and $v/@prefix ne ''">
                <xsl:element name="namespaces" namespace="">
                    <!-- add some namespaces known by default -->
                    <xsl:if
                        test="not($config/configuration/vocabularies/vocabulary[@prefix = 'xs'])">
                        <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
                    </xsl:if>
                    <!-- add namespaces from vocabularies -->
                    <xsl:for-each select="$config/configuration/vocabularies/vocabulary">
                        <xsl:namespace name="{@prefix}" select="@uri"/>
                        <xsl:message use-when="system-property('debug') eq 'true'">
                            <xsl:text>add namespace declaration </xsl:text>
                            <xsl:value-of select="@prefix"/>
                            <xsl:text>=</xsl:text>
                            <xsl:value-of select="@uri"/>
                        </xsl:message>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="default" as="element(vocabulary)*"
                    select="$config/configuration/vocabularies/vocabulary[not(@prefix) or @prefix eq '']"/>
                <xsl:if test="$default[position() gt 1]">
                    <xsl:message>
                        <xsl:text>Configuration error: multiple vocabularies with the default prefix!</xsl:text>
                    </xsl:message>
                </xsl:if>
                <xsl:element name="namespaces" namespace="{$default[1]/@uri}">
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>default namespace: </xsl:text>
                        <xsl:value-of select="$default[1]/@uri"/>
                    </xsl:message>
                    <!-- add some namespaces known by default -->
                    <xsl:if
                        test="not($config/configuration/vocabularies/vocabulary[@prefix = 'xs'])">
                        <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
                    </xsl:if>
                    <!-- add namespaces from vocabularies -->
                    <xsl:for-each
                        select="$config/configuration/vocabularies/vocabulary except $default">
                        <xsl:namespace name="{@prefix}" select="@uri"/>
                        <xsl:message use-when="system-property('debug') eq 'true'">
                            <xsl:text>add namespace declaration </xsl:text>
                            <xsl:value-of select="@prefix"/>
                            <xsl:text>=</xsl:text>
                            <xsl:value-of select="@uri"/>
                        </xsl:message>
                    </xsl:for-each>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
