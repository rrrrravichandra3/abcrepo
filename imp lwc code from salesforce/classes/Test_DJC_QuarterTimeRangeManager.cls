@isTest
public class Test_DJC_QuarterTimeRangeManager {

    public static testMethod void getCurrentTimeRangeAPACTest(){
        
        DJC_Region region = DJC_Region.APAC;
        
        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(region);
        
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
        
        Integer expectedQuarter = 4;
        Integer expectedYear = 2015;
        Integer cycleCounter = 2;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getCurrentTimeRange(targetDate);
            String expectedDate = String.format('Q{0} - {1}', new String[]{String.valueOf(expectedQuarter), String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(cycleCounter == 2){
                cycleCounter = 0;
                if(expectedQuarter == 4){
                    expectedQuarter = 1;
                    expectedYear++;
                }else{
                    expectedQuarter++;
                }
            }else{
                cycleCounter++;
            }
        }
    }
    
    public static testMethod void getCurrentTimeRangeEMEATest(){
        
        DJC_Region region = DJC_Region.EMEA;
        
        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(region);
        
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
        
        Integer expectedQuarter = 1;
        Integer expectedYear = 2016;
        Integer cycleCounter = 0;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getCurrentTimeRange(targetDate);
            String expectedDate = String.format('Q{0} - {1}', new String[]{String.valueOf(expectedQuarter), String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(cycleCounter == 2){
                cycleCounter = 0;
                    expectedQuarter++;
            }else{
                cycleCounter++;
            }
        }
    }
    
    public static testMethod void getCurrentTimeRangeLACATest(){
        
        DJC_Region region = DJC_Region.LACA;
        
        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(region);
        
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
        
        Integer expectedQuarter = 4;
        Integer expectedYear = 2015;
        Integer cycleCounter = 2;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getCurrentTimeRange(targetDate);
            String expectedDate = String.format('Q{0} - {1}', new String[]{String.valueOf(expectedQuarter), String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(cycleCounter == 2){
                cycleCounter = 0;
                if(expectedQuarter == 4){
                    expectedQuarter = 1;
                    expectedYear++;
                }else{
                    expectedQuarter++;
                }
            }else{
                cycleCounter++;
            }
        }
    }
    
    public static testMethod void getPreviousTimeRangeEMEATest(){
        
        DJC_Region region = DJC_Region.EMEA;
        
        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(region);
        
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
        
        Integer expectedQuarter = 4;
        Integer expectedYear = 2015;
        Integer cycleCounter = 0;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getPreviousTimeRange(targetDate);
            String expectedDate = String.format('Q{0} - {1}', new String[]{String.valueOf(expectedQuarter), String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(cycleCounter == 2){
                cycleCounter = 0;
                if(expectedQuarter == 4){
                    expectedQuarter = 1;
                    expectedYear++;
                }else{
                    expectedQuarter++;
                }
            }else{
                cycleCounter++;
            }
        }
    }
    
    public static testMethod void getPreviousTimeRangeAPACTest(){
        
        DJC_Region region = DJC_Region.APAC;
        
        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(region);
        
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
        
        Integer expectedQuarter = 3;
        Integer expectedYear = 2015;
        Integer cycleCounter = 2;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getPreviousTimeRange(targetDate);
            String expectedDate = String.format('Q{0} - {1}', new String[]{String.valueOf(expectedQuarter), String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(cycleCounter == 2){
                cycleCounter = 0;
                if(expectedQuarter == 4){
                    expectedQuarter = 1;
                    expectedYear++;
                }else{
                    expectedQuarter++;
                }
            }else{
                cycleCounter++;
            }
        }
    }
    
    public static testMethod void getPreviousTimeRangeLACATest(){
        
        DJC_Region region = DJC_Region.LACA;
        
        DJC_QuarterTimeRangeManager timeRangeManager = new DJC_QuarterTimeRangeManager(region);
        
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
        
        Integer expectedQuarter = 3;
        Integer expectedYear = 2015;
        Integer cycleCounter = 2;
        
        for(Date targetDate : targetDates){
            
            String timeRange = timeRangeManager.getPreviousTimeRange(targetDate);
            String expectedDate = String.format('Q{0} - {1}', new String[]{String.valueOf(expectedQuarter), String.valueOf(expectedYear)});
            
            System.assertEquals(expectedDate, timeRange);
            
            if(cycleCounter == 2){
                cycleCounter = 0;
                if(expectedQuarter == 4){
                    expectedQuarter = 1;
                    expectedYear++;
                }else{
                    expectedQuarter++;
                }
            }else{
                cycleCounter++;
            }
        }
    }
    
}