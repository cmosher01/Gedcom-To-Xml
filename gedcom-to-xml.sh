#!/bin/sh -e

CALABASH_HOME=${CALABASH_HOME:-~/xmlcalabash-*}

if [ -t 0 -o $# -gt 0 ] ; then
    echo "usage: $0 <input.ged >output.xml" >&2
    echo "Converts input.ged to output.xml." >&2
    echo "See https://github.com/cmosher01/Gedcom-To-Xml" >&2
    exit 1
fi

if [ ! -e $CALABASH_HOME/xmlcalabash-*.jar ] ; then
    set +e
    java -jar $CALABASH_HOME/xmlcalabash-*/xmlcalabash-*.jar >&2 2>&1
    echo "Please install XML Calabash to run the pipeline." >&2
    echo "See http://xmlcalabash.com" >&2
    exit 1
fi

in=$(mktemp)
cat - >$in

me="$(perl -MCwd -e 'print Cwd::abs_path shift' "$0")"
here="$(dirname "$me")"

java -jar $CALABASH_HOME/xmlcalabash-*.jar -p "filename=$in" $here/gedcom.xpl
