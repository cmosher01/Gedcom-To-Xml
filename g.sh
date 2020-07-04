#!/bin/sh

if [ -z "$1" ] ; then
	echo "usage: $0 input.ged" >&2
	exit 1
fi

if ! xslt-pipeline >/dev/null 2>&1 ; then
	echo "ERROR: requires https://github.com/cmosher01/Xslt-Pipeline"
fi

filepath="$(perl -MCwd -e 'print Cwd::abs_path shift' "$1")"

xslt-pipeline \
	\
	-xsd --xsd=lib/xsd/lines.xsd \
	--param=filename:"file:$filepath" --it=true --xslt=lib/xslt/toxml.xslt --it=false --validate \
	\
	--xsd --xsd=lib/xsd/hier.xsd \
	--xslt=lib/xslt/level.xslt --validate \
	--xslt=lib/xslt/fixlev.xslt --validate \
	--xslt=lib/xslt/hier.xslt --validate \
	\
	--xsd --xsd=lib/xsd/gedcom.xsd \
	--xslt=lib/xslt/parse_raw_nodes.xslt --validate \
	--xslt=lib/xslt/contconc.xslt --validate \
	--xslt=lib/xslt/extract_ptrs.xslt --validate \
	--xslt=lib/xslt/remap_ids2.xslt --validate \
	--xslt=lib/xslt/strip_attrs.xslt --validate \
#	
