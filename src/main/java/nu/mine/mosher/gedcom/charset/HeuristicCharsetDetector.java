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

import org.mozilla.universalchardet.UniversalDetector;
import org.slf4j.*;

import java.io.*;
import java.nio.charset.*;
import java.util.*;

/**
 * Reads a GEDCOM format input stream to determine character set encoding of the stream,
 * using "JUniversalCharDet".1
 *
 * The input stream's location is marked before reading, and reset afterwards.
 *
 * 1. Alberto Fernández, "JUniversalCharDet", java software (https://github.com/albfernandez/juniversalchardet : accessed 2020-07-13).
 */
public class HeuristicCharsetDetector {
    public static Optional<Charset> detect(final BufferedInputStream gedcomStream) throws IOException {
        final int cBytesToCheck = 64 * 1024;
        gedcomStream.mark(cBytesToCheck);
        try {
            return tryDetect(gedcomStream, cBytesToCheck);
        } finally {
            gedcomStream.reset();
        }
    }



    private static final Logger LOG = LoggerFactory.getLogger(DeclaredCharsetDetector.class);

    private static Optional<Charset> tryDetect(final BufferedInputStream gedcomStream, final int cBytesToCheck) throws IOException {
        final UniversalDetector detector = new UniversalDetector();

        final int cBufferSize = 4 * 1024;
        final byte[] buf = new byte[cBufferSize];
        boolean first = true;
        int sane = cBytesToCheck / cBufferSize;
        for (int cRead = gedcomStream.read(buf); cRead > 0 && --sane > 0; cRead = gedcomStream.read(buf)) {
            if (first && cRead >= 4) {
                final Optional<Charset> prescreened = prescreen(buf);
                if (prescreened.isPresent()) {
                    return prescreened;
                }
            }
            detector.handleData(buf, 0, cRead);
            first = false;
        }

        detector.dataEnd();

        return charsetForName(detector.getDetectedCharset());
    }

    /*
    Universal detector has trouble detecting UTF-16 without BOM.
    We know GEDCOM stream starts with "0 ", so we can use that to our
    advantage in detecting UTF-16.
     */
    private static Optional<Charset> prescreen(final byte[] b) {
        if (b[0] == 0x30 && b[1] == 0x00 && b[2] == 0x20 && b[3] == 0x00) {
            LOG.info("Pre-screen detected charset UTF-16 (LE) without BOM.");
            return Optional.of(StandardCharsets.UTF_16LE);
        }
        if (b[0] == 0x00 && b[1] == 0x30 && b[2] == 0x00 && b[3] == 0x20) {
            LOG.info("Pre-screen detected charset UTF-16 (BE) without BOM.");
            return Optional.of(StandardCharsets.UTF_16BE);
        }
        return Optional.empty();
    }

    private static Optional<Charset> charsetForName(String detected) {
        if (Objects.isNull(detected)) {
            LOG.info("Charset detector returned null.");
            return Optional.empty();
        }

        detected = detected.trim();

        if (detected.isEmpty()) {
            LOG.info("Charset detector returned empty string.");
            return Optional.empty();
        }

        try {
            LOG.info("Charset detector returned charset name: {}.", detected);
            return Optional.of(Charset.forName(detected));
        } catch (final Exception ignore) {
            LOG.warn("Charset detector returned invalid charset name: {}.", detected, ignore);
            return Optional.empty();
        }
    }
}
