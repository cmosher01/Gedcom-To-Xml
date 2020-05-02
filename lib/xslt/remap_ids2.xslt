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
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:lines="https://mosher.mine.nu/xmlns/lines"
    xmlns:hier="https://mosher.mine.nu/xmlns/hier"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>



    <xsl:variable name="idfile" as="document-node()" select="fn:head(fn:tail(collection()))"/>

    <xsl:key name="mapIds" match="gedcom:id" use="@gedcom:id"/>

    <xsl:function name="gedcom:mapId" as="xs:ID">
        <xsl:param name="gedcomId" as="xs:string"/>
        <xsl:sequence select="xs:ID(fn:key('mapIds', $gedcomId, $idfile)/@xml:id)"/>
    </xsl:function>

    <xsl:function name="gedcom:mapPtr" as="xs:anyURI">
        <xsl:param name="gedcomPtr" as="xs:string"/>
        <xsl:sequence select="xs:anyURI(fn:concat('#', fn:key('mapIds', $gedcomPtr, $idfile)/@xml:id))"/>
    </xsl:function>




     <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gedcom:node[@gedcom:id]">
        <xsl:copy>
            <xsl:variable name="xml-id" select="gedcom:mapId(@gedcom:id)"/>
            <xsl:if test="$xml-id != ''">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="$xml-id"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="gedcom:value[@gedcom:ptr]">
        <xsl:copy>
            <xsl:variable name="xlink-href" select="gedcom:mapPtr(@gedcom:ptr)"/>
            <xsl:if test="$xlink-href != '#'">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="$xlink-href"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
