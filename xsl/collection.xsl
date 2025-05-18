<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT module provides components for evaluating <collection>.

This is only a module and should be imported by some calling stylesheet.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xtriples="https://xtriples.lod.academy/" xmlns:err="http://www.w3.org/2005/xqt-errors"
    exclude-result-prefixes="#all" version="3.0">

    <xsl:import href="vocabularies.xsl"/>

    <!-- Whether collection/@uri is to be evaluated as a Saxon collection URI. Otherwise read as ordinary XML document. -->
    <xsl:param name="is-collection-uri" as="xs:boolean" select="true()"/>

    <!--
        entry point: Returns a sequence of resources
        for a given config by evaluating the <collection>
        elements.

        This is to be used, when no XML source document is
        passed to the XML processor, but the <collection>
        tags in the configuration determine the XML sources.
    -->
    <xsl:function name="xtriples:resources" as="node()*" visibility="public">
        <xsl:param name="config" as="element(xtriples)"/>
        <xsl:apply-templates mode="resources" select="$config/collection">
            <xsl:with-param name="namespaces" as="node()" tunnel="true"
                select="xtriples:namespaces($config)"/>
        </xsl:apply-templates>
    </xsl:function>

    <!--
        entry point: Returns a sequence of resources
        for a given document. Therefore, the first collection
        with "XPATH based resource crawling with resources
        all in one single file" is evaluated.

        This is used when the source document is passed to the
        processor.
    -->
    <xsl:function name="xtriples:resources" visibility="public">
        <xsl:param name="config" as="element(xtriples)?"/>
        <xsl:param name="document" as="document-node()"/>
        <xsl:variable name="collection" as="element(collection)?"
            select="($config/collection[@uri])[1]"/>
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
                    namespace-context="xtriples:namespaces($config)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$document"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- INTERNALS -->


    <!-- mode resources is used to process collection tags
        to make resources -->
    <xsl:mode name="resources" on-no-match="deep-skip"/>

    <xsl:template mode="resources" match="collection[not(@uri)]">
        <xsl:apply-templates mode="resources" select="resource"/>
    </xsl:template>

    <!-- Link based resource crawling with fixed resources in the configuration file -->
    <xsl:template mode="resources" match="resource[@uri]">
        <xsl:variable name="uri" select="resolve-uri(@uri, base-uri(.))"/>
        <xsl:try>
            <xsl:sequence select="doc($uri)"/>
            <xsl:catch>
                <xsl:message>
                    <xsl:text>Failed to parse file </xsl:text>
                    <xsl:value-of select="@uri"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="$uri"/>
                    <xsl:text>): ERROR </xsl:text>
                    <xsl:value-of select="$err:code"/>
                    <xsl:text>&#xa;</xsl:text>
                    <xsl:value-of select="$err:description"/>
                </xsl:message>
            </xsl:catch>
        </xsl:try>
    </xsl:template>

    <!-- Literal resource crawling with XML resources -->
    <xsl:template mode="resources" match="resource[not(@uri)]">
        <xsl:copy-of select="element()"/>
    </xsl:template>

    <!-- a collection from a Saxon URI collection -->
    <xsl:template mode="resources" match="collection[@uri]">
        <xsl:variable name="collection" as="element(collection)" select="."/>
        <xsl:variable name="collection-uri" as="xs:anyURI"
            select="$collection/@uri => resolve-uri(base-uri(.))"/>
        <xsl:variable name="resources" as="node()*">
            <xsl:choose>
                <xsl:when test="$is-collection-uri and not(resource)">
                    <!-- done. Every document in the collection is a resource -->
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>extracting from collection </xsl:text>
                        <xsl:value-of select="$collection-uri"/>
                    </xsl:message>
                    <xsl:sequence select="$collection-uri => collection()"/>
                </xsl:when>
                <xsl:when test="$is-collection-uri">
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>unnesting resources from collection </xsl:text>
                        <xsl:value-of select="$collection-uri"/>
                    </xsl:message>
                    <xsl:apply-templates mode="collection" select="resource">
                        <xsl:with-param name="collection" as="document-node()*"
                            select="$collection-uri => collection()" tunnel="true"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="not($is-collection-uri) and not(resource)">
                    <!-- done. Document is a resource -->
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>extracting from document </xsl:text>
                        <xsl:value-of select="$collection-uri"/>
                    </xsl:message>
                    <xsl:sequence select="$collection-uri => doc()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>unnesting resources from document </xsl:text>
                        <xsl:value-of select="$collection-uri"/>
                    </xsl:message>
                    <xsl:apply-templates mode="collection" select="resource">
                        <xsl:with-param name="collection" as="document-node()*"
                            select="$collection-uri => doc()" tunnel="true"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!--  if @max present: return only the resources 1 .. @max -->
            <xsl:when test="@max">
                <xsl:sequence select="$resources[position() le xs:integer(@max)]"/>
            </xsl:when>
            <!-- otherwise: return all resources -->
            <xsl:otherwise>
                <xsl:sequence select="$resources"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- mode collection is used to process resources of a Saxon URI collection -->
    <xsl:mode name="collection" on-no-match="deep-skip"/>

    <!-- XPATH based resource crawling with resources all in one single file -->
    <xsl:template mode="collection" match="resource[xtriples:is-node-extractor(@uri)]" as="node()*"
        priority="10">
        <xsl:param name="collection" as="document-node()*" tunnel="true"/>
        <xsl:param name="namespaces" as="node()" tunnel="true"/>
        <xsl:variable name="resource-xpath" as="xs:string"
            select="@uri => replace('^\{', '') => replace('\}$', '')"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>xpath for unnesting resources </xsl:text>
            <xsl:value-of select="$resource-xpath"/>
        </xsl:message>
        <!-- evaluate resource xpath on each document in the collection -->
        <xsl:for-each select="$collection">
            <xsl:evaluate as="node()*" context-item="." xpath="$resource-xpath"
                namespace-context="$namespaces"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="collection" match="resource[@uri]">
        <xsl:message terminate="yes">
            <xsl:text>XPATH based resource crawling with resources spread over multiple files</xsl:text>
            <xsl:text> IS NOT SUPPORTED</xsl:text>
        </xsl:message>
    </xsl:template>

    <!-- return true for uri="{//god}" or similar -->
    <xsl:function name="xtriples:is-node-extractor" as="xs:boolean">
        <xsl:param name="uri" as="attribute(uri)"/>
        <xsl:sequence select="matches($uri, '^\{') and matches($uri, '\}$')"/>
    </xsl:function>

</xsl:stylesheet>
