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

import nu.mine.mosher.mopper.ArgParser;

import java.io.*;
import java.nio.charset.StandardCharsets;

// Created by Christopher Alan Mosher on 2018-11-03.

public class GedcomToXml {
    private static final String DTD_FPI = "+//IDN mosher.mine.nu//DTD gedcom nodes 1.0//EN";
    private static final String DTD_URL = "https://mosher.mine.nu/dtd/gedcom/nodes.dtd";
    public static final String XML_NS = "https://mosher.mine.nu/xmlns/gedcom";

    private final BufferedWriter out;
    private final BufferedReader in;
    private int p = -1;


    public static void main(final String... args) throws IOException {
        final GedcomToXmlOptions options = new ArgParser<>(new GedcomToXmlOptions()).parse(args);
        new GedcomToXml(options).run();

        System.out.flush();
        System.err.flush();
    }


    private GedcomToXml(final GedcomToXmlOptions options) {
        this.in = new BufferedReader(new InputStreamReader(new FileInputStream(FileDescriptor.in), options.encoding));
        this.out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(FileDescriptor.out), StandardCharsets.UTF_8));
    }

    private void run() throws IOException {
        try {
            start();
            int lineNumber = 1;
            for (final LevelLineReader.LevelLine line : new LevelLineReader(this.in)) {
                processLine(line, lineNumber++);
            }
            finish();

            this.out.flush();
        } finally {
            try {
                this.out.close();
            } catch (Throwable e) {
                e.printStackTrace();
            }
            try {
                this.in.close();
            } catch (Throwable e) {
                e.printStackTrace();
            }
        }
    }

    private void start() throws IOException {
        this.out.write("<?xml version=\"1.1\" encoding=\"UTF-8\" standalone=\"no\"?>\n");
        this.out.write(String.format("<!DOCTYPE gedcom:nodes PUBLIC \"%s\" \"%s\">\n", DTD_FPI, DTD_URL));
        this.out.write(String.format("<gedcom:nodes xmlns:gedcom=\"%s\">\n", XML_NS));
    }

    private void processLine(final LevelLineReader.LevelLine line, int lineNumber) throws IOException {
        final int pop = this.p + 1 - line.level;
        if (pop < 0) {
            System.err.println(String.format("Illegal level (%d) found at line %d. Generating nodes (without tags) to compensate.", line.level, lineNumber));
            for (int i = 0; i < this.p + 1; ++i) {
                this.out.write("</gedcom:node>\n");
            }
            for (int i = 0; i < line.level; ++i) {
                this.out.write("<gedcom:node gedcom:line-number=\"" + lineNumber + "\">\n");
                this.out.write("<gedcom:value/>\n");
            }
        } else {
            for (int i = 0; i < pop; ++i) {
                this.out.write("</gedcom:node>\n");
            }
        }
        this.p = line.level;
        this.out.write("<gedcom:node gedcom:line-number=\"" + lineNumber + "\">\n");
        this.out.write("<gedcom:value>");
        this.out.write(cdata(line.value));
        this.out.write("</gedcom:value>\n");
    }

    private void finish() throws IOException {
        final int pop = this.p + 1;
        for (int i = 0; i < pop; ++i) {
            this.out.write("</gedcom:node>\n");
        }
        this.out.write("</gedcom:nodes>\n");
    }

    private String cdata(String value) {
        return "<![CDATA[" + cdataEscape(value) + "]]>";
    }

    private String cdataEscape(String value) {
        return value.replace("]]>", "]]]]><![CDATA[>");
    }
}
