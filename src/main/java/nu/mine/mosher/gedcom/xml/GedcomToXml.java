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


import ch.qos.logback.classic.*;
import nu.mine.mosher.xml.XsltPipeline;
import org.slf4j.LoggerFactory;
import org.slf4j.bridge.SLF4JBridgeHandler;
import org.w3c.dom.*;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.*;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.atomic.AtomicLong;


public class GedcomToXml {
    static {
        SLF4JBridgeHandler.removeHandlersForRootLogger();
        SLF4JBridgeHandler.install();
        java.util.logging.Logger.getLogger("").setLevel(java.util.logging.Level.FINEST);
    }

    public static void main(final String... args) throws ParserConfigurationException, IOException, SAXException, TransformerException {
        boolean verbose = false;
        boolean help = false;
        boolean dryrun = false;

        for (final String arg : args) {
            if (arg.startsWith("-")) {
                switch (arg) {
                    case "--verbose":
                    case "-v":
                        verbose = true;
                        break;
                    case "--dry-run":
                    case "-n":
                        dryrun = true;
                        break;
                    case "--help":
                    case "-h":
                        help = true;
                        break;
                    default:
                        throw new IllegalArgumentException("Invalid option: " + arg);
                }
            }
        }

        if (help) {
            help();
        } else {
            for (final String arg : args) {
                if (arg.startsWith("-")) {
                    // TODO positional options
                } else {
                    final File fileIn = new File(arg).getCanonicalFile();
                    final File fileOut = outFileFor(fileIn);
                    runPipelineOn(fileIn, fileOut, verbose, dryrun);
                }
            }
        }

        System.out.flush();
        System.err.flush();
    }

    private static void help() {
        System.out.println("usage:");
        System.out.println("    gedcom-to-xml ( input.ged | OPTION ) ...");
        System.out.println("options:");
//        System.out.println("global options (affect entire run):");
        System.out.println("    --help, -h    show help, and exit");
        System.out.println("    --verbose, -v    display log messages, and output of every step of conversion");
        System.out.println("    --dry-run, -n    do not generate any output files");
// TODO additional options
//        System.out.println("positional options (affect starting at position:");
//        System.out.println("    --encoding=guess    detect encoding automatically (default)");
//        System.out.println("    --encoding=ENC    force encoding to use");
    }

    private static File outFileFor(final File fileIn) {
        final File dir = fileIn.getParentFile();

        final String[] ss = fileIn.getName().split("\\.(?=[^.]+$)");
        String s = ss[0];
        if (!s.endsWith(".")) {
            s += ".";
        }

        File newfile = new File(dir, s + "xml");
        if (newfile.exists()) {
            newfile = uniquify(dir, s, "xml");
        }
        return newfile;
    }

    private static File uniquify(final File dir, final String s, final String typ) {
        final String uniq = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss_nnnnnnnnn").withZone(ZoneId.of("UTC")).format(Instant.now());
        return new File(dir, s + uniq + "." + typ);
    }

    private static void runPipelineOn(final File fileIn, final File fileOut, final boolean verbose, final boolean dryrun) throws ParserConfigurationException, TransformerException, SAXException, IOException {
        final XsltPipeline pipeline = new XsltPipeline();

        if (verbose) {
            pipeline.trace(true);
            ((Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME)).setLevel(Level.ALL);
            System.setProperty("jaxp.debug", "1");
        } else {
            pipeline.trace(false);
            ((Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME)).setLevel(Level.WARN);
        }

        pipeline.xsd(lib("xsd/lines.xsd"));

        pipeline.dom();
        buildLinesXml(fileIn, pipeline.accessDom());
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

    private static void buildLinesXml(final File fileIn, final Node node) throws FileNotFoundException {
        // TODO: handle different charsets
        final BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream(fileIn), StandardCharsets.UTF_8));

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

    private static URL lib(final String path) {
        return GedcomToXml.class.getResource("lib/" + path);
    }
}
