/*
    Gedcom-To-Xml
    Converts GEDCOM file to XML format.

    Copyright © 2018–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

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

package nu.mine.mosher.gedcom.charset;

import org.slf4j.*;

import java.io.*;
import java.nio.charset.Charset;
import java.util.*;

/**
 * Reads a GEDCOM format input stream to determine character set encoding of the stream.
 * This makes a best effort using heuristic byte analysis, and the declared CHAR value in
 * the GEDCOM file.
 *
 * If all heuristics fail, returns the JVM's default character set ({@link Charset#defaultCharset()}).
 */
public class CharsetDetector {
    private static final Logger LOG = LoggerFactory.getLogger(CharsetDetector.class);

    private final BufferedInputStream gedcom;

    public CharsetDetector(final BufferedInputStream gedcom) {
        this.gedcom = gedcom;
    }

    public Charset detect() throws IOException {
        final Optional<Charset> charsetDetected = HeuristicCharsetDetector.detect(this.gedcom);

        if (charsetDetected.isPresent()) {
            LOG.info("First guess at charset: {}.", charsetDetected.get().displayName());
        } else {
            LOG.info("First guess at charset failed.");
            LOG.info("First guess at charset defaulting to: {}.", Charset.defaultCharset().displayName());
        }

        final Optional<Charset> charsetDeclared = DeclaredCharsetDetector.detect(this.gedcom, charsetDetected.orElse(Charset.defaultCharset()));
        if (charsetDeclared.isPresent()) {
            LOG.info("Declared charset: {}.", charsetDeclared.get().displayName());
        } else {
            LOG.warn("Could not find a valid charset declaration.");
        }

        final Charset charsetResult;
        if (charsetDetected.isPresent() && charsetDeclared.isPresent()) {
            charsetResult = resolveConflictingCharsets(charsetDetected.get(), charsetDeclared.get());
        } else if (charsetDetected.isPresent()) {
            charsetResult = charsetDetected.get();
        } else if (charsetDeclared.isPresent()) {
            charsetResult = charsetDeclared.get();
        } else {
            charsetResult = Charset.defaultCharset();
        }

        LOG.info("Will use charset: {}.", charsetResult.displayName());

        return charsetResult;
    }

    private Charset resolveConflictingCharsets(final Charset detected, final Charset declared) {
        if (detected.equals(declared)) {
            LOG.info("The detected charset and the declared charset are the same. Good.");
            return detected;
        }
        if (isDetectionReliable(detected)) {
            return detected;
        }
        return declared;
    }

    private boolean isDetectionReliable(final Charset detected) {
        return detected.name().contains("UTF");
    }
}
