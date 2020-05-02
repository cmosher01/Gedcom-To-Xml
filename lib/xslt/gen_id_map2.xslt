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
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>

    <xsl:template match="gedcom:nodes[.//gedcom:node/@gedcom:id-valid = 'false']">
        <xsl:element name="gedcom:ids">
            <xsl:apply-templates select=".//gedcom:node" mode="generate-ids"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gedcom:node" mode="generate-ids">
        <xsl:if test="fn:count(@gedcom:id) != 0">
            <xsl:element name="gedcom:id">
                <xsl:attribute name="gedcom:id">
                    <xsl:value-of select="@gedcom:id"/>
                </xsl:attribute>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="fn:generate-id()"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gedcom:nodes">
        <xsl:element name="gedcom:ids">
            <xsl:apply-templates select=".//gedcom:node"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gedcom:node">
        <xsl:if test="fn:count(@gedcom:id) != 0">
            <xsl:element name="gedcom:id">
                <xsl:attribute name="gedcom:id">
                    <xsl:value-of select="@gedcom:id"/>
                </xsl:attribute>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="@gedcom:id"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
