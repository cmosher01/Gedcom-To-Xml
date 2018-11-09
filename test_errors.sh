#!/bin/sh

# GEDCOM to XML (raw nodes only)
./gedcom-to-xml-1.0.0-SNAPSHOT/bin/gedcom-to-xml -n -e UTF-8 -v <../Gedcom-Tests/errors.ged >e1.xml

# parse nodes to id/tag/value/pointer
java -cp /opt/saxon/current/saxon9he.jar net.sf.saxon.Transform -xmlversion:1.1 -dtd:on -xsl:src/main/resources/xslt/parse_raw_nodes.xslt -s:e1.xml >e2.xml
java -cp /usr/share/java/Saxon-HE.jar net.sf.saxon.Query -qs:/ '!indent=yes' -s:e2.xml >e2.f.xml

# generate id mapping
java -cp /opt/saxon/current/saxon9he.jar net.sf.saxon.Transform -xmlversion:1.1 -dtd:on -xsl:src/main/resources/xslt/generate_id_map.xslt -s:e2.xml >e3.id.xml
java -cp /usr/share/java/Saxon-HE.jar net.sf.saxon.Query -qs:/ '!indent=yes' -s:e3.id.xml >e3.id.f.xml

# remap ids
java -cp /opt/saxon/current/saxon9he.jar net.sf.saxon.Transform -xmlversion:1.1 -dtd:on -xsl:src/main/resources/xslt/remap_ids.xslt -s:e2.xml >e4.xml
java -cp /usr/share/java/Saxon-HE.jar net.sf.saxon.Query -qs:/ '!indent=yes' -s:e4.xml >e4.f.xml
