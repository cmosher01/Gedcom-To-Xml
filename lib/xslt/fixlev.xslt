<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:lines="https://mosher.mine.nu/xmlns/lines"
    xmlns:hier="https://mosher.mine.nu/xmlns/hier"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="hier:node[following-sibling::*[1]/@hier:invalid = 'true']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="hier:value">
                <xsl:variable name="r" select="following-sibling::*[@hier:invalid = 'true'] intersect following-sibling::*[not(@hier:invalid = 'true')][1]/preceding-sibling::*"/>
                <xsl:sequence select="fn:concat(hier:value/text(), '&#x0A;', fn:string-join($r, '&#x0A;'))"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="hier:node[@hier:invalid = 'true']" priority="1"/>
</xsl:stylesheet>
