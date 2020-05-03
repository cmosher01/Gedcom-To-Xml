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
<p:declare-step
    version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
    <p:input port="parameters" kind="parameter"/>
    <p:input port="source" sequence="true">
        <p:empty/>
    </p:input>

    <p:output port="result"/>
    <p:serialization
        port="result"
        version="1.1"
        indent="true"
        omit-xml-declaration="false"
        standalone="false"
    />



    <p:xslt name="lines-to-xml" template-name="xsl:initial-template">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/toxml.xslt"/>
        </p:input>
    </p:xslt>

     <p:validate-with-xml-schema name="v-lines-to-xml">
        <p:input port="schema">
            <p:document href="lib/xsd/lines.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>



    <p:xslt name="find-level-numbers">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/level.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-xml-schema name="v-find-level-numbers">
        <p:input port="schema">
            <p:document href="lib/xsd/hier.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>



    <p:xslt name="fix-missing-level-numbers">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/fixlev.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-xml-schema name="v-fix-missing-level-numbers">
        <p:input port="schema">
            <p:document href="lib/xsd/hier.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>



    <p:xslt name="generate-hierarchy">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/hier.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-xml-schema name="v-generate-hierarchy">
        <p:input port="schema">
            <p:document href="lib/xsd/hier.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>



    <p:xslt name="parse-gedcom-lines">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/parse_raw_nodes.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-xml-schema name="v-parse-gedcom-lines">
        <p:input port="schema">
            <p:document href="lib/xsd/gedcom.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>



    <p:xslt name="process-cont-conc-lines">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/contconc.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-xml-schema name="v-process-cont-conc-lines">
        <p:input port="schema">
            <p:document href="lib/xsd/gedcom.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>


    <p:xslt name="extract-pointers">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/extract_ptrs.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-xml-schema name="v-extract-pointers">
        <p:input port="schema">
            <p:document href="lib/xsd/gedcom.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>



     <p:xslt name="generate-id-map-or-remap">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/gen_id_map2.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-xml-schema name="v-generate-id-map-or-remap">
        <p:input port="schema">
            <p:document href="lib/xsd/gedcom-ids.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>



    <p:xslt name="remap-ids">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/remap_ids2.xslt"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="v-extract-pointers" port="result"/>
            <p:pipe step="v-generate-id-map-or-remap" port="result"/>
        </p:input>
    </p:xslt>


    <p:validate-with-xml-schema name="v-remap-ids">
        <p:input port="schema">
            <p:document href="lib/xsd/gedcom.xsd"/>
        </p:input>
    </p:validate-with-xml-schema>




     <p:xslt name="strip-attrs">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/strip_attrs.xslt"/>
        </p:input>
    </p:xslt>
</p:declare-step>
