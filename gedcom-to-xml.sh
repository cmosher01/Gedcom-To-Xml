#!/bin/sh
calabash=/opt/calabash/current/xmlcalabash-*.jar

if [ $# = 0 ] ; then
    echo "usage: $0 input.ged" >&2
    echo "Converts input.ged to XML on standard output." >&2
    exit 1
fi

cj="$(readlink -f $calabash)"
echo "Using Calabash jar file: $cj" >&2
if [ ! -r "$cj" ] ; then
    echo "Error: cannot find Calabash jar file $calabash" >&2
    exit 1
fi

here="$(dirname "$(readlink -f "$0")")"

java -jar "$cj" -p base-dir=file://$(pwd)/ -p filename="$1" $here/gedcom.xpl
