<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output
        method="xml"
        version="1.1"
        omit-xml-declaration="no"
        encoding="UTF-8"
        standalone="no"
        doctype-public="+//IDN mosher.mine.nu//DTD gedcom nodes 1.0//EN"
        doctype-system="https://mosher.mine.nu/dtd/gedcom/nodes.dtd"
        cdata-section-elements="gedcom:value"
    />



    <xsl:function name="gedcom:validId" as="xs:string">
        <xsl:param name="candidateId" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="fn:matches($candidateId, '^[_A-Za-z][_A-Za-z0-9]*$', 's')">
                <xsl:value-of select="$candidateId"/>
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
            <xsl:if test="fn:count(@gedcom:id) > 0 and fn:string-length(gedcom:validId(@gedcom:id)) = 0">
                <xsl:attribute name="id-type">
                    <xsl:value-of select="'mapped'"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
