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

    <xsl:template match="hier:root">
        <xsl:element name="gedcom:nodes">
            <xsl:namespace name="lines" select="'https://mosher.mine.nu/xmlns/lines'"/>
            <xsl:namespace name="hier" select="'https://mosher.mine.nu/xmlns/hier'"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
<!--
    <xsl:template match="hier:node">
        <xsl:element name="gedcom:node">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="hier:value">
        <xsl:choose>
            <xsl:when test="fn:count(./text()) != 0">
                <xsl:analyze-string select="gedcom:maskDoubleAts(./text())" regex="^\s*(@[^@]*@?)?(?:\s*(\S+)\s?(.*))?$" flags="s">
                    <xsl:matching-substring>
                        <xsl:element name="gedcom:value">
                            <xsl:variable name="id">
                                <xsl:value-of select="gedcom:restoreAts(gedcom:extractId(fn:regex-group(1)))"/>
                            </xsl:variable>
                            <xsl:if test="fn:string-length($id) != 0">
                                <xsl:attribute name="gedcom:id">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                                <xsl:attribute name="gedcom:id-valid">
                                    <xsl:value-of select="fn:matches($id, '^[A-Za-z][A-Za-z0-9]*$')"/>
                                </xsl:attribute>
                            </xsl:if>

                            <xsl:variable name="tag">
                                <xsl:value-of select="gedcom:restoreAts(fn:regex-group(2))"/>
                            </xsl:variable>
                            <xsl:if test="fn:string-length($tag) != 0">
                                <xsl:attribute name="gedcom:tag">
                                    <xsl:value-of select="$tag"/>
                                </xsl:attribute>
                            </xsl:if>


***************
                            <xsl:variable name="ptr">
                                <xsl:value-of select="gedcom:restoreAts(gedcom:extractId(fn:regex-group(3)))"/>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="fn:string-length($ptr) != 0">
                                    <xsl:attribute name="gedcom:ptr">
                                        <xsl:value-of select="$ptr"/>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
***************
                                     <xsl:value-of select="gedcom:restoreAts(fn:regex-group(3))"/>
***************
                                 </xsl:otherwise>
                            </xsl:choose>
***************
                        </xsl:element>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="gedcom:value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

-->
    <xsl:template match="hier:value"/>

    <xsl:template match="hier:node">
        <xsl:element name="gedcom:node">
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="fn:count(hier:value/text()) != 0">
                    <xsl:analyze-string select="gedcom:maskDoubleAts(hier:value/text())" regex="^\s*(@[^@]*@?)?(?:\s*(\S+)\s?(.*))?$" flags="s">
                        <xsl:matching-substring>
                            <xsl:variable name="id">
                                <xsl:value-of select="gedcom:restoreAts(gedcom:extractId(fn:regex-group(1)))"/>
                            </xsl:variable>
                            <xsl:if test="fn:string-length($id) != 0">
                                <xsl:attribute name="gedcom:id">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                                <xsl:attribute name="gedcom:id-valid">
                                    <xsl:value-of select="fn:matches($id, '^[A-Za-z][A-Za-z0-9]*$')"/>
                                </xsl:attribute>
                            </xsl:if>

                            <xsl:variable name="tag">
                                <xsl:value-of select="gedcom:restoreAts(fn:regex-group(2))"/>
                            </xsl:variable>
                            <xsl:if test="fn:string-length($tag) != 0">
                                <xsl:attribute name="gedcom:tag">
                                    <xsl:value-of select="$tag"/>
                                </xsl:attribute>
                            </xsl:if>

                            <xsl:element name="gedcom:value">
                                <xsl:value-of select="gedcom:restoreAts(fn:regex-group(3))"/>
                            </xsl:element>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:element name="gedcom:value"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>



</xsl:stylesheet>
