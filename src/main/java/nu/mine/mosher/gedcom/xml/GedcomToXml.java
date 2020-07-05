package nu.mine.mosher.gedcom.xml;



import nu.mine.mosher.xml.XsltPipeline;
import org.slf4j.bridge.SLF4JBridgeHandler;
import org.xml.sax.SAXException;
import org.slf4j.LoggerFactory;
import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.*;
import java.net.URI;
import java.net.URL;
import java.nio.file.Paths;



public class GedcomToXml {
    static {
        SLF4JBridgeHandler.removeHandlersForRootLogger();
        SLF4JBridgeHandler.install();
        java.util.logging.Logger.getLogger("").setLevel(java.util.logging.Level.FINEST);
    }

    public static void main(final String... args) throws ParserConfigurationException, IOException, SAXException, TransformerException {
        final XsltPipeline pipeline = new XsltPipeline();
        pipeline.trace(false);
        final Logger root = (Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
        root.setLevel(Level.WARN);
        parseArgs(args, pipeline, root);

        pipeline.xsd(lib("xsd/lines.xsd"));

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

        pipeline.serialize(new BufferedOutputStream(new FileOutputStream(FileDescriptor.out)));
    }

    private static void parseArgs(final String[] args, final XsltPipeline pipeline, final Logger root) throws IOException {
        boolean ged = false;
        for (final String arg : args) {
            if (arg.equals("--verbose") || arg.equals("-v")) {
                pipeline.trace(true);
                root.setLevel(Level.ALL);
                System.setProperty("jaxp.debug", "1");
            } else {
                if (!ged) {
                    ged = true;
                    pipeline.param("filename", asUrl(arg));
                } else {
                    throw new IllegalArgumentException("usage gedcom-to-xml input.ged");
                }
            }
        }
        if (!ged) {
            throw new IllegalArgumentException("usage gedcom-to-xml input.ged");
        }
    }

    private static URL lib(final String path) {
        return GedcomToXml.class.getResource("lib/"+path);
    }

    private static URL asUrl(final String pathOrUrl) throws IOException {
        Throwable urlExcept;
        try {
            return new URI(pathOrUrl).toURL();
        } catch (final Throwable e) {
            urlExcept = e;
        }

        Throwable pathExcept;
        try {
            return Paths.get(pathOrUrl).toUri().toURL();
        } catch (final Throwable e) {
            pathExcept = e;
        }

        final IOException except = new IOException("Invalid path or URL: " + pathOrUrl);
        except.addSuppressed(pathExcept);
        except.addSuppressed(urlExcept);
        throw except;
    }
}
