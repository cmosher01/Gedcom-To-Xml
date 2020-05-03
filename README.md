# Gedcom-To-Xml

Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

[![License](https://img.shields.io/github/license/cmosher01/Gedcom-To-Xml.svg)](https://www.gnu.org/licenses/gpl.html)
[![Latest Release](https://img.shields.io/github/release-pre/cmosher01/Gedcom-To-Xml.svg)](https://github.com/cmosher01/Genealdb/releases/latest)
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
## run

Using docker:

`docker run -i cmosher01/gedcom-to-xml < FILE.ged > FILE.xml`

Or else, install [XML Calabash](http://xmlcalabash.com/), then run:

`./gedcom-to-xml.sh < FILE.ged > FILE.xml`

---
## example

For example, the following GEDCOM file:

```
0 HEAD
1 CHAR UTF-8
1 SUBM @S1@
0 @S1@ SUBM
1 NAME Chris /Mosher/
2 NOTE Note:
3 CONT This is a minimal ex
3 CONC ample GEDCOM file.
0 TRLR
```

gets converted to the following XML:

```xml
<?xml version="1.1" encoding="UTF-8"?>
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

---

Assumes UTF-8 input GEDCOM files. Any non-UTF-8 GEDCOM files must be converted to UTF-8 first.
[Gedcom-Lib](https://github.com/cmosher01/Gedcom-Lib) may be of help in this regard.

---
## implementation

Gedcom-To-Xml is implemented as an XML XProc pipeline that converts the GEDCOM file
in a series of XSL transformations. Each step transforms one aspect of the GEDCOM data
and verifies the output against an XML schema.
