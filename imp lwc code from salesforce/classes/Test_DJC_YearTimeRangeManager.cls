@isTest
public class Test_DJC_YearTimeRangeManager {

    public static testMethod void getCurrentTimeRangeEMEATest(){
        
        DJC_Region region = DJC_Region.EMEA;
        DJC_YearTimeRangeManager timeRangeManager = new DJC_YearTimeRangeManager(region);
        
        List<Date> targetDates = new List<Date>();
        targetDates.add(Date.newInstance(2016, 1, 1));
        targetDates.add(Date.newInstance(2016, 2, 1));
        targetDates.add(Date.newInstance(2016, 3, 1));
        targetDates.add(Date.newInstance(2016, 4, 1));
        targetDates.add(Date.newInstance(2016, 5, 1));
        targetDates.add(Date.newInstance(2016, 6, 1));
        targetDates.add(Date.newInstance(2016, 7, 1));
        targetDates.add(Date.newInstance(2016, 8, 1));
        targetDates.add(Date.newInstance(2016, 9, 1));
        targetDates.add(Date.newInstance(2016, 10, 1));
        targetDates.add(Date.newInstance(2016, 11, 1));
        targetDates.add(Date.newInstance(2016, 12, 1));
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getCurrentTimeRange(targetDate);
            String expectedDate = '01 - 2016';
            
            System.assertEquals(expectedDate, timeRange);
        }
        
    }
    
    public static testMethod void getCurrentTimeRangeAPACTest(){
        
        DJC_Region region = DJC_Region.APAC;
        
        DJC_YearTimeRangeManager timeRangeManager = new DJC_YearTimeRangeManager(region);
        
        List<Date> targetDates = new List<Date>();
        targetDates.add(Date.newInstance(2016, 1, 1));
        targetDates.add(Date.newInstance(2016, 2, 1));
        targetDates.add(Date.newInstance(2016, 3, 1));
        targetDates.add(Date.newInstance(2016, 4, 1));
        targetDates.add(Date.newInstance(2016, 5, 1));
        targetDates.add(Date.newInstance(2016, 6, 1));
        targetDates.add(Date.newInstance(2016, 7, 1));
        targetDates.add(Date.newInstance(2016, 8, 1));
        targetDates.add(Date.newInstance(2016, 9, 1));
        targetDates.add(Date.newInstance(2016, 10, 1));
        targetDates.add(Date.newInstance(2016, 11, 1));
        targetDates.add(Date.newInstance(2016, 12, 1));
        
        Integer expectedYear = 2015;
        Integer yearChangeFlag = 0;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getCurrentTimeRange(targetDate);
            String expectedDate = String.format('02 - {0}', new String[]{String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(yearChangeFlag == 0){
				expectedYear++;
                yearChangeFlag = 1;
            }
        }
    }
    
    public static testMethod void getCurrentTimeRangeLACATest(){
        
        DJC_Region region = DJC_Region.LACA;
        
        DJC_YearTimeRangeManager timeRangeManager = new DJC_YearTimeRangeManager(region);
        
        List<Date> targetDates = new List<Date>();
        targetDates.add(Date.newInstance(2016, 1, 1));
        targetDates.add(Date.newInstance(2016, 2, 1));
        targetDates.add(Date.newInstance(2016, 3, 1));
        targetDates.add(Date.newInstance(2016, 4, 1));
        targetDates.add(Date.newInstance(2016, 5, 1));
        targetDates.add(Date.newInstance(2016, 6, 1));
        targetDates.add(Date.newInstance(2016, 7, 1));
        targetDates.add(Date.newInstance(2016, 8, 1));
        targetDates.add(Date.newInstance(2016, 9, 1));
        targetDates.add(Date.newInstance(2016, 10, 1));
        targetDates.add(Date.newInstance(2016, 11, 1));
        targetDates.add(Date.newInstance(2016, 12, 1));
        
        Integer expectedYear = 2015;
        Integer yearChangeFlag = 0;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getCurrentTimeRange(targetDate);
            String expectedDate = String.format('02 - {0}', new String[]{String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(yearChangeFlag == 0){
				expectedYear++;
                yearChangeFlag = 1;
            }
        }
    }
    
    public static testMethod void getPreviousTimeRangeEMEATest(){
        
        DJC_Region region = DJC_Region.EMEA;
        DJC_YearTimeRangeManager timeRangeManager = new DJC_YearTimeRangeManager(region);
        
        List<Date> targetDates = new List<Date>();
        targetDates.add(Date.newInstance(2016, 1, 1));
        targetDates.add(Date.newInstance(2016, 2, 1));
        targetDates.add(Date.newInstance(2016, 3, 1));
        targetDates.add(Date.newInstance(2016, 4, 1));
        targetDates.add(Date.newInstance(2016, 5, 1));
        targetDates.add(Date.newInstance(2016, 6, 1));
        targetDates.add(Date.newInstance(2016, 7, 1));
        targetDates.add(Date.newInstance(2016, 8, 1));
        targetDates.add(Date.newInstance(2016, 9, 1));
        targetDates.add(Date.newInstance(2016, 10, 1));
        targetDates.add(Date.newInstance(2016, 11, 1));
        targetDates.add(Date.newInstance(2016, 12, 1));
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getPreviousTimeRange(targetDate);
            String expectedDate = '01 - 2015';
            
            System.assertEquals(expectedDate, timeRange);
        }
    }
    
    public static testMethod void getPreviousTimeRangeAPACTest(){
        
        DJC_Region region = DJC_Region.APAC;
        
        DJC_YearTimeRangeManager timeRangeManager = new DJC_YearTimeRangeManager(region);
        
        List<Date> targetDates = new List<Date>();
        targetDates.add(Date.newInstance(2016, 1, 1));
        targetDates.add(Date.newInstance(2016, 2, 1));
        targetDates.add(Date.newInstance(2016, 3, 1));
        targetDates.add(Date.newInstance(2016, 4, 1));
        targetDates.add(Date.newInstance(2016, 5, 1));
        targetDates.add(Date.newInstance(2016, 6, 1));
        targetDates.add(Date.newInstance(2016, 7, 1));
        targetDates.add(Date.newInstance(2016, 8, 1));
        targetDates.add(Date.newInstance(2016, 9, 1));
        targetDates.add(Date.newInstance(2016, 10, 1));
        targetDates.add(Date.newInstance(2016, 11, 1));
        targetDates.add(Date.newInstance(2016, 12, 1));
        
        Integer expectedYear = 2014;
        Integer yearChangeFlag = 0;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getPreviousTimeRange(targetDate);
            String expectedDate = String.format('02 - {0}', new String[]{String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(yearChangeFlag == 0){
				expectedYear++;
                yearChangeFlag = 1;
            }
        }
    }
    
    public static testMethod void getPreviousTimeRangeLACATest(){
        
        DJC_Region region = DJC_Region.LACA;
        
        DJC_YearTimeRangeManager timeRangeManager = new DJC_YearTimeRangeManager(region);
        
        List<Date> targetDates = new List<Date>();
        targetDates.add(Date.newInstance(2016, 1, 1));
        targetDates.add(Date.newInstance(2016, 2, 1));
        targetDates.add(Date.newInstance(2016, 3, 1));
        targetDates.add(Date.newInstance(2016, 4, 1));
        targetDates.add(Date.newInstance(2016, 5, 1));
        targetDates.add(Date.newInstance(2016, 6, 1));
        targetDates.add(Date.newInstance(2016, 7, 1));
        targetDates.add(Date.newInstance(2016, 8, 1));
        targetDates.add(Date.newInstance(2016, 9, 1));
        targetDates.add(Date.newInstance(2016, 10, 1));
        targetDates.add(Date.newInstance(2016, 11, 1));
        targetDates.add(Date.newInstance(2016, 12, 1));
        
        Integer expectedYear = 2014;
        Integer yearChangeFlag = 0;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getPreviousTimeRange(targetDate);
            String expectedDate = String.format('02 - {0}', new String[]{String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(yearChangeFlag == 0){
				expectedYear++;
                yearChangeFlag = 1;
            }
        }
    }
}