<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:lines="https://mosher.mine.nu/xmlns/lines"
    xmlns:hier="https://mosher.mine.nu/xmlns/hier"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>



    <xsl:function name="gedcom:maskDoubleAts" as="xs:string">
        <xsl:param name="lineWithDoubleAts" as="xs:string"/>
        <xsl:value-of select="fn:replace($lineWithDoubleAts, '@@', '&#xfffc;')"/>
    </xsl:function>

    <xsl:function name="gedcom:restoreAts" as="xs:string">
        <xsl:param name="lineWithMaskedAts" as="xs:string"/>
        <xsl:value-of select="fn:replace($lineWithMaskedAts, '&#xfffc;', '@')"/>
    </xsl:function>

    <xsl:function name="gedcom:extractId" as="xs:string">
        <xsl:param name="optId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="fn:matches($optId, '^\s*@([^@]+)@?\s*$', 's')">
                <xsl:value-of select="fn:replace($optId, '^\s*@([^@]+)@?\s*$', '$1', 's')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>



    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

        <xsl:template match="gedcom:value">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:if test="fn:count(./text()) != 0">
                    <xsl:variable name="ptr">
                        <xsl:value-of select="gedcom:restoreAts(gedcom:extractId(gedcom:maskDoubleAts(./text())))"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="fn:string-length($ptr) != 0">
                            <xsl:attribute name="gedcom:ptr">
                                <xsl:value-of select="$ptr"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="./text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                 </xsl:if>
            </xsl:copy>
        </xsl:template>
</xsl:stylesheet>
