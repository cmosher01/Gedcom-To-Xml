<?xml version="1.0" encoding="UTF-8"?>
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
            <p:document href="lib/xslt/toxml.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-lines-to-xml">
        <p:input port="schema">
            <p:document href="lib/relaxng/lines.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



    <p:xslt name="find-level-numbers">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/level.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-find-level-numbers">
        <p:input port="schema">
            <p:document href="lib/relaxng/hier.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



    <p:xslt name="fix-missing-level-numbers">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/fixlev.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-fix-missing-level-numbers">
        <p:input port="schema">
            <p:document href="lib/relaxng/hier.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



    <p:xslt name="generate-hierarchy">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/hier.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-generate-hierarchy">
        <p:input port="schema">
            <p:document href="lib/relaxng/hier.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



    <p:xslt name="parse-gedcom-lines">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/parse_raw_nodes.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-parse-gedcom-lines">
        <p:input port="schema">
            <p:document href="lib/relaxng/gedcom.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



    <p:xslt name="process-cont-conc-lines">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/contconc.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-process-cont-conc-lines">
        <p:input port="schema">
            <p:document href="lib/relaxng/gedcom.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



    <p:xslt name="extract-pointers">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/extract_ptrs.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-extract-pointers">
        <p:input port="schema">
            <p:document href="lib/relaxng/gedcom.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



     <p:xslt name="generate-id-map-or-remap">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/gen_id_map2.xslt"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-generate-id-map-or-remap">
        <p:input port="schema">
            <p:document href="lib/relaxng/gedcom-ids.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



    <p:xslt name="remap-ids">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/remap_ids2.xslt"/>
        </p:input>
        <p:input port="source">
            <p:pipe step="v-extract-pointers" port="result"/>
            <p:pipe step="v-generate-id-map-or-remap" port="result"/>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="v-remap-ids">
        <p:input port="schema">
            <p:document href="lib/relaxng/gedcom.rng.xml"/>
        </p:input>
    </p:validate-with-relax-ng>



     <p:xslt name="strip-attrs">
        <p:input port="stylesheet">
            <p:document href="lib/xslt/strip_attrs.xslt"/>
        </p:input>
    </p:xslt>
</p:declare-step>
