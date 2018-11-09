package nu.mine.mosher.gedcom;

import java.io.BufferedReader;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.regex.Matcher;

public class LevelLineReader implements Iterable<LevelLineReader.LevelLine> {
    private final MissingLevelReader source;

    public LevelLineReader(final BufferedReader source) {
        this.source = new MissingLevelReader(source);
    }

    @Override
    public Iterator<LevelLine> iterator() {
        return new Iter();
    }

    public static class LevelLine {
        public final int level;
        public final String value;
        public LevelLine(final int level, final String value) {
            this.level = level;
            this.value = value;
            if (this.level < -1 || 1000 <= this.level) {
                throw new IllegalStateException("Invalid level number: "+this.level+" (must be less than 1000)");
            }
        }

        public static LevelLine of(final String line) {
            if (line == null) {
                return new LevelLine(-1, null);
            }
            final Matcher matcher = MissingLevelReader.PATTERN_LINE.matcher(line);
            if (!matcher.matches()) {
                throw new IllegalStateException("pattern should always match");
            }
            return new LevelLine(Integer.parseInt(matcher.group(1)), matcher.group(2));
        }

        @Override
        public String toString() {
            return String.format("{level=%d,value=\"%s\"}", this.level, this.value);
        }
    }

    private final class Iter implements Iterator<LevelLine> {
        private LevelLine lineNext;

        public Iter() {
            prepareNext();
        }

        @Override
        public boolean hasNext() {
            return this.lineNext.value != null;
        }

        @Override
        public LevelLine next() throws NoSuchElementException {
            checkNext();
            final LevelLine returned = this.lineNext;
            prepareNext();
            return returned;
        }

        @SuppressWarnings("synthetic-access")
        private void prepareNext() {
            this.lineNext = nextLine();
        }

        private void checkNext() throws NoSuchElementException {
            if (this.lineNext.value == null) {
                throw new NoSuchElementException();
            }
        }
    }

    private LevelLine nextLine() {
        String line;
        try {
            line = this.source.nextLeveledLine();
        } catch (final Exception e) {
            throw new IllegalStateException(e);
        }
        return LevelLine.of(line);
    }
}
