#!/bin/sh

sax98="java -cp /usr/share/java/Saxon-HE.jar"
sax99="java -cp /opt/saxon/current/saxon9he.jar"
sax="$sax98"
xslt="$sax net.sf.saxon.Transform -xmlversion:1.1 -dtd:on"
tdir=src/main/resources/xslt
initt={http://www.w3.org/1999/XSL/Transform}initial-template

$xslt -xsl:$tdir/toxml.xslt "-it:$initt" filename=/dev/stdin encoding=UTF-8 >a1.xml
$xslt -xsl:$tdir/level.xslt -s:a1.xml >a2.xml
$xslt -xsl:$tdir/fixlev.xslt -s:a2.xml >a3.xml
$xslt -xsl:$tdir/hier.xslt -s:a3.xml >e1.xml

# parse nodes to id/tag/value/pointer
$xslt -xsl:$tdir/parse_raw_nodes.xslt -s:e1.xml >e2.xml

# see if there are any invalid GEDCOM ID values
remap=true
if $xslt -xsl:$tdir/verify_valid_ids.xslt -s:e2.xml ; then
    remap=false
fi

# generate id mapping
$xslt -xsl:$tdir/generate_id_map.xslt -s:e2.xml remap=$remap >e3.id.xml

# remap ids
# +param=filename broken in Saxon 9.9, so use 9.8
$xslt -xsl:$tdir/remap_ids.xslt -s:e2.xml +idfile=e3.id.xml >e4.xml

# process CONT and CONC lines
$xslt -xsl:$tdir/contconc.xslt -s:e4.xml >e5.xml


# $sax net.sf.saxon.Query -xmlversion:1.1 -dtd:on -qs:/ '!indent=yes' -s:e5.xml >e5.f.xml
