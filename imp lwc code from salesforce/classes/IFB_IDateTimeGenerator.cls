/**
 * @author Angel Abrego <aabrego@salesforce.com>
 * @date 2017-09-05
 * 
 * @description Generates DateTime instances given the Year, Month, Day, Time 
 * and TimeZone
 */
public interface IFB_IDateTimeGenerator {

	/**
   * @description creates a new DateTime instance from the perspective of a
   * specific TimeZone
   * @param dateYear      Year (from the perspective provided TimeZone)
   * @param dateMonth     Month (from the perspective provided TimeZone)
   * @param dateDay       Day (from the perspective provided TimeZone)
   * @param timeString String representing the time component. (from the 
   * perspective provided TimeZone) Accepted formats depend on specific 
   * implementation.
   * @param timeZoneId    Indentifier of the Time Zone to be used 
   * to interpret the other Date/Time parameters. Eg. "America/Los_Angeles", 
   * "Asia/Tokyo". Only Time Zone Ids suported by salesforce.com are accepted
   * (See TimeZone.getTimeZone() APEX method)
   * @return a DateTime instance that corresponds to point in time indicated
   * in the patameters.
   */
	DateTime newInstanceTimeZone(Integer dateYear,
                               Integer dateMonth,
                               Integer dateDay,
                               String  timeString,
                               String  timeZoneId);
}