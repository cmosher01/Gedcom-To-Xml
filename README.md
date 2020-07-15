# Gedcom-To-Xml

Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

[![License](https://img.shields.io/github/license/cmosher01/Gedcom-To-Xml.svg)](https://www.gnu.org/licenses/gpl.html)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CVSSQ2BWDCKQ2)

Yet another GEDCOM to XML converter: converts a GEDCOM file into an XML file.

The philosophy of this program is to be a simple conversion of syntax, and not to try
to parse or understand GEDCOM tags. It robustly handles the follow GEDCOM features:

* hierarchical levels (become nested `node` elements)
* tags (become `tag` attributes)
* values (become their own `value` elements)
* cross-references (IDs become `xml:id` and pointers become `xlink:href`)
* `@@` becomes `@`
* `CONC` and `CONT` lines

---
## Run

Requires Java SE 11 or greater.

```sh
/path/to/gedcom-to-xml "My Family Tree.ged"
```

creates corresponding `My Family Tree.xml` output file.

This program is safe to run; no existing files will be modified, overwritten, or deleted.
If the corresponding XML output file already exists,
then a new unique filename (with a timestamp) will be created instead.

For usage information:
```sh
/path/to/gedcom-to-xml --help
```

---
## Tutorial

Install:
```sh
$ tar xf gedcom-to-xml-1.0.0.tar
```

Create test GEDCOM file:
```sh
$ cat - >minimal.ged
0 HEAD
1 CHAR UTF-8
1 SUBM @S1@
0 @S1@ SUBM
1 NAME Chris /Mosher/
1 EMAIL cmosher01@@gmail.com
2 NOTE Note:
3 CONT This is a minimal ex
3 CONC ample GEDCOM file.
0 TRLR
```

Run it through Gedcom-To-Xml:
```sh
$ ./gedcom-to-xml-1.0.0/bin/gedcom-to-xml minimal.ged
```

See the resuting XML output file:
```xml
$ cat minimal.xml
<?xml version="1.0" encoding="UTF-8"?>
<gedcom:nodes xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom">
   <gedcom:node gedcom:tag="HEAD">
      <gedcom:value/>
      <gedcom:node gedcom:tag="CHAR">
         <gedcom:value>UTF-8</gedcom:value>
      </gedcom:node>
      <gedcom:node gedcom:tag="SUBM">
         <gedcom:value xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#S1"/>
      </gedcom:node>
   </gedcom:node>
   <gedcom:node gedcom:tag="SUBM" xml:id="S1">
      <gedcom:value/>
      <gedcom:node gedcom:tag="NAME">
         <gedcom:value>Chris /Mosher/</gedcom:value>
      </gedcom:node>
      <gedcom:node gedcom:tag="EMAIL">
         <gedcom:value>cmosher01@gmail.com</gedcom:value>
         <gedcom:node gedcom:tag="NOTE">
            <gedcom:value>Note:
This is a minimal example GEDCOM file.</gedcom:value>
         </gedcom:node>
      </gedcom:node>
   </gedcom:node>
   <gedcom:node gedcom:tag="TRLR">
      <gedcom:value/>
   </gedcom:node>
</gedcom:nodes>
```


## Implementation
Gedcom-To-Xml is implemented as a pipeline that converts the GEDCOM file using
a series of XSL transformations. Each step transforms one aspect of the GEDCOM
data and verifies the output against an XML schema.

## Development
Build using JDK 11 or greater.
Depends on Xerces and Saxon-HE (latest versions).

Quick start:

```sh
$ java -version
openjdk version "11.0.5" 2019-10-15 LTS
OpenJDK Runtime Environment Corretto-11.0.5.10.1 (build 11.0.5+10-LTS)
OpenJDK 64-Bit Server VM Corretto-11.0.5.10.1 (build 11.0.5+10-LTS, mixed mode)
$ git clone https://github.com/cmosher01/Gedcom-To-Xml.git
$ cd Gedcom-To-Xml
$ ./gradlew build
$ tar xf build/distributions/gedcom-to-xml-1.0.0.tar
$ ./gedcom-to-xml-1.0.0/bin/gedcom-to-xml examples/minimal.ged
$ cat examples/minimal.xml
```
