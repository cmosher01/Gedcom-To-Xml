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
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>

    <xsl:param name="filename" as="xs:string"/>
    <xsl:param name="base-dir" select="fn:static-base-uri()"/>
    <xsl:param name="encoding" as="xs:string" select="'UTF-8'"/>

    <xsl:template name="xsl:initial-template">
        <xsl:element name="lines:lines">
            <xsl:for-each select="fn:tokenize(fn:unparsed-text(fn:resolve-uri($filename, $base-dir), $encoding), '\r|\n|\r\n')">
                <xsl:if test="fn:string-length(.) != 0">
                    <xsl:element name="lines:line">
                        <xsl:attribute name="lines:seq">
                            <xsl:sequence select="fn:position()"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
