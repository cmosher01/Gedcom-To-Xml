<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    name="test"
>
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>

    <p:xslt name="generate-id-map-or-remap">
        <p:input port="stylesheet">
            <p:document href="xslt/gen_id_map2.xslt"/>
        </p:input>
        <p:input port="parameters"/>
    </p:xslt>

    <p:xslt name="remap-ids">
        <p:input port="stylesheet">
            <p:document href="xslt/remap_ids2.xslt"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="test" port="source"/>
            <p:pipe step="generate-id-map-or-remap" port="result"/>
        </p:input>
        <p:input port="parameters"/>
    </p:xslt>
</p:declare-step>
