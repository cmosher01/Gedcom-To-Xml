#!/bin/sh -e

cd

calabash="java -jar xmlcalabash*/xmlcalabash*.jar"

in=$(mktemp)
cat - >$in

if [ ! -s "$in" ] ; then
    echo "usage:" >&2
    echo "    docker run -i cmosher01/gedcom-to-xml < FILE.ged" >&2
    exit 1
fi

exec $calabash -p "filename=$in" gedcom.xpl
