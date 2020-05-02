#!/bin/sh -e

if [ -t 0 -o $# -gt 0 ] ; then
    echo "usage: $0 <input.ged >output.xml" >&2
    echo "Converts input.ged to output.xml." >&2
    echo "See https://github.com/cmosher01/Gedcom-To-Xml" >&2
    exit 1
fi

if ! calabash -i source=p:empty -s p:count >/dev/null 2>&1 ; then
    set +e
    calabash >&2 2>&1
    echo "Please install calabash to run the pipeline." >&2
    echo "See http://xmlcalabash.com" >&2
    exit 1
fi

in=$(mktemp)
cat - >$in

me="$(perl -MCwd -e 'print Cwd::abs_path shift' "$0")"
here="$(dirname "$me")"

echo "Converting GEDCOM file..." >&2
calabash -p "filename=$in" $here/gedcom.xpl
echo "Created XML file." >&2
