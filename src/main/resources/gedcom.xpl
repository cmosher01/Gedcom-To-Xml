<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
    <p:input port="source" sequence="true">
        <p:empty/>
    </p:input>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result"/>
    <p:serialization port="result"
        version="1.1"
        indent="true"
        omit-xml-declaration="false"
        standalone="false"
        doctype-public="+//IDN mosher.mine.nu//DTD gedcom nodes 1.0//EN"
        doctype-system="https://mosher.mine.nu/dtd/gedcom/nodes.dtd"
    />



    <p:xslt name="lines-to-xml" template-name="xsl:initial-template">
        <p:input port="stylesheet">
            <p:document href="xslt/toxml.xslt"/>
        </p:input>
    </p:xslt>

    <p:xslt name="find-level-numbers">
        <p:input port="stylesheet">
            <p:document href="xslt/level.xslt"/>
        </p:input>
    </p:xslt>

    <p:xslt name="fix-missing-level-numbers">
        <p:input port="stylesheet">
            <p:document href="xslt/fixlev.xslt"/>
        </p:input>
    </p:xslt>

    <p:xslt name="generate-hierarchy">
        <p:input port="stylesheet">
            <p:document href="xslt/hier.xslt"/>
        </p:input>
    </p:xslt>

    <p:xslt name="parse-gedcom-lines">
        <p:input port="stylesheet">
            <p:document href="xslt/parse_raw_nodes.xslt"/>
        </p:input>
    </p:xslt>

    <p:xslt name="generate-id-map-or-remap">
        <p:input port="stylesheet">
            <p:document href="xslt/gen_id_map2.xslt"/>
        </p:input>
    </p:xslt>

    <p:xslt name="remap-ids">
        <p:input port="stylesheet">
            <p:document href="xslt/remap_ids2.xslt"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="parse-gedcom-lines" port="result"/>
            <p:pipe step="generate-id-map-or-remap" port="result"/>
        </p:input>
    </p:xslt>

    <p:xslt name="process-cont-conc-lines">
        <p:input port="stylesheet">
            <p:document href="xslt/contconc.xslt"/>
        </p:input>
    </p:xslt>
</p:declare-step>
