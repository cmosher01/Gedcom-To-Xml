package nu.mine.mosher.gedcom;

import java.io.BufferedReader;
import java.util.Objects;
import java.util.regex.Pattern;

/**
 * Gets lines from the given Reader. Lines are assumed to start with
 * a number (a string of digits) in the nominal case. Any lines that
 * follow a properly numbered line that do not start with a number
 * are appended to the latest preceding numbered line.
 */
final class MissingLevelReader {
    public static final Pattern PATTERN_LINE = Pattern.compile("(?s)\\s*(\\d+)(.*?)");

    private final BufferedReader source;
    private String readahead;

    public MissingLevelReader(final BufferedReader source) {
        this.source = source;
        this.readahead = get();
    }

    public String nextLeveledLine() {
        String s = this.readahead;
        this.readahead = get();
        while (unnumbered(this.readahead)) {
            s += "\n";
            s += this.readahead;
            this.readahead = get();
        }
        return s;
    }

    private String get() {
        try {
            return this.source.readLine();
        } catch (final Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private static boolean unnumbered(final String s) {
        if (Objects.isNull(s)) {
            return false;
        }

        return !PATTERN_LINE.matcher(s).matches();
    }
}
