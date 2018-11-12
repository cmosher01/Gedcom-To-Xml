#!/bin/sh -e

if [ $# = 0 ] ; then
    echo "usage: $0 input.ged" >&2
    echo "Converts input.ged to XML on standard output." >&2
    echo "Use - to read from standard input." >&2
    exit 1
fi

echo "Checking for installation of Calabash XML." >&2
if ! calabash -i source= -s p:count >/dev/null 2>&1 ; then
    echo "Please install calabash to run the pipeline." >&2
    calabash
    exit 1
fi

in="$1"
if [ "$in" = "-" ] ; then
    in=$(mktemp)
    cat - >$in
fi

me="$(perl -MCwd -e 'print Cwd::abs_path shift' "$0")"
here="$(dirname "$me")"

calabash -p base-dir=file://$(pwd)/ -p filename="$in" $here/gedcom.xpl
