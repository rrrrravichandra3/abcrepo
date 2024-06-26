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
private class TestPF_OverallCSMController_Unit {

   static testMethod void Test_OverallSOQLController() {
        
        GenerateEnvironmentTest3.genV2MOMUtil();
        
        Test.startTest();
        
        PerformanceSOQLController controller = new PerformanceSOQLController();
       
        System.assert(controller.getPerformanceReviewWithSharing(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu.Id) != null);
        
        System.RunAs(GenerateEnvironmentTest3.employeeStandard)
        {
             System.assert(controller.getPerformanceReviewWithSharing(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu.Id) == null);    
        }
        
        controller.setCurrentUser(GenerateEnvironmentTest3.employeeEducation);
        System.RunAs(GenerateEnvironmentTest3.employeeEducation)
        {
             System.assert(controller.getScorecardCommentWithSharing(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu) != null);    
        }
       
        GenerateEnvironmentTest3.PRIndividualQ1Q2Edu.Status__c = '3rd Party Assessment';
        
        update GenerateEnvironmentTest3.PRIndividualQ1Q2Edu;
        
        
        /*System.runAs(GenerateEnvironmentTest3.reviewManagerEducation)
        {
            System.assert(controller.getScorecardCommentWithSharing(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu) != null);
        }*/
        
        List<Method__c> newMethodList = new List<Method__c>();
        List<CompetencyGroup__c> competencyGroup = new List<CompetencyGroup__c>();
        
        System.assert(controller.getMethodReviewsWithSharing(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu, newMethodList) != null);
        
        System.assert(controller.getCompetencyReviewManagerDataWithSharing(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,competencyGroup ) != null);
        
        System.assert(controller.getMethodHistoryWithSharing(GenerateEnvironmentTest3.PRIndividualQ1Q2Edu,GenerateEnvironmentTest3.methodQ1Q2Edu1) != null);
        
        System.assert(controller.getCompetencyHistoryWithSharing( GenerateEnvironmentTest3.PRIndividualQ1Q2Edu.Id, GenerateEnvironmentTest3.PRIndividualQ1Q2Edu) != null);
        
        System.assert(controller.getMethodReviewRating( GenerateEnvironmentTest3.PRIndividualQ1Q2Edu, GenerateEnvironmentTest3.methodQ1Q2Edu1) != null);
        
        System.assert(controller.getMethodReviewStatus( GenerateEnvironmentTest3.PRIndividualQ1Q2Edu, GenerateEnvironmentTest3.methodQ1Q2Edu1) != null);
        
        
        Test.stopTest();
        
    }
    
      static testMethod void Test_OverallCSMController() {
        
            
            User currentUser = [Select Id, u.Profile.Name, u.ProfileId From User u where id = : userInfo.getUserId()];
           
            Test.startTest();
            
         
            PerformanceReview__c performanceReview = GenerateEnvironmentTest1.genPerformanceReviewAdHoc();
            OverallCSMController  controller = new OverallCSMController(performanceReview);
            
            
            
            controller.getOverallUtil();
        

            //Test second constructor
            OverallCSMController  controller2 = new OverallCSMController(performanceReview,true);
            
            Test.stopTest();
      }
      
}