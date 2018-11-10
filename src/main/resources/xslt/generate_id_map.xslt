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
        doctype-public="+//IDN mosher.mine.nu//DTD gedcom ids 1.0//EN"
        doctype-system="https://mosher.mine.nu/dtd/gedcom/ids.dtd"
    />

    <xsl:param name="remap" as="xs:boolean" select="fn:false()"/>

    <xsl:template match="gedcom:nodes">
        <xsl:element name="gedcom:ids">
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gedcom:value">
        <xsl:if test="fn:count(@gedcom:id) != 0">
            <xsl:element name="gedcom:id">
                <xsl:attribute name="gedcom:id">
                    <xsl:value-of select="@gedcom:id"/>
                </xsl:attribute>
                <xsl:attribute name="xml:id">
                    <xsl:choose>
                        <xsl:when test="$remap">
                            <xsl:value-of select="fn:generate-id()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@gedcom:id"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
