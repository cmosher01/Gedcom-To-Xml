/*

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    Copyright © 2018, by Christopher Alan Mosher, Shelton, Connecticut, USA.

    <https://mosher.mine.nu/>

 */

package nu.mine.mosher.gedcom;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

class GedcomToXmlOptions {
    public Charset encoding = StandardCharsets.UTF_8;

    public void help() {
        System.out.println("Usage: gedcom-to-xml [OPTIONS] <in.ged >out.xml");
        System.out.println("Converts GEDCOM to XML. Does only minimal processing or parsing.");
        System.out.println("Options:");
        String s = String.join("\n",
            "",
            "-h, --help          Print this help",
            "-e, --encoding=ENC  Character encoding of GEDCOM file (default: UTF-8)"
        );
    }

    public void h() {
        help();
    }

    public void encoding(final String encoding) {
        this.encoding = Charset.forName(encoding);
    }

    public void e(final String encoding) {
        encoding(encoding);
    }
}
