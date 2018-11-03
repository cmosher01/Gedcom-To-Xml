package nu.mine.mosher.gedcom;

public class GedcomToXmlOptions extends GedcomOptions {
    public boolean fragment = false;
    public int charsMin = 60;
    public boolean pretty = false;
    public boolean escape = false;

    public void help() {
        this.help = true;
        System.err.println("Usage: gedcom-to-xml [OPTIONS] <in.ged >out.xml");
        System.err.println("Converts GEDCOM to XML.");
        System.err.println("Options:");
        System.err.println("-f, --fragment       output as XML fragment (no header)");
        System.err.println("-m, --min=chars      minimun characters to write as value");
        System.err.println("-p, --pretty         add some whitespace for prettier output");
        System.err.println("-x, --escape         escape values rather than wrapping in CDATA");
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

    public GedcomToXmlOptions verify() {
        if (this.help) {
            return this;
        }
        return this;
    }
}
