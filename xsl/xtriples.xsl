<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT is the workhorse of this XTriples implementation.

The output format is NTriples.

This is only a module and should be imported by some calling stylesheet.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xtriples="https://xtriples.lod.academy/" xmlns:err="http://www.w3.org/2005/xqt-errors"
    exclude-result-prefixes="#all" version="3.0">

    <xsl:variable name="xtriples:fullstop" as="xs:string" select="'.'"/>


    <xsl:template name="xtriples:extract">
        <xsl:param name="config" as="document-node(element(xtriples))"/>
        <xsl:param name="resource" as="node()"/>
        <xsl:param name="resource-index" as="xs:integer"/>
        <!-- generate context variables for the advanced configuration -->
        <xsl:variable name="xpath-params" as="map(xs:QName, item()*)" select="
                map {
                    xs:QName('currentResource'): $resource,
                    xs:QName('resourceIndex'): $resource-index
                }"/>
        <xsl:apply-templates mode="statement"
            select="$config/xtriples/configuration/triples/statement">
            <xsl:with-param name="vocabularies" as="element(vocabularies)" tunnel="true"
                select="$config/xtriples/configuration/vocabularies"/>
            <xsl:with-param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"
                select="$xpath-params"/>
            <xsl:with-param name="namespaces" as="node()"
                select="xtriples:namespaces($config/xtriples)" tunnel="true"/>
        </xsl:apply-templates>
    </xsl:template>

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


    <xsl:mode name="statement" on-no-match="fail"/>

    <!-- We collect all data from subject, predicate, object
         and tunnel the intermediate result, so we have subject
         and predicate when we reach the object. -->
    <xsl:template mode="statement" match="statement" as="xs:string*">
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"/>
        <xsl:param name="namespaces" as="node()" tunnel="true"/>
        <xsl:variable name="context" as="element(statement)" select="."/>
        <xsl:variable name="condition" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="not(condition)">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- we wrap the XPath in xs:boolean( ... ) -->
                    <xsl:evaluate as="xs:boolean"
                        context-item="map:get($xpath-params, xs:QName('currentResource'))"
                        with-params="$xpath-params" xpath="concat('$currentResource', condition)"
                        namespace-context="$namespaces"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$condition">
            <xsl:choose>
                <xsl:when test="xs:integer(@repeat) lt 1"/>
                <xsl:when test="not(@repeat)">
                    <xsl:apply-templates mode="statement" select="subject"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="repetitions" as="xs:integer">
                        <xsl:choose>
                            <xsl:when test="substring(@repeat, 1, 1) eq '/'">
                                <xsl:evaluate as="xs:integer" with-params="$xpath-params"
                                    context-item="map:get($xpath-params, xs:QName('currentResource'))"
                                    xpath="concat('$currentResource', @repeat)"
                                    namespace-context="$namespaces"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="xs:integer(@repeat)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:for-each select="1 to $repetitions">
                        <xsl:apply-templates mode="statement" select="$context/subject">
                            <xsl:with-param name="xpath-params" as="map(xs:QName, item()*)"
                                tunnel="true"
                                select="map:put($xpath-params, xs:QName('repeatIndex'), position())"
                            />
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:function name="xtriples:all-true" as="xs:boolean">
        <xsl:param name="values" as="xs:boolean*"/>
        <xsl:choose>
            <xsl:when test="empty($values)">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="
                        fold-left(($values), true(), function ($acc, $x) {
                            $acc and $x
                        })"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template mode="statement" match="subject">
        <xsl:param name="vocabularies" as="element(vocabularies)" tunnel="true"/>
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"/>
        <xsl:param name="namespaces" as="node()" tunnel="true"/>
        <xsl:variable name="stmt" select="parent::statement"/>
        <xsl:for-each select="xtriples:part-to-rdf(., $vocabularies, $xpath-params, $namespaces)">
            <xsl:message use-when="system-property('debug') eq 'true'">subject</xsl:message>
            <xsl:apply-templates mode="statement" select="$stmt/predicate">
                <xsl:with-param name="subject" as="item()" tunnel="true" select="."/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>


    <xsl:template mode="statement" match="predicate">
        <xsl:param name="vocabularies" as="element(vocabularies)" tunnel="true"/>
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"/>
        <xsl:param name="namespaces" as="node()" tunnel="true"/>
        <xsl:variable name="stmt" select="parent::statement"/>
        <xsl:for-each select="xtriples:part-to-rdf(., $vocabularies, $xpath-params, $namespaces)">
            <xsl:message use-when="system-property('debug') eq 'true'">predicate</xsl:message>
            <xsl:apply-templates mode="statement" select="$stmt/object">
                <xsl:with-param name="predicate" as="item()" tunnel="true" select="."/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="statement" match="object">
        <xsl:param name="subject" as="item()" tunnel="true"/>
        <xsl:param name="predicate" as="item()" tunnel="true"/>
        <xsl:param name="vocabularies" as="element(vocabularies)" tunnel="true"/>
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)" tunnel="true"/>
        <xsl:param name="namespaces" as="node()" tunnel="true"/>
        <xsl:variable name="context" select="."/>
        <xsl:variable name="stmt" select="parent::statement"/>
        <xsl:for-each select="xtriples:part-to-rdf(., $vocabularies, $xpath-params, $namespaces)">
            <xsl:message use-when="system-property('debug') eq 'true'">object</xsl:message>
            <xsl:value-of select="$subject"/>
            <xsl:value-of select="$predicate"/>
            <xsl:value-of select="."/>
            <xsl:value-of select="$xtriples:fullstop"/>
        </xsl:for-each>
    </xsl:template>


    <xsl:function name="xtriples:part-to-rdf">
        <xsl:param name="part" as="element()"/>
        <xsl:param name="vocabularies" as="element(vocabularies)"/>
        <xsl:param name="xpath-params" as="map(xs:QName, item()*)"/>
        <xsl:param name="namespaces" as="node()"/>
        <xsl:variable name="xs" as="item()*">
            <xsl:choose>
                <xsl:when test="substring($part, 1, 1) eq '/'">
                    <xsl:message use-when="system-property('debug') eq 'true'">xpath</xsl:message>
                    <xsl:choose>
                        <xsl:when test="$part/@resource">
                            <xsl:message use-when="system-property('debug') eq 'true'">
                                <xsl:text>evaluating in context of external resource</xsl:text>
                                <xsl:value-of select="string($part)"/>
                            </xsl:message>
                            <xsl:variable name="resource-uri" as="xs:anyURI"
                                select="resolve-uri($part/@resource, base-uri(map:get($xpath-params, xs:QName('currentResource'))))"/>
                            <xsl:try>
                                <xsl:variable name="resource" as="document-node()"
                                    select="doc($resource-uri)"/>
                                <xsl:variable name="params" as="map(xs:QName, item()*)"
                                    select="map:put($xpath-params, xs:QName('externalResource'), $resource)"/>
                                <!-- the external resource must be passed as XPath context
                                and as an advanced configuation variable -->
                                <xsl:evaluate as="item()*" with-params="$params"
                                    context-item="$resource"
                                    xpath="concat('$externalResource', $part)"
                                    namespace-context="$namespaces"/>
                                <xsl:catch>
                                    <xsl:message terminate="yes">
                                        <xsl:text>Evaluation in the context of external resource </xsl:text>
                                        <xsl:value-of select="$part/@resource"/>
                                        <xsl:text> failed. Absolute resource URI: </xsl:text>
                                        <xsl:value-of select="$resource-uri"/>
                                        <xsl:text>&#xa;ERROR: </xsl:text>
                                        <xsl:value-of select="$err:code"/>
                                        <xsl:text>&#xa;</xsl:text>
                                        <xsl:value-of select="$err:description"/>
                                    </xsl:message>
                                </xsl:catch>
                            </xsl:try>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message use-when="system-property('debug') eq 'true'">
                                <xsl:text>evaluating on current resource xpath: </xsl:text>
                                <xsl:value-of select="string($part)"/>
                            </xsl:message>
                            <xsl:evaluate as="item()*" with-params="$xpath-params"
                                context-item="map:get($xpath-params, xs:QName('currentResource'))"
                                xpath="concat('$currentResource', $part)"
                                namespace-context="$namespaces"/>
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
                    <!-- using xsl:value-of to concatenate multiple values to a single string -->
                    <xsl:value-of>
                        <xsl:text>&lt;</xsl:text>
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
                        <xsl:text>&gt;</xsl:text>
                    </xsl:value-of>
                </xsl:when>
                <xsl:when test="$part/@type eq 'bnode'">
                    <xsl:value-of>
                        <xsl:text>_:</xsl:text>
                        <xsl:value-of select="$x"/>
                    </xsl:value-of>
                </xsl:when>
                <xsl:when test="$part/@type eq 'literal'">
                    <xsl:value-of>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="$x"/>
                        <xsl:text>"</xsl:text>
                        <xsl:choose>
                            <!--
                                In contrast to the spec, we also allow XPath expression
                                in the object/@lang attribute!
                            -->
                            <xsl:when test="substring($part/@lang, 1, 1) eq '/'">
                                <xsl:text>@</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="$part/@resource">
                                        <xsl:variable name="resource" select="doc($part/@resource)"/>
                                        <xsl:evaluate as="xs:string" context-item="$resource"
                                            with-params="map:merge($xpath-params, map:entry(xs:QName('externalResource'), $resource))"
                                            xpath="concat('$externalResource', $part/@lang)"
                                            namespace-context="$namespaces"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:evaluate as="xs:string"
                                            context-item="map:get($xpath-params, xs:QName('currentResource'))"
                                            with-params="$xpath-params"
                                            xpath="concat('$currentResource', $part/@lang)"
                                            namespace-context="$namespaces"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$part/@lang">
                                <xsl:text>@</xsl:text>
                                <xsl:value-of select="$part/@lang"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:value-of>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        <xsl:text>cannot determine node type: </xsl:text>
                        <xsl:value-of select="$part"/>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="xtriples:serialize">
        <xsl:param name="sentence-parts" as="item()*"/>
        <xsl:for-each select="$sentence-parts">
            <xsl:value-of select="."/>
            <xsl:text>&#x20;</xsl:text>
            <xsl:if test=". eq $xtriples:fullstop">
                <xsl:text>&#xa;</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

</xsl:stylesheet>
