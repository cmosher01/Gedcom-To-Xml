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

    <xsl:param name="reLevel" static="true" as="xs:string" select="'^\s*(\d+)(.*?)$'"/>



    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="lines:lines">
        <xsl:element name="hier:root">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="lines:line">
        <xsl:element name="hier:node">
            <xsl:apply-templates select="@*"/>
            <xsl:analyze-string select="./node()" regex="{$reLevel}">
                <xsl:matching-substring>
                    <xsl:attribute name="hier:level">
                        <xsl:sequence select="xs:nonNegativeInteger(fn:regex-group(1))"/>
                    </xsl:attribute>
                    <xsl:element name="hier:value">
                        <xsl:sequence select="fn:regex-group(2)"/>
                    </xsl:element>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:attribute name="hier:invalid">
                        <xsl:sequence select="fn:true()"/>
                    </xsl:attribute>
                    <xsl:element name="hier:value">
                        <xsl:sequence select="."/>
                    </xsl:element>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
