/*
    Gedcom-To-Xml
    Converts GEDCOM file to XML format.

    Copyright © 2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

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
import nu.mine.mosher.gedcom.charset.CharsetDetector;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.nio.charset.Charset;
import java.util.*;

@SuppressWarnings({"OptionalUsedAsFieldOrParameterType", "unused"})
public class GedcomToXmlCli {
    public boolean help;
    public boolean verbose;
    public boolean dryrun;
    public final List<Step> steps = new ArrayList<>(8);



    public void help(final Optional<String> none) {
        if (none.isPresent()) {
            throw new IllegalArgumentException("--help option does not allow a value");
        }
        this.help = true;

        System.out.println("usage:");
        System.out.println();
        System.out.println("    gedcom-to-xml { OPTION | input.ged } ...");
        System.out.println();
        System.out.println("options:");
        System.out.println();
        System.out.println("  --help                  show help and exit, do not run anything");
        System.out.println("  --verbose={true|false}  display log messages, and output of every step of conversion");
        System.out.println("  --dryrun={true|false}   do not write output files, just print report");
        System.out.println("  --charset               detect charset of file(s) automatically (default)");
        System.out.println("  --charset=CHARSET       assume file(s) are encoded in CHARSET");
    }

    public void verbose(final Optional<String> b) {
        this.verbose = parseBoolean("verbose", b);
    }

    public void dryrun(final Optional<String> b) {
        this.dryrun = parseBoolean("dryrun", b);
    }

    public void charset(final Optional<String> name) {
        if (name.isPresent()) {
            this.steps.add(new ForceCharsetStep(Charset.forName(name.get())));
        } else {
            this.steps.add(new GuessCharsetStep());
        }
    }

    public void __(final Optional<String> path) throws IOException {
        this.steps.add(new ConvertFileStep(new File(path.get()).getCanonicalFile()));
    }






    void execute() {
        final Logger log = (Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
        if (verbose) {
            log.setLevel(Level.ALL);
            System.setProperty("jaxp.debug", "1");
            log.info("Will show verbose log messages.");
        } else {
            log.setLevel(Level.WARN);
        }

        this.steps.forEach(Step::execute);
    }



    private Optional<Charset> charsetForce = Optional.empty();



    public interface Step {
        void execute();
    }

    public class ForceCharsetStep implements Step {
        public final Charset charset;
        private ForceCharsetStep(final Charset charset) {
            this.charset = Objects.requireNonNull(charset);
        }
        @Override
        public void execute() {
            GedcomToXmlCli.this.charsetForce = Optional.of(this.charset);
        }
    }

    public class GuessCharsetStep implements Step {
        private GuessCharsetStep() {}
        @Override
        public void execute() {
            GedcomToXmlCli.this.charsetForce = Optional.empty();
        }
    }

    public class ConvertFileStep implements Step {
        private final File file;
        private ConvertFileStep(File file) {
            this.file = Objects.requireNonNull(file);
        }
        @Override
        public void execute() {
            try {
                final File fileOut = FileUtil.outFileFor(this.file);
                final Charset charset;
                if (charsetForce.isPresent()) {
                    charset = charsetForce.get();
                } else {
                    final BufferedInputStream gedcom = new BufferedInputStream(new FileInputStream(this.file));
                    charset = new CharsetDetector(gedcom).detect();
                    gedcom.close();
                }
                GedcomToXmlPipeline.runPipelineOn(this.file, charset, fileOut, verbose, dryrun);
            } catch (final Exception e) {
                throw new RuntimeException(e);
            }
        }
    }





    static boolean parseBoolean(final String option, final Optional<String> b) {
        boolean r;
        if (b.isPresent() && (b.get().equalsIgnoreCase("true") || b.get().equalsIgnoreCase("t"))) {
            r = true;
        } else if (b.isPresent() && (b.get().equalsIgnoreCase("false") || b.get().equalsIgnoreCase("f"))) {
            r = false;
        } else if (!b.isPresent()) {
            r = true;
        } else {
            throw new IllegalArgumentException(String.format("Invalid value for option --%s={true|false}", option));
        }
        return r;
    }
}
