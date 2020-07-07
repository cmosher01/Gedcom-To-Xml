package nu.mine.mosher.gedcom.xml;



import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import nu.mine.mosher.xml.XsltPipeline;
import org.slf4j.LoggerFactory;
import org.slf4j.bridge.SLF4JBridgeHandler;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.*;
import java.net.URISyntaxException;
import java.net.URL;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;



public class GedcomToXml {
    static {
        SLF4JBridgeHandler.removeHandlersForRootLogger();
        SLF4JBridgeHandler.install();
        java.util.logging.Logger.getLogger("").setLevel(java.util.logging.Level.FINEST);
    }

    public static void main(final String... args) throws ParserConfigurationException, IOException, SAXException, TransformerException, URISyntaxException
    {
        final boolean verbose = verbose(args);

        for (final String arg : args) {
            if (!arg.startsWith("-")) {
                final File fileIn = new File(arg).getCanonicalFile();
                final File fileOut = outFileFor(fileIn);
                runPipelineOn(fileIn, fileOut, verbose);
            }
        }
        System.out.println();
        System.err.println();
    }

    private static File outFileFor(final File fileIn) throws IOException {
        final File dir = fileIn.getParentFile();

        final String[] ss = fileIn.getName().split("\\.(?=[^.]+$)");
        String s = ss[0];
        if (!s.endsWith(".")) {
            s += ".";
        }

        File newfile = new File(dir, s+"xml");
        if (newfile.exists()) {
            newfile = uniquify(dir, s,"xml");
        }
        return newfile;
    }

    private static File uniquify(File dir, String s, String typ) {
        final String uniq = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss_nnnnnnnnn").withZone(ZoneId.of("UTC")).format(Instant.now());
        return new File(dir, s+uniq+"."+typ);
    }

    private static void runPipelineOn(final File fileIn, final File fileOut, final boolean verbose) throws ParserConfigurationException, TransformerException, SAXException, IOException {
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

        pipeline.param("filename", fileIn.toURI().toURL());
        pipeline.initialTemplate(true);
        pipeline.xslt(lib("xslt/toxml.xslt"));
        pipeline.initialTemplate(false);
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

        pipeline.serialize(new BufferedOutputStream(new FileOutputStream(fileOut)));

        if (verbose) {
            System.err.println(String.format("%s --> %s", fileIn, fileOut));
        }
    }

    private static boolean verbose(final String... args) {
        for (final String arg : args) {
            if (arg.equals("--verbose") || arg.equals("-v")) {
                return true;
            }
        }
        return false;
    }

    private static URL lib(final String path) {
        return GedcomToXml.class.getResource("lib/"+path);
    }
}
