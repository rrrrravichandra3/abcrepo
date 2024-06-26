@isTest
public class Test_WellnessTimeRangeManager {

    public static testMethod void foundationEducationTimeRangeManagerTest(){
        
        DJC_YearEducationTimeRangeManager_Fndt timeRangeManager = new DJC_YearEducationTimeRangeManager_Fndt(DJC_Region.EMEA);

        //Test period range: since 01 of January until 31 of December
        Date testDate = Date.newInstance(2016, 12, 31);
        System.assertEquals('2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('2015', timeRangeManager.getPreviousTimeRange(testDate));
        
        testDate = Date.newInstance(2016, 1, 1);
        System.assertEquals('2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('2015', timeRangeManager.getPreviousTimeRange(testDate));
     
        //Test isDateMoreThanOnePeriodBack method
        testDate = System.today();
        testDate = testDate.addYears(-1);
        
        System.assertEquals(true, timeRangeManager.isDateMorethanOnePeriodBack(testDate));
        
        //Test getMinDateInCurrentPeriod method
        Date minDateInCurrentPeriod = timeRangeManager.getMinDateInCurrentPeriod();
        testDate = System.today();
        
        System.assertEquals(1, minDateInCurrentPeriod.day());
        System.assertEquals(1, minDateInCurrentPeriod.month());
        System.assertEquals(testDate.year(), minDateInCurrentPeriod.year());
        
        //Test getMaxDateInCurrentPeriod method
        Date maxDateInCurrentPeriod = timeRangeManager.getMaxDateInCurrentPeriod();
        testDate = System.today();
        
        System.assertEquals(31, maxDateInCurrentPeriod.day());
        System.assertEquals(12, maxDateInCurrentPeriod.month());
        System.assertEquals(testDate.year(), maxDateInCurrentPeriod.year());
    }
    
    public static testMethod void foundationWellnessTimeRangeManagerTest(){
        
        DJC_WellnessTimeRangeManager_Fndt timeRangeManager = new DJC_WellnessTimeRangeManager_Fndt(DJC_Region.EMEA);

        Date testDate = Date.newInstance(2016, 1, 1);
        System.assertEquals('Q1 - 2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('Q4 - 2015', timeRangeManager.getPreviousTimeRange(testDate));
        
        testDate = Date.newInstance(2016, 3, 31);
        System.assertEquals('Q1 - 2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('Q4 - 2015', timeRangeManager.getPreviousTimeRange(testDate));
        
        testDate = Date.newInstance(2016, 4, 1);
        System.assertEquals('Q2 - 2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('Q1 - 2016', timeRangeManager.getPreviousTimeRange(testDate));
        
        testDate = Date.newInstance(2016, 6, 30);
        System.assertEquals('Q2 - 2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('Q1 - 2016', timeRangeManager.getPreviousTimeRange(testDate));
        
        testDate = Date.newInstance(2016, 7, 1);
        System.assertEquals('Q3 - 2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('Q2 - 2016', timeRangeManager.getPreviousTimeRange(testDate));
        
        testDate = Date.newInstance(2016, 9, 30);
        System.assertEquals('Q3 - 2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('Q2 - 2016', timeRangeManager.getPreviousTimeRange(testDate));
        
        testDate = Date.newInstance(2016, 10, 1);
        System.assertEquals('Q4 - 2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('Q3 - 2016', timeRangeManager.getPreviousTimeRange(testDate));
        
        testDate = Date.newInstance(2016, 12, 31);
        System.assertEquals('Q4 - 2016', timeRangeManager.getCurrentTimeRange(testDate));
        System.assertEquals('Q3 - 2016', timeRangeManager.getPreviousTimeRange(testDate));
        
        //Test isDateMoreThanOnePeriodBack method
        testDate = System.today();
        testDate = testDate.addMonths(-6);
        
        System.assertEquals(true, timeRangeManager.isDateMorethanOnePeriodBack(testDate));
    }
}