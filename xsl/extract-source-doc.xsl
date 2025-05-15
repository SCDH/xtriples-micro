<?xml version="1.0" encoding="UTF-8"?>
<!-- Extract Triples from the source document based on the configuration passed in as parameter

The output format is NTriples
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtriples="https://xtriples.lod.academy/"
    xmlns:bin="http://expath.org/ns/binary" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="text"/>

    <xsl:import href="xtriples.xsl"/>

    <xsl:param name="config-uri" as="xs:string?" select="()"/>

    <xsl:param name="config-b64" as="xs:base64Binary?" select="()"/>


    <xsl:variable name="config" as="document-node()">
        <xsl:choose>
            <xsl:when test="$config-uri">
                <xsl:sequence select="doc($config-uri)"/>
            </xsl:when>
            <xsl:when test="exists($config-b64) and not(function-available('bin:decode-string', 1))">
                <xsl:message terminate="yes">
                    <xsl:text>decoding of base64 encoded strings not available</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:when test="exists($config-b64)"
                use-when="function-available('bin:decode-string', 1)">
                <xsl:sequence select="bin:decode-string($config-b64) => parse-xml()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="true">
                    <xsl:text>either $config-uri or $config-b64 must be provided</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>



    <xsl:mode name="eval-xtriples" on-no-match="deep-skip"/>

    <xsl:template match="document-node()">
        <xsl:call-template name="xtriples:extract">
            <xsl:with-param name="config" select="$config"/>
            <xsl:with-param name="resource" select="."/>
            <xsl:with-param name="resource-index" select="1"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
