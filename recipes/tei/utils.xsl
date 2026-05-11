<?xml version="1.0" encoding="UTF-8"?>
<!-- Utility functions for use with TEI-XML

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://scdh.uni-muenster.de/xtriples/utils/"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:param name="context-length" as="xs:integer" select="5"/>

    <xsl:param name="project-directory-url" as="xs:string" select="'file:'"/>


    <xsl:function name="utils:relative-path" as="xs:string" visibility="public">
        <xsl:param name="abs-path" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($abs-path, $project-directory-url)">
                <xsl:value-of
                    select="substring($abs-path, string-length($project-directory-url) + 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$abs-path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="utils:prefix" as="xs:string" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="pre-nodes" as="node()*"
            select="outermost($context/(preceding::text() | preceding::*)[ancestor::text])"/>
        <xsl:variable name="pre-text">
            <xsl:apply-templates mode="text" select="$pre-nodes"/>
        </xsl:variable>
        <xsl:variable name="pre-words" as="xs:string*"
            select="$pre-nodes => string-join() => normalize-space() => tokenize()"/>
        <xsl:variable name="limit" as="xs:integer" select="count($pre-words) - $context-length"/>
        <xsl:sequence
            select="($pre-words[position() gt $limit]) => string-join(' ') => utils:escape()"/>
    </xsl:function>

    <xsl:function name="utils:suffix" as="xs:string" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="context-nodes" as="node()*"
            select="outermost($context/(following::text() | preceding::*)[ancestor::text])"/>
        <xsl:variable name="context-text">
            <xsl:apply-templates mode="text" select="$context-nodes"/>
        </xsl:variable>
        <xsl:variable name="context-words" as="xs:string*"
            select="$context-nodes => string-join() => normalize-space() => tokenize()"/>
        <xsl:variable name="limit" as="xs:integer" select="$context-length"/>
        <xsl:sequence
            select="($context-words[position() le $limit]) => string-join(' ') => utils:escape()"/>
    </xsl:function>

    <xsl:function name="utils:escape" as="xs:string">
        <xsl:param name="content" as="xs:string*"/>
        <xsl:value-of select="string-join(($content)) => replace('&quot;', '&amp;quot;')"/>
    </xsl:function>


    <xsl:mode name="text" on-no-match="shallow-skip"/>

    <xsl:template mode="text" match="text()">
        <xsl:sequence select="."/>
    </xsl:template>

    <xsl:template mode="text" match="app/*"/>

    <xsl:template mode="text" match="app/lem[//variantEncoding/@method eq 'parallel-segmenation']">
        <xsl:apply-templates mode="text" select="node()"/>
    </xsl:template>

    <xsl:template mode="text" match="note"/>

    <xsl:template mode="text" match="comment() | processing-instruction() | attribute()"/>



</xsl:stylesheet>
