package nu.mine.mosher.gedcom;

import nu.mine.mosher.collection.TreeNode;
import nu.mine.mosher.gedcom.exception.InvalidLevel;
import nu.mine.mosher.mopper.ArgParser;
import org.owasp.encoder.Encode;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import static nu.mine.mosher.logging.Jul.log;

// Created by Christopher Alan Mosher on 2017-09-16

public class GedcomToXml implements Gedcom.Processor {
    private final GedcomToXmlOptions options;
    private final BufferedWriter out;

    public static void main(final String... args) throws InvalidLevel, IOException {
        log();
        final GedcomToXmlOptions options = new ArgParser<>(new GedcomToXmlOptions()).parse(args).verify();
        new Gedcom(options, new GedcomToXml(options)).main();
        System.out.flush();
        System.err.flush();
    }



    private GedcomToXml(final GedcomToXmlOptions options) {
        this.options = options;
        this.out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(FileDescriptor.out), StandardCharsets.UTF_8));
    }



    @Override
    public boolean process(final GedcomTree tree) {
        new GedcomConcatenator(tree).concatenate();
        try {
            if (!this.options.fragment) {
                outHead();
            }
            convertFrom(tree.getRoot(), 0);
            this.out.flush();
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
        return false;
    }

    private void outHead() throws IOException {
        this.out.write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>");
        nl();
    }

    private void convertFrom(final TreeNode<GedcomLine> node, final int indent) throws IOException {
        outNode(node, indent);
        for (final TreeNode<GedcomLine> child : node) {
            convertFrom(child, indent+1);
        }
        closeNode(node, indent);
    }

    private void outNode(TreeNode<GedcomLine> node, int indent) throws IOException {
        final GedcomLine line = node.getObject();
        indent(indent);
        this.out.write("<"+ tag(line));
        if (Objects.isNull(line)) {
            this.out.write(" xmlns:gedcom=\"http://mosher.mine.nu/xmlns/gedcom\"");
            this.out.write(" xmlns:xlink=\"http://www.w3.org/1999/xlink\"");
        } else {
            if (line.hasID()) {
                this.out.write(" xml:id=\"" + enc(line.getID()) + "\"");
            }
            if (line.isPointer()) {
                this.out.write(" xlink:href=\"#" + enc(line.getPointer()) + "\"");
            }
            final String value = line.getValue();
            if (!value.isEmpty() && asAttr(value)) {
                this.out.write(" gedcom:value=\"" + enc(value) + "\"");
            }
        }
        this.out.write(">");
        nl();
        if (Objects.nonNull(line)) {
            final String value = line.getValue();
            if (!value.isEmpty() && !asAttr(value)) {
                indent(indent+1);
                this.out.write(this.options.escape ? enc(value) : cdata(value));
                nl();
            }
        }
    }

    private boolean asAttr(String value) {
        boolean small = value.length() < this.options.charsMin;
        boolean hasNewlines = value.contains("\n");
        return small && ! hasNewlines;
    }

    private String cdata(String value) {
        return "<![CDATA["+cdataEscape(value)+"]]>";
    }

    private String cdataEscape(String value) {
        return value.replace("]]>", "]]]]><![CDATA[>");
    }

    private void indent(int indent) throws IOException {
        if (this.options.pretty) {
            for (int i = 0; i < indent; ++i) {
                this.out.write("    ");
            }
        }
    }

    private void nl() throws IOException {
        if (this.options.pretty) {
            this.out.newLine();
        }
    }

    private void closeNode(final TreeNode<GedcomLine> node, int indent) throws IOException {
        final GedcomLine line = node.getObject();
        indent(indent);
        this.out.write("</"+ tag(line)+">");
        nl();
    }

    private String tag(final GedcomLine line) {
        return "gedcom:"+(Objects.isNull(line) ? "GED" : enc(line.getTagString()));
    }

    private static String enc(String value) {
        return Encode.forXml(value);
    }
}
