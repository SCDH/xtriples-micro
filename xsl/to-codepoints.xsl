<?xml version="1.0" encoding="UTF-8"?>
<!-- Make a JSON array of integers representing the codepoints of the file given as $input parameter

The output format is JSON
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:xtriples="https://xtriples.lod.academy/" xmlns:bin="http://expath.org/ns/binary"
    exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="json"/>

    <xsl:param name="input" as="xs:string" required="true"/>

    <xsl:template name="xsl:initial-template">
        <xsl:sequence select="array {unparsed-text($input) => string-to-codepoints()}"/>
    </xsl:template>

</xsl:stylesheet>
