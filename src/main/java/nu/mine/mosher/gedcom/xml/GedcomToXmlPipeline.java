/*
    Gedcom-To-Xml
    Converts GEDCOM file to XML format.

    Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package nu.mine.mosher.gedcom.xml;

import nu.mine.mosher.xml.XsltPipeline;
import org.mozilla.universalchardet.UnicodeBOMInputStream;
import org.w3c.dom.*;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.*;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicLong;

public class GedcomToXmlPipeline {
    public static void runPipelineOn(final File fileIn, final Charset charsetIn, final File fileOut, final boolean verbose, final boolean dryrun) throws ParserConfigurationException, TransformerException, SAXException, IOException {
        final BufferedReader in =
            new BufferedReader(
                new InputStreamReader(
                    new UnicodeBOMInputStream(
                        new FileInputStream(Objects.requireNonNull(fileIn))),
                    Objects.requireNonNull(charsetIn)));



        final XsltPipeline pipeline = new XsltPipeline();

        pipeline.trace(verbose);

        pipeline.xsd(lib("xsd/lines.xsd"));

        pipeline.dom();
        buildLinesXml(in, pipeline.accessDom());
        pipeline.traceDom();
        pipeline.validate();


        pipeline.xsd();
        pipeline.xsd(lib("xsd/hier.xsd"));

        pipeline.xslt(lib("xslt/level.xslt"));
        pipeline.validate();

        pipeline.xslt(lib("xslt/fixlev.xslt"));
        pipeline.validate();

        pipeline.xslt(lib("xslt/hier.xslt"));
        pipeline.validate();


        pipeline.xsd();
        pipeline.xsd(lib("xsd/gedcom.xsd"));

        pipeline.xslt(lib("xslt/parse_raw_nodes.xslt"));
        pipeline.validate();

        pipeline.xslt(lib("xslt/contconc.xslt"));
        pipeline.validate();

        pipeline.xslt(lib("xslt/extract_ptrs.xslt"));
        pipeline.validate();

        pipeline.xslt(lib("xslt/remap_ids2.xslt"));
        pipeline.validate();

        pipeline.xslt(lib("xslt/strip_attrs.xslt"));
        pipeline.validate();

        pipeline.xmldecl(true);
        pipeline.pretty(true);

        if (dryrun) {
            if (verbose) {
                pipeline.serialize(new BufferedOutputStream(new OutputStream() { public void write(int b) { } }));
            }
        } else {
            pipeline.serialize(new BufferedOutputStream(new FileOutputStream(fileOut)));
        }



        if (verbose) {
            if (dryrun) {
                System.err.println("Dry run; no files created. If this had been an actual run, it would have converted:");
            } else {
                System.err.println("Converted:");
            }
            System.err.println(String.format("%s --> %s", fileIn, fileOut));
        }
    }

    /**
     * Takes a standard text file reader and creates a simple XML DOM
     * out of it, that conforms to https://mosher.mine.nu/xmlns/lines schema.
     *
     * @param in input reader
     * @param node node to append to DOM to
     */
    private static void buildLinesXml(final BufferedReader in, final Node node) {
        final String NS = "https://mosher.mine.nu/xmlns/lines";
        final Document document = node instanceof Document ? (Document)node : node.getOwnerDocument();

        final Element lines = document.createElementNS(NS, "lines:lines");
        node.appendChild(lines);

        final AtomicLong n = new AtomicLong(1L);
        in.lines().forEachOrdered(s -> {
            final Element line = document.createElementNS(NS, "lines:line");
            line.setAttributeNS(NS, "lines:seq", Long.toString(n.getAndIncrement()));
            line.setTextContent(s);
            lines.appendChild(line);
        });
    }

    /**
     * Gets URL of "lib" resource.
     *
     * @param path path in this class's lib directory of resource
     * @return URL
     */
    private static URL lib(final String path) {
        return GedcomToXmlPipeline.class.getResource("lib/" + path);
    }
}
