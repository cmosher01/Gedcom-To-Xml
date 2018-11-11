<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:lines="https://mosher.mine.nu/xmlns/lines"
    xmlns:hier="https://mosher.mine.nu/xmlns/hier"
>

    <xsl:output
        method="xml"
        version="1.1"
        omit-xml-declaration="no"
        encoding="UTF-8"
        indent="yes"
        standalone="no"
        doctype-public="+//IDN mosher.mine.nu//DTD hier 1.0//EN"
        doctype-system="https://mosher.mine.nu/dtd/hier.dtd"
        cdata-section-elements="hier:value"
    />

    <xsl:key
        name="child-by-parent"
        match="hier:node"
        use="fn:generate-id(preceding-sibling::*[(./@hier:level) &lt; (current()/@hier:level)][1])"
    />

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="hier:root">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="hier:node[@hier:level = 0]"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="hier:node">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="hier:value">
                <xsl:value-of select="."/>
            </xsl:element>
            <xsl:apply-templates select="fn:key('child-by-parent', fn:generate-id())"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
