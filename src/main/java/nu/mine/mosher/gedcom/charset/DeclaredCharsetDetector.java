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

import org.mozilla.universalchardet.UnicodeBOMInputStream;
import org.slf4j.*;

import java.io.*;
import java.nio.charset.Charset;
import java.util.*;
import java.util.function.Supplier;
import java.util.regex.*;

/**
 * Reads a GEDCOM format input stream to determine character set encoding of the stream,
 * based on the "CHAR charset" entry in the HEAD.
 *
 * The input stream's location is marked before reading, and reset afterwards.
 *
 * There is a "catch-22" problem, in that we need to presume some character encoding in order
 * to read the stream to interpret the "CHAR" entry itself. Pass this in as the charsetBestGuess
 * parameter.
 */
public class DeclaredCharsetDetector {
    public static Optional<Charset> detect(final BufferedInputStream gedcomStream, final Charset charsetBestGuess) throws IOException {
        final int cBytesToCheck = 32 * 1024;
        gedcomStream.mark(cBytesToCheck);
        try {
            return tryDetect(gedcomStream, cBytesToCheck, charsetBestGuess);
        } finally {
            gedcomStream.reset();
        }
    }





    private static final Logger LOG = LoggerFactory.getLogger(DeclaredCharsetDetector.class);



    private static Optional<Charset> tryDetect(final BufferedInputStream gedcomStream, final int cBytesToCheck, final Charset charsetBestGuess) throws IOException {
        final String rawCharSetName = readCharsetNameDeclared(gedcomStream, cBytesToCheck, charsetBestGuess);
        final String mappedCharSetName = interpretHeadCharSetName(rawCharSetName);

        String useCharSetName;
        if (mappedCharSetName.isEmpty()) {
            LOG.warn("Did not recognize declared charset name \"{}\" as GEDCOM or de facto standard.", rawCharSetName);
            useCharSetName = rawCharSetName;
        } else {
            LOG.info("Interpreted declared charset name as: {}.", mappedCharSetName);
            useCharSetName = mappedCharSetName;
        }

        try {
            return Optional.of(Charset.forName(useCharSetName));
        } catch (final Exception e) {
            LOG.warn("Invalid charset name: {}.", useCharSetName, e);
            return Optional.empty();
        }
    }

    private static String readCharsetNameDeclared(final BufferedInputStream gedcomStream, final int cBytesToCheck, final Charset charsetBestGuess) throws IOException {
        // Small finite state machine to find (first) CHAR under (first) HEAD record
        final Pattern HEAD_LINE = Pattern.compile("0\\s+HEAD.*");
        final Pattern CHAR_LINE = Pattern.compile("1\\s+CHAR\\s+(.*)");
        final Pattern REC0_LINE = Pattern.compile("0\\s+.*");
        final int START = 0;
        final int IN_HEAD = 1;
        final int OUT_HEAD = 2;

        final BufferedReader gedcomReader = createNiceLineReader(gedcomStream, charsetBestGuess);
        int sane = cBytesToCheck / 2; // just to be safe
        int state = START;
        for (String line = gedcomReader.readLine(); line != null && sane > 0; line = gedcomReader.readLine()) {
            sane -= (line.length()+2);
            line = line.trim();
            switch (state) {
                case START: {
                    if (HEAD_LINE.matcher(line).matches()) {
                        LOG.info("Found HEAD line. Good.");
                        state = IN_HEAD;
                    }
                }
                break;
                case IN_HEAD: {
                    if (REC0_LINE.matcher(line).matches()) {
                        state = OUT_HEAD;
                    } else {
                        final Matcher matcher = CHAR_LINE.matcher(line);
                        if (matcher.matches()) {
                            final String charsetNameDeclared = matcher.group(1).trim();
                            LOG.info("Found CHAR line with value: \"{}\".", charsetNameDeclared);
                            return charsetNameDeclared;
                        }
                    }
                }
                break;
                case OUT_HEAD: {
                    LOG.warn("Could not find CHAR line.");
                    return "";
                }
            }
        }
        LOG.warn("Could not find HEAD line.");
        return "";
    }

    private static BufferedReader createNiceLineReader(final BufferedInputStream gedcomStream, final Charset charsetBestGuess) throws IOException {
        return new BufferedReader(new InputStreamReader(new UnicodeBOMInputStream(gedcomStream), charsetBestGuess));
    }

    private static final Map<String, String> MAP_KNOWN_CHAR_SET_NAMES = ((Supplier<Map<String, String>>)() -> {
        final Map<String, String> m = new HashMap<>();

        // Tamura Jones, "GEDCOM Character Encodings", Modern Software Experience 2014-08-26
        // (https://www.tamurajones.net/GEDCOMCharacterEncodings.xhtml : accessed 2020-07-13).

        m.put("IBMPC", "Cp437");
        m.put("IBM-PC", "Cp437");
        m.put("IBM", "Cp437");
        m.put("PC", "Cp437");
        m.put("OEM", "Cp437");

        m.put("MSDOS", "Cp850");
        m.put("MS-DOS", "Cp850");
        m.put("DOS", "Cp850");
        m.put("IBM DOS", "Cp850");

        m.put("ANSI", "windows-1252");
        m.put("WINDOWS", "windows-1252");
        m.put("WIN", "windows-1252");
        m.put("IBM WINDOWS", "windows-1252");
        m.put("IBM_WINDOWS", "windows-1252");

        m.put("ASCII", "windows-1252"); // 5.5.1, 5.5
        m.put("CP1252", "windows-1252");

        m.put("ISO-8859-1", "windows-1252");
        m.put("ISO8859-1", "windows-1252");
        m.put("ISO-8859", "windows-1252");
        m.put("LATIN1", "windows-1252");

        m.put("MAC", "MacRoman");
        m.put("MACINTOSH", "MacRoman");

        m.put("UNICODE", "UTF-16"); // 5.5.1, 5.5
        m.put("UTF-8", "UTF-8"); // 5.5.1

        m.put("ANSEL", "x-gedcom-ansel"); // 5.5.1, 5.5

        return Collections.unmodifiableMap(m);
    }).get();

    private static String interpretHeadCharSetName(final String headCharSetName) {
        // TODO more research to extend this list, possibly with some parsing and smart logic
        // possibly "massaging" the name to a recognizable standard
        return Objects.toString(MAP_KNOWN_CHAR_SET_NAMES.get(headCharSetName.toUpperCase()), "");
    }
}
