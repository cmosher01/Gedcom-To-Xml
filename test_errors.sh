#!/bin/sh

sax98="java -cp /usr/share/java/Saxon-HE.jar"
sax99="java -cp /opt/saxon/current/saxon9he.jar"
sax="$sax98"

# GEDCOM to XML (raw nodes only)
./gedcom-to-xml-1.0.0-SNAPSHOT/bin/gedcom-to-xml >e1.xml

# parse nodes to id/tag/value/pointer
$sax net.sf.saxon.Transform -xmlversion:1.1 -dtd:on -xsl:src/main/resources/xslt/parse_raw_nodes.xslt -s:e1.xml >e2.xml
$sax net.sf.saxon.Query -xmlversion:1.1 -dtd:on -qs:/ '!indent=yes' -s:e2.xml >e2.f.xml

# see if there are any invalid GEDCOM ID values
remap=true
if $sax net.sf.saxon.Transform -xmlversion:1.1 -dtd:on -xsl:src/main/resources/xslt/verify_valid_ids.xslt -s:e2.xml ; then
    remap=false
fi

# generate id mapping
$sax net.sf.saxon.Transform -xmlversion:1.1 -dtd:on -xsl:src/main/resources/xslt/generate_id_map.xslt -s:e2.xml remap=$remap >e3.id.xml
$sax net.sf.saxon.Query -xmlversion:1.1 -dtd:on -qs:/ '!indent=yes' -s:e3.id.xml >e3.id.f.xml

# remap ids
# +param=filename broken in Saxon 9.9, so use 9.8
$sax net.sf.saxon.Transform -xmlversion:1.1 -dtd:on -xsl:src/main/resources/xslt/remap_ids.xslt -s:e2.xml +idfile=e3.id.xml >e4.xml
$sax net.sf.saxon.Query -xmlversion:1.1 -dtd:on -qs:/ '!indent=yes' -s:e4.xml >e4.f.xml

# process CONT and CONC lines
$sax net.sf.saxon.Transform -xmlversion:1.1 -dtd:on -xsl:src/main/resources/xslt/contconc.xslt -s:e4.xml >e5.xml
$sax net.sf.saxon.Query -xmlversion:1.1 -dtd:on -qs:/ '!indent=yes' -s:e5.xml >e5.f.xml
