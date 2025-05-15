<?xml version="1.0" encoding="UTF-8"?>
<!-- Make SEED runtime parameters from the xtriples configuration pass in as $input parameter

The output format is JSON
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="json"/>

    <xsl:param name="input" as="xs:string" required="true"/>

    <xsl:template name="xsl:initial-template">
        <xsl:map>
            <xsl:map-entry key="'globalParameters'">
                <xsl:map>
                    <xsl:map-entry key="'config-codepoints'">
                        <xsl:sequence
                            select="array {unparsed-text($input) => string-to-codepoints()}"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
        </xsl:map>
    </xsl:template>

</xsl:stylesheet>
