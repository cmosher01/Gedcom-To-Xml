<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
    Gedcom-To-Xml
    Converts GEDCOM file to XML format.

    Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->
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
