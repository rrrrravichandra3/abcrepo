/**
 * @author Angel Abrego <aabrego@salesforce.com>
 * @date 2017-09-05
 * 
 * @description Implementation of the "IFB_ITimeParser" interface that
 * parses time strings in the "h:mm a" format (Eg. "9:45 AM", "4:50 PM")
 */
public with sharing class IFB_TimeParser_h_mm_a implements IFB_ITimeParser {

  private static final String TIME_STRING_REGEX;
  private static final Pattern timeRegexPattern;

  static {
    // "h:mm a" format
    TIME_STRING_REGEX = '^([0-9]|1[0-2]):([0-5][0-9]) (AM|PM)$';
    timeRegexPattern = Pattern.compile(TIME_STRING_REGEX);
  }

  /**
   * @description Implementation of the "IFB_ITimeParser" interface. 
   * Uses the regex expression to validate time in the "h:mm a" format
   */
  public Boolean validateTimeString(String timeString) {
      Matcher tMatcher = timeRegexPattern.matcher(timeString);
      
      // Assert that entry matches the "h:mm a" format
      if (tMatcher.matches() && tMatcher.hitEnd()) {
        return true;
      } else {
        return false;
      }
  }

  /**
   * @description Implementation of the "IFB_ITimeParser" interface. 
   * Uses the regex expression to generate to extract information from 
   * an time string in the "h:mm a" format, and generate a Time instance.
   */
  public Time parseTimeString(String timeString) {
    Time t;
    Matcher tMatcher = timeRegexPattern.matcher(timeString);

    if (tMatcher.matches() && tMatcher.hitEnd()) {    
        Integer hour = Integer.valueOf(tMatcher.group(1));
        Integer minutes = Integer.valueOf(tMatcher.group(2));
        t = Time.newInstance(hour, minutes, 0, 0);

        if (tMatcher.group(3) == 'PM' && (hour != 12)) {
          t = t.addHours(12);
        }
  
    } else {
      new IFB_TimeParserException(Label.IFB_TimeParserException_InvalidFormat);
    }

    return t;
  }
}