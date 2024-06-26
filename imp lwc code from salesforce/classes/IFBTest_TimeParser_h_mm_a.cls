/**
 * @author Angel Abrego <aabrego@salesforce.com>
 * @description Tests IFBTest_TimeParser_hh_mm_a class methods. These
 * validate and extract information from a time string in the "h:mm a" format
 */
@isTest
private class IFBTest_TimeParser_h_mm_a {
  
  // Assert we can intepret times in the morning
  @isTest static void validateTimeStringPositiveMorning() {
    final String TIME_STRING_TO_TEST = '9:35 AM';
    IFB_ITimeParser parser = new IFB_TimeParser_h_mm_a();
    Boolean result;
    
    Test.startTest();
      result = parser.validateTimeString(TIME_STRING_TO_TEST);
    Test.stopTest();

    System.assertEquals(true, result, 
      'Time string format should be accepted: '  + TIME_STRING_TO_TEST);
  }

  // Assert we can intepret times in the afternoon
  @isTest static void validateTimeStringPositiveAfternoon() {
    final String TIME_STRING_TO_TEST = '4:17 PM';
    IFB_ITimeParser parser = new IFB_TimeParser_h_mm_a();
    Boolean result;
    
    Test.startTest();
      result = parser.validateTimeString(TIME_STRING_TO_TEST);
    Test.stopTest();

    System.assertEquals(true, result, 
      'Time string format should be accepted: '  + TIME_STRING_TO_TEST);
  }

  // Assert we can detect time string that don't comply with the expected format
  @isTest static void validateTimeStringNegative() {
    final String TIME_STRING_TO_TEST = '21:12 hrs';
    IFB_ITimeParser parser = new IFB_TimeParser_h_mm_a();
    Boolean result;
    
    Test.startTest();
      result = parser.validateTimeString(TIME_STRING_TO_TEST);
    Test.stopTest();

    System.assertEquals(false, result, 
      'Time string format should not be accepted: '  + TIME_STRING_TO_TEST);
  }

  // Assert we can detect time string that don't comply with the expected format
  // Note that the format does NOT left padding zeroes when the "hour" is one 
  // digit
  @isTest static void validateTimeStringNegativeLeadingZero() {
    final String TIME_STRING_TO_TEST = '09:35 AM';
    IFB_ITimeParser parser = new IFB_TimeParser_h_mm_a();
    Boolean result;
    
    Test.startTest();
      result = parser.validateTimeString(TIME_STRING_TO_TEST);
    Test.stopTest();

    System.assertEquals(false, result, 
      'Leading zero in time string should not be accepted : ' +
      TIME_STRING_TO_TEST);
  }
  
  // Assert we can parse times in the morning
  @isTest static void parseTimeStringPositiveMorning() {
    final String TIME_STRING_TO_TEST = '9:35 AM';
    IFB_ITimeParser parser = new IFB_TimeParser_h_mm_a();
    Time result;
    
    Test.startTest();
      result = parser.parseTimeString(TIME_STRING_TO_TEST);
    Test.stopTest();

    System.assertEquals(9,  result.hour(), 'Unexpected hour');
    System.assertEquals(35, result.minute(), 'Unexpected minute');
    System.assertEquals(0,  result.second(), 'Unexpected second');
    System.assertEquals(0,  result.millisecond(), 'Unexpected millisecond');
  }

  // Assert we can parse times in the afternoon
  @isTest static void parseTimeStringPositiveAfternoon() {
    final String TIME_STRING_TO_TEST = '4:17 PM';
    IFB_ITimeParser parser = new IFB_TimeParser_h_mm_a();
    Time result;
    
    Test.startTest();
      result = parser.parseTimeString(TIME_STRING_TO_TEST);
    Test.stopTest();

    System.assertEquals(16,  result.hour(), 'Unexpected hour');
    System.assertEquals(17, result.minute(), 'Unexpected minute');
    System.assertEquals(0,  result.second(), 'Unexpected second');
    System.assertEquals(0,  result.millisecond(), 'Unexpected millisecond');
  }

  // Assert we can detect time string that don't comply with the expected format
  @isTest static void parseTimeStringNegative() {
    final String TIME_STRING_TO_TEST = '21:12 hrs';
    IFB_ITimeParser parser = new IFB_TimeParser_h_mm_a();
    Time result;
    
    try {
      Test.startTest();
        result = parser.parseTimeString(TIME_STRING_TO_TEST);
      Test.stopTest(); 

    } catch (IFB_TimeParserException ex) {
      System.assertEquals(Label.IFB_TimeParserException_InvalidFormat,
                          ex.getMessage(), 'Unexpected error message');

    } catch (Exception ex) {
      System.assert(false, 'Unexpected exception type' + ex);
    }   
  }
  

}