/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class Test_ScorecardAdminConsultingNBCont {
    
    static testMethod void myUnitTest() {
       Test.startTest();
       
       ScorecardAdminConsultingNBController testClass = new ScorecardAdminConsultingNBController();
       
       testClass.newBookingsChangesReload();
       testClass.getBookingsDeptEast();
       testClass.getBookingsDeptWest();
       testClass.getRatingSelectOptions();
       testClass.getScorecard();
       
       DeptScorecard__c departmentBookingsScorecard = new DeptScorecard__c();
       departmentBookingsScorecard.Q1Actual__c = 3;
       departmentBookingsScorecard.Q2Actual__c = 3;
       departmentBookingsScorecard.Q3Actual__c = 3;
       departmentBookingsScorecard.Q4Actual__c = 3;
       departmentBookingsScorecard.Q1Target__c = 3;
       departmentBookingsScorecard.Q2Target__c = 3;
       departmentBookingsScorecard.Q3Target__c = 3;
       departmentBookingsScorecard.Q4Target__c = 3;
       
       insert departmentBookingsScorecard;
       ScorecardAdminConsultingNBController.DepartmentBookingsEast innerBookEast = new ScorecardAdminConsultingNBController.DepartmentBookingsEast(departmentBookingsScorecard);
    
    	innerBookEast.getActualQ1();
    	innerBookEast.getActualQ2();
    	innerBookEast.getActualQ3();
    	innerBookEast.getActualQ4();
    	innerBookEast.getTargetQ1();
    	innerBookEast.getTargetQ2();
    	innerBookEast.getTargetQ3();
    	innerBookEast.getTargetQ4();
    	innerBookEast.getRatingQ1();
    	innerBookEast.getRatingQ2();
    	innerBookEast.getRatingQ3();
    	innerBookEast.getRatingQ4();
    	innerBookEast.getAvgRatingQ1Q2();
    	innerBookEast.getAvgRatingQ3Q4();
    	innerBookEast.getAttainabilityQ1();
    	innerBookEast.getAttainabilityQ2();
    	innerBookEast.getAttainabilityQ3();
    	innerBookEast.getAttainabilityQ4();
    	innerBookEast.getAttainalibityAvgQ1Q2();
    	innerBookEast.getAttainalibityAvgQ3Q4();
    	
    	ScorecardAdminConsultingNBController.DepartmentBookingsWest innerBookWest = new ScorecardAdminConsultingNBController.DepartmentBookingsWest(departmentBookingsScorecard);
    	
    	innerBookWest.getActualQ1();
    	innerBookWest.getActualQ2();
    	innerBookWest.getActualQ3();
    	innerBookWest.getActualQ4();
    	innerBookWest.getTargetQ1();
    	innerBookWest.getTargetQ2();
    	innerBookWest.getTargetQ3();
    	innerBookWest.getTargetQ4();
    	innerBookWest.getRatingQ1();
    	innerBookWest.getRatingQ2();
    	innerBookWest.getRatingQ3();
    	innerBookWest.getRatingQ4();
    	innerBookWest.getAvgRatingQ1Q2();
    	innerBookWest.getAvgRatingQ3Q4();
    	innerBookWest.getAttainabilityQ1();
    	innerBookWest.getAttainabilityQ2();
    	innerBookWest.getAttainabilityQ3();
    	innerBookWest.getAttainabilityQ4();
    	innerBookWest.getAttainalibityAvgQ1Q2();
    	innerBookWest.getAttainalibityAvgQ3Q4();
    }
}