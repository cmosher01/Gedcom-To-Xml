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


import nu.mine.mosher.gnopt.Gnopt;
import org.slf4j.bridge.SLF4JBridgeHandler;


public class GedcomToXml {
    static {
        SLF4JBridgeHandler.removeHandlersForRootLogger();
        SLF4JBridgeHandler.install();
        java.util.logging.Logger.getLogger("").setLevel(java.util.logging.Level.FINEST);
    }

    public static void main(final String... args) throws Gnopt.InvalidOption {
        final GedcomToXmlCli cli = Gnopt.process(GedcomToXmlCli.class, args);

        if (!cli.help) {
            cli.execute();
        }

        System.out.flush();
        System.err.flush();
    }
}
