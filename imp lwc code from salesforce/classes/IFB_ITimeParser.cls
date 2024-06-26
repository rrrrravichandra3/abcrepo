/**
 * @author Angel Abrego <aabrego@salesforce.com>
 * @date 2017-09-05
 * 
 * @description Parses strings that represents time. The expected string format
 * is up to the implementation class.
 */
public interface IFB_ITimeParser {

  /**
   * @description validates that a string represents a time in the supported 
   * format of the implementation class
   * @param timeString value to be validated ((E.g "9:35 AM", "23:40", 
   * "15:35 hrs") the accepted string format dependens on the implementation 
   * class
   * @return true if string matches string format, false if not.
   */
  Boolean validateTimeString(String timeString);

  /**
   * @description parses an string that represents the time component of 
   * datetime variable
   * @param timeString value to be parsed (E.g "9:35 AM", "23:40", "15:35 hrs")
   * the accepted string format dependens on the implementation class
   * @return a Time instance that corresponds to the parsed string
   */
  Time parseTimeString(String timeString);
}