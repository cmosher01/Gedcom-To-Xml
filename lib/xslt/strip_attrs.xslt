<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gedcom:nodes">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gedcom:node">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@gedcom:tag"/>
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gedcom:value">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@xlink:href"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
