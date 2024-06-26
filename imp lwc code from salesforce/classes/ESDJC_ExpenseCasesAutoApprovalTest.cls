@isTest
public class ESDJC_ExpenseCasesAutoApprovalTest {

    /*EMEA*/
    public static testMethod void testAutoApprovalEMEASunday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 1, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.EMEA, createdDate);
    }
    
    public static testMethod void testAutoApprovalEMEAMonday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 2, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.EMEA, createdDate);
    }
    
    public static testMethod void testAutoApprovalEMEATuesday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 3, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.EMEA, createdDate);
    }
    
    public static testMethod void testAutoApprovalEMEAWednesday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 4, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.EMEA, createdDate);
    }
    
    public static testMethod void testAutoApprovalEMEAThursday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 5, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.EMEA, createdDate);
    }    
    
    public static testMethod void testAutoApprovalEMEAFriday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 6, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.EMEA, createdDate);
    }
    
    public static testMethod void testAutoApprovalEMEASaturday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 7, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.EMEA, createdDate);
    }
    

    /*APAC*/
    public static testMethod void testAutoApprovalAPACSunday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 1, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.APAC, createdDate);
    }
    
    public static testMethod void testAutoApprovalAPACMonday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 2, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.APAC, createdDate);
    }
    
    public static testMethod void testAutoApprovalAPACTuesday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 3, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.APAC, createdDate);
    }
    
    public static testMethod void testAutoApprovalAPACWednesday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 4, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.APAC, createdDate);
    }
    
    public static testMethod void testAutoApprovalAPACThursday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 5, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.APAC, createdDate);
    }    
    
    public static testMethod void testAutoApprovalAPACFriday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 6, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.APAC, createdDate);
    }
    
    public static testMethod void testAutoApprovalAPACSaturday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 7, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.APAC, createdDate);
    }
    
    
    /*LACA*/
    public static testMethod void testAutoApprovalLACASunday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 1, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.LACA, createdDate);
    }
    
    public static testMethod void testAutoApprovalLACAMonday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 2, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.LACA, createdDate);
    }
    
    public static testMethod void testAutoApprovalLACATuesday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 3, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.LACA, createdDate);
    }
    
    public static testMethod void testAutoApprovalLACAWednesday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 4, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.LACA, createdDate);
    }
    
    public static testMethod void testAutoApprovalLACAThursday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 5, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.LACA, createdDate);
    }    
    
    public static testMethod void testAutoApprovalLACAFriday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 6, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.LACA, createdDate);
    }
    
    public static testMethod void testAutoApprovalLACASaturday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 7, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.LACA, createdDate);
    }
    
    /*America*/
    public static testMethod void testAutoApprovalAMERSunday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 1, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.AMERUSA, createdDate);
    }
    
    public static testMethod void testAutoApprovalAMERMonday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 2, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.AMERUSA, createdDate);
    }
    
    public static testMethod void testAutoApprovalAMERTuesday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 3, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.AMERUSA, createdDate);
    }
    
    public static testMethod void testAutoApprovalAMERWednesday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 4, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.AMERUSA, createdDate);
    }
    
    public static testMethod void testAutoApprovalAMERThursday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 5, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.AMERUSA, createdDate);
    }    
    
    public static testMethod void testAutoApprovalAMERFriday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 6, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.AMERUSA, createdDate);
    }
    
    public static testMethod void testAutoApprovalAMERSaturday(){
        DateTime createdDate = Datetime.newInstance(2017, 1, 7, Integer.valueOf(Math.random() * 24), 30, 0);
        testExpectedDateOfApprovalCalculation(DJC_Division.AMERUSA, createdDate);
    }
    
    private static void testExpectedDateOfApprovalCalculation(DJC_Division division, Datetime createdDate){
        
        Test.startTest();
        
        Test_Wellness_Util.testDate = createdDate;            
        Case c = Test_Wellness_Util.createEdCaseByRegion(division.name);
        
        INSERT c;
		
        Test.stopTest();
        
        c = [SELECT DJC_reimb_expected_date_of_approval__c FROM Case WHERE Id = :c.Id];

        assertExpectedDateResult(createdDate, c.DJC_reimb_expected_date_of_approval__c, division);
    }
    
    private static void assertExpectedDateResult(Datetime createdDate, Datetime expectedDateOfApproval, DJC_Division division){
        
        String createdDateDay = createdDate.format('EEEE', division.timeZoneKey);
        String expectedDateDay = expectedDateOfApproval.format('EEEE', division.timeZoneKey);
        
        if(createdDateDay == 'Monday'){
            System.assertEquals('Tuesday', expectedDateDay, 'Wrong approval day');
        }else if(createdDateDay == 'Tuesday'){
            System.assertEquals('Wednesday', expectedDateDay, 'Wrong approval day');
        }else if(createdDateDay == 'Wednesday'){
            System.assertEquals('Thursday', expectedDateDay, 'Wrong approval day');
        }else if(createdDateDay == 'Thursday'){
            System.assertEquals('Friday', expectedDateDay, 'Wrong approval day');
        }else if(createdDateDay == 'Friday'){
            System.assertEquals('Monday', expectedDateDay, 'Wrong approval day');
        }else if(createdDateDay == 'Saturday'){
            System.assertEquals('Monday', expectedDateDay, 'Wrong approval day');
        }else if(createdDateDay == 'Sunday'){
            System.assertEquals('Monday', expectedDateDay, 'Wrong approval day');
        }
		
        Integer createdDateHour = Integer.valueOf(createdDate.format('H', division.timeZoneKey));
        Integer expectedDateHour = Integer.valueOf(expectedDateOfApproval.format('H', division.timeZoneKey));
        
        if(createdDateHour < 13){
            System.assert(expectedDateHour >= 9 && expectedDatehour <= 12, 'Approval hour must be between 09:00 AM and 12:00 PM');
        }else{
            System.assert(expectedDateHour >= 13 && expectedDatehour <= 17, 'Approval hour must be between 01:00 PM and 05:00 PM');
        }
    }
}