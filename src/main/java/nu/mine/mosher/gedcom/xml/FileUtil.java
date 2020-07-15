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

import java.io.*;
import java.time.*;
import java.time.format.DateTimeFormatter;

class FileUtil {
    /**
     * Generate output file corresponding to input file:
     *
     *     path/to/file.ged --> path/to/file.xml
     *
     * But if output file already exists, then instead:
     *
     *     path/to/file.ged --> path/to/file.yyyyMMdd_HHmmss_nnnnnnnnn.xml
     *
     * @param fileIn input (.ged) file
     * @return output (.xml) file
     */
    public static File outFileFor(final File fileIn) throws IOException {
        final File dir = fileIn.getParentFile();

        final String[] ss = fileIn.getName().split("\\.(?=[^.]+$)");
        String s = ss[0];
        if (!s.endsWith(".")) {
            s += ".";
        }

        File newfile = new File(dir, s + "xml").getCanonicalFile();
        if (newfile.exists()) {
            newfile = uniquify(dir, s, "xml").getCanonicalFile();
        }
        return newfile;
    }

    private static File uniquify(final File dir, final String s, final String typ) {
        final String uniq = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss_nnnnnnnnn").withZone(ZoneId.of("UTC")).format(Instant.now());
        return new File(dir, s + uniq + "." + typ);
    }
}
