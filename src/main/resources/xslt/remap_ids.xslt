<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xlink="http://www.w3.org/1999/xlink"
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



    <xsl:param name="idfile" as="document-node()"/>

    <xsl:key name="mapIds" match="gedcom:id" use="@gedcom:id"/>

    <xsl:function name="gedcom:mapId" as="xs:ID">
        <xsl:param name="gedcomId" as="xs:string"/>
        <xsl:sequence select="xs:ID(fn:key('mapIds', $gedcomId, $idfile)/@xml:id)"/>
    </xsl:function>

    <xsl:function name="gedcom:mapPtr" as="xs:anyURI">
        <xsl:param name="gedcomPtr" as="xs:string"/>
        <xsl:sequence select="xs:anyURI(fn:concat('#',fn:key('mapIds', $gedcomPtr, $idfile)/@xml:id))"/>
    </xsl:function>



    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gedcom:value[@gedcom:id|@gedcom:ptr]">
        <xsl:copy>
            <xsl:if test="@gedcom:id">
                <xsl:variable name="xml-id" select="gedcom:mapId(@gedcom:id)"/>
                <xsl:if test="$xml-id != ''">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="$xml-id"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>

            <xsl:if test="@gedcom:ptr">
                <xsl:variable name="xlink-href" select="gedcom:mapPtr(@gedcom:ptr)"/>
                <xsl:if test="$xlink-href != '#'">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="$xlink-href"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>

            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
