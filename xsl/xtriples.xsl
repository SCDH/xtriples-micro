<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT is the workhorse of this XTriples implementation.

The output format is NTriples.

This is only a module and should be imported by some calling stylesheet.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xtriples="https://xtriples.lod.academy/" exclude-result-prefixes="#all" version="3.0">

    <xsl:mode name="statement" on-no-match="fail"/>

    <!-- We collect all data from subject, predicate, object
         and tunnel the intermediate result, so we have subject
         and predicate when we reach the object. -->
    <xsl:template mode="statement" match="statement">
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"/>
        <xsl:variable name="statements" as="xs:string*">
            <xsl:apply-templates mode="statement" select="subject"/>
        </xsl:variable>
        <!-- amount of statements for output is determined by @repeat -->
        <xsl:choose>
            <xsl:when test="not(@repeat)">
                <xsl:sequence select="$statements"/>
            </xsl:when>
            <xsl:when test="substring(@repeat, 1, 1) eq '/'">
                <!-- @repeat is an XPath expression -->
                <xsl:variable name="repeat" as="xs:integer">
                    <xsl:evaluate as="xs:integer" with-params="$xpath-params"
                        context-item="map:get($xpath-params, xs:QName('currentResource'))"
                        xpath="substring(@repeat, 2)"/>
                </xsl:variable>
                <xsl:sequence select="$statements[position() le $repeat]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="repeat" as="xs:integer" select="xs:integer(@repeat)"/>
                <xsl:sequence select="$statements[position() le $repeat]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="statement" match="subject">
        <xsl:param name="vocabularies" as="element(vocabularies)" tunnel="true"/>
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"/>
        <xsl:variable name="stmt" select="parent::statement"/>
        <xsl:message>subject</xsl:message>
        <xsl:for-each select="xtriples:part-to-rdf(., $vocabularies, $xpath-params)">
            <xsl:message>subject</xsl:message>
            <xsl:apply-templates mode="statement" select="$stmt/predicate">
                <xsl:with-param name="subject" as="item()" tunnel="true" select="."/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>


    <xsl:template mode="statement" match="predicate">
        <xsl:param name="vocabularies" as="element(vocabularies)" tunnel="true"/>
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"/>
        <xsl:variable name="stmt" select="parent::statement"/>
        <xsl:message>predicate</xsl:message>
        <xsl:for-each select="xtriples:part-to-rdf(., $vocabularies, $xpath-params)">
            <xsl:apply-templates mode="statement" select="$stmt/object">
                <xsl:with-param name="predicate" as="item()" tunnel="true" select="."/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="statement" match="object" as="item()+">
        <xsl:param name="subject" as="item()" tunnel="true"/>
        <xsl:param name="predicate" as="item()" tunnel="true"/>
        <xsl:param name="vocabularies" as="element(vocabularies)" tunnel="true"/>
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"/>
        <xsl:variable name="context" select="."/>
        <xsl:variable name="stmt" select="parent::statement"/>
        <xsl:message>object</xsl:message>
        <xsl:for-each select="xtriples:part-to-rdf(., $vocabularies, $xpath-params)">
            <xsl:value-of select="$subject"/>
            <xsl:value-of select="$predicate"/>
            <xsl:choose>
                <xsl:when test="$context/@type eq 'literal'">
                    <xsl:value-of>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>"</xsl:text>
                    </xsl:value-of>
                </xsl:when>
            </xsl:choose>
            <xsl:text> .&#xa;</xsl:text>
        </xsl:for-each>
    </xsl:template>


    <xsl:function name="xtriples:part-to-rdf">
        <xsl:param name="part" as="element()"/>
        <xsl:param name="vocabularies" as="element(vocabularies)"/>
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)"/>
        <xsl:variable name="xs" as="item()*">
            <xsl:choose>
                <xsl:when test="substring($part, 1, 1) eq '/'">
                    <xsl:message>xpath</xsl:message>
                    <xsl:choose>
                        <xsl:when test="$part/@resource and doc-available($part/@resource)">
                            <xsl:message>evaluating in context of external resource</xsl:message>
                            <xsl:variable name="resource" as="document-node()"
                                select="doc($part/@resource)"/>
                            <!-- the external resource must be passed as XPath context
                                and as an advanced configuation variable -->
                            <xsl:evaluate as="item()*"
                                with-params="map:merge($xpath-params, map:entry(xs:QName('externalResource'), $resource))"
                                context-item="$resource" xpath="substring($part, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message>
                                <xsl:text>evaluating xpath: </xsl:text>
                                <xsl:value-of select="substring($part, 2)"/>
                            </xsl:message>

                            <xsl:evaluate as="item()*" with-params="$xpath-params"
                                context-item="map:get($xpath-params, xs:QName('currentResource'))"
                                xpath="substring($part, 2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$part"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$xs">
            <xsl:variable name="x" select="."/>
            <xsl:choose>
                <xsl:when
                    test="$part[self::subject and not(@type)] or $part[self::predicate] or $part/@type eq 'uri'">
                    <xsl:choose>
                        <xsl:when test="$part/@prefix">
                            <xsl:variable name="prefix" as="xs:string" select="$part/@prefix"/>
                            <xsl:sequence
                                select="xs:anyURI($vocabularies/vocabulary[@prefix eq $prefix]/@uri || $x)"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="uri-parts" as="xs:string+">
                                <xsl:if test="$part/@prepend">
                                    <xsl:sequence select="$part/@prepend"/>
                                </xsl:if>
                                <xsl:value-of select="$x"/>
                                <xsl:if test="$part/@append">
                                    <xsl:sequence select="$part/@append"/>
                                </xsl:if>
                            </xsl:variable>
                            <xsl:sequence select="string-join($uri-parts) => xs:anyURI()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$part/@type eq 'literal'">
                    <xsl:value-of select="$x"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

</xsl:stylesheet>
