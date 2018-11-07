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

public class GedcomToXmlOptions extends GedcomOptions {
    public boolean fragment = false;
    public int charsMin = 60;
    public boolean pretty = false;
    public boolean escape = false;
    public boolean nodes = false;

    public void help() {
        this.help = true;
        System.err.println("Usage: gedcom-to-xml [OPTIONS] <in.ged >out.xml");
        System.err.println("Converts GEDCOM to XML.");
        System.err.println("Options:");
        System.err.println("-f, --fragment       output as XML fragment (no header)");
        System.err.println("-m, --min=chars      minimun characters to write as value");
        System.err.println("-p, --pretty         add some whitespace for prettier output");
        System.err.println("-x, --escape         escape values rather than wrapping in CDATA");
        System.err.println("-n, --nodes          nodes-only mode");
        options();
    }

    public void f() {
        fragment();
    }

    public void fragment() {
        this.fragment = true;
    }

    public void m(final String n) {
        min(n);
    }

    public void min(final String n) {
        this.charsMin = Integer.parseInt(n);
    }

    public void p() {
        pretty();
    }

    public void pretty() {
        this.pretty = true;
    }

    public void x() {
        escape();
    }

    public void escape() {
        this.escape = true;
    }

    public void n() {
        nodes();
    }

    public void nodes() {
        this.nodes = true;
    }

    public GedcomToXmlOptions verify() {
        if (this.help) {
            return this;
        }
        return this;
    }
}
