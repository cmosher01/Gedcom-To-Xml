package nu.mine.mosher.gedcom.xml;

import ch.qos.logback.classic.*;
import org.slf4j.LoggerFactory;

public class LogUtil {
    public static String setLevel(final String nameLevel) {
        final Level level = Level.toLevel(nameLevel);

        if (Level.DEBUG.isGreaterOrEqual(level)) {
            System.setProperty("jaxp.debug", "1");
        } else {
            System.clearProperty("jaxp.debug");
        }

        final Logger logger = (Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
        logger.setLevel(level);
        return logger.getEffectiveLevel().toString();
    }
}
