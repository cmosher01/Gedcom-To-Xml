<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:lines="https://mosher.mine.nu/xmlns/lines"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>

    <xsl:param name="filename" as="xs:string"/>
    <xsl:param name="base-dir" select="fn:static-base-uri()"/>
    <xsl:param name="encoding" as="xs:string" select="'UTF-8'"/>

    <xsl:template name="xsl:initial-template">
        <xsl:element name="lines:lines">
            <xsl:for-each select="fn:tokenize(fn:unparsed-text(fn:resolve-uri($filename, $base-dir), $encoding), '\r|\n|\r\n')">
                <xsl:if test="fn:string-length(.) != 0">
                    <xsl:element name="lines:line">
                        <xsl:attribute name="lines:seq">
                            <xsl:sequence select="fn:position()"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
