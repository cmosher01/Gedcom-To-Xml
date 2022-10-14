# Gedcom-To-Xml

Copyright © 2019–2022, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

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
* `CONC` and `CONT` lines are concatenated appropriately

This program is safe to run; no existing files will be modified, overwritten, or deleted.
If the corresponding XML output file already exists,
then a new unique filename (with a timestamp) will be created instead.

---
## quick start (Ubuntu)

Download the latest DEB package from
https://github.com/cmosher01/Gedcom-To-Xml/releases/latest ,
and then install it:

```sh
$ sudo dpkg -i ~/Downloads/gedcom-to-xml_VERSION-1_amd64.deb
Selecting previously unselected package gedcom-to-xml.
(Reading database ... 974904 files and directories currently installed.)
Preparing to unpack .../gedcom-to-xml_2.0.1-1_amd64.deb ...
Unpacking gedcom-to-xml (2.0.1-1) ...
Setting up gedcom-to-xml (2.0.1-1) ...
```

Create a small GEDCOM file:
```sh
$ cat - >minimal.ged
0 HEAD
1 CHAR UTF-8
1 SUBM @S1@
0 @S1@ SUBM
1 NAME Chris /Mosher/
1 EMAIL cmosher01@@gmail.com
2 NOTE Note:
3 CONT This is a small ex
3 CONC ample GEDCOM file.
0 TRLR
```

Run it through Gedcom-To-Xml:
```sh
$ /opt/gedcom-to-xml/bin/gedcom-to-xml minimal.ged
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
This is a small example GEDCOM file.</gedcom:value>
         </gedcom:node>
      </gedcom:node>
   </gedcom:node>
   <gedcom:node gedcom:tag="TRLR">
      <gedcom:value/>
   </gedcom:node>
</gedcom:nodes>
```



## XML schema

Three XML namespaces, with associated schema, are defined.
Schema definition files are available at the namespace URLs.

`https://mosher.mine.nu/xmlns/gedcom`

This is the primary GEDCOM schema, defining `node`
and `value` elements, and the `tag` attribute.

`https://mosher.mine.nu/xmlns/hier`

This is an intermediate schema describing an XML file
that represents a generic hierarchy of nodes.

`https://mosher.mine.nu/xmlns/lines`

This is a very generic schema describing an XML file
that represents a simple series of lines.



## implementation
Gedcom-To-Xml is implemented as a pipeline that converts the GEDCOM file using
a series of XSL transformations. Each step transforms one aspect of the GEDCOM
data and verifies the output against an XML schema.

## development
Build using JDK 17 or greater.
Depends on Xerces and Saxon-HE (latest versions).

```sh
$ java -version
openjdk version "17.0.4" 2022-07-19
OpenJDK Runtime Environment (build 17.0.4+8-Ubuntu-122.04)
OpenJDK 64-Bit Server VM (build 17.0.4+8-Ubuntu-122.04, mixed mode, sharing)
$ git clone https://github.com/cmosher01/Gedcom-To-Xml.git
$ cd Gedcom-To-Xml
$ ./gradlew build
```
