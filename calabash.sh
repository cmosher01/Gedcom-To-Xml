#!/bin/sh -e

cd

in=$(mktemp)
cat - >$in

if [ ! -s "$in" ] ; then
    echo "usage:" >&2
    echo "    docker run -i cmosher01/gedcom-to-xml < FILE.ged" >&2
    exit 1
fi

exec java -jar xmlcalabash*/xmlcalabash*.jar -p "filename=$in" gedcom.xpl
