/**
 * @author Angel Abrego <aabrego@salesforce.com>
 * @date 2017-09-05
 * 
 * @description Generates DateTime instances given the Year, Month, Day, Time 
 * and TimeZone. Interprets the Time Component string to be in the "hh:mm s"
 * format
 */
public with sharing class IFB_DateTimeGenerator implements 
                                                IFB_IDateTimeGenerator {

  private final IFB_ITimeParser timeStrategy;
  public IFB_DateTimeGenerator() {
    this.timeStrategy = new IFB_TimeParser_h_mm_a();
  }

  public DateTime newInstanceTimeZone(Integer dateYear,
                                      Integer dateMonth,
                                      Integer dateDay,
                                      String  timeString,
                                      String  timeZoneId) {
    Datetime dt;

    if (!String.isEmpty(timeZoneId) && !String.isEmpty(timeString)) {
      this.newInstanceTimeZoneInputValidation(timeZoneId);
    
      Time timeComponent = this.timeStrategy.parseTimeString(timeString);
      DateTime dtGMT = Datetime.newInstanceGmt(dateYear, 
                                               dateMonth,
                                               dateDay,
                                               timeComponent.hour(),
                                               timeComponent.minute(),
                                               0);

      TimeZone tz = TimeZone.getTimeZone(timeZoneId);
      Set<Integer> offsets = new Set<Integer>();
      offsets.add(tz.getOffset(dtGMT));
      offsets.add(tz.getOffset(dtGMT.addDays(-1)));
      offsets.add(tz.getOffset(dtGMT.addDays(1)));

      for (Integer offset : offsets) {
        dt = dtGMT.addSeconds((-1)*(offset/1000));
        String dtString    = dt.format('MM/dd/yyyy h:mm a', timeZoneId);
        String dtGMTString = dtGMT.format('MM/dd/yyyy h:mm a','GMT');
    
        if(dtString.equals(dtGMTString)) {
          break;
        }
      }

    } else {
      // In case of any problem interpreting the Time String/Time Zone, set the time of midnight that day.
      dt = DateTime.newInstance(dateYear, dateMonth, dateDay);   
      dt = DateTime.newInstance(dt.date(), System.Now().time());
    }
    
    return dt;
  }

	private void newInstanceTimeZoneInputValidation(String timeZoneId) {
		
    TimeZone tz = TimeZone.getTimeZone(timeZoneId);
    if (!timeZoneId.equals(tz.getID())) {
			throw new IFB_DateTimeGeneratorException('Invalid Time Zone: ' + timeZoneId + '. Expected: ' + tz.getID());
		}
	}
	
}