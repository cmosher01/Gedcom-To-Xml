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
            <xsl:variable name="val">
                <xsl:value-of select="./node()"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="./node()">
                    <xsl:analyze-string select="$val" regex="{$reLevel}">
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
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="hier:invalid">
                        <xsl:sequence select="fn:true()"/>
                    </xsl:attribute>
                    <xsl:element name="hier:value">
                        <xsl:sequence select="''"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
