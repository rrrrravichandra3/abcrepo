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
private class Test_PerformanceMethodController {

    static testMethod void test() {

        User employeeStandard;
        User managerStandard;
        User secondManagerStandard;
        User pcommStandard;
        
        V2MOM__c v2momIndividual;
        Method__c method;
        Department__c department;
        MethodReview__c review; 
        List<MethodReview__c> history;
        List<Obstacle__c> obstacle;
        List<Measure__c> metrics;
        
        double rating1 = 25;
        double weight = 34;
        String statusManagerAssessment = 'Manager Assessment';
        String statusThirdParty='3rd Party Assessment';
        String previousStatus='Created';
        
        
      			
        //Create Employees         
        employeeStandard  = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.ccstndmngr];
        managerStandard =  [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCRevSup2ndMngr];
        secondManagerStandard =  [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCStnd2ndMngr];
        pcommStandard = [select id, username, name, Profile.Name from User where username=:GenerateEnvironmentTestUsers.CCPCOMM];


        //Create Performance Review Period
      	Date sdate = System.today();
		Date edate = sdate.addYears(1);
         PerformanceReviewPeriod__c performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
																		Effective_Date__c = 'FY11',
																		V2MOM_Type__c = 'Individual',
															            StartDate__c = sdate,
																		EndDate__c = edate);
        
        
        //Create Method Review
		review = new MethodReview__c(Name='Review Name',CreatedDate=sdate,LastModifiedDate=edate);	
        System.assertEquals(review.Name, 'Review Name');
        //Create a new V2MOM
        v2momIndividual = GenerateEnvironmentTest3.createV2MOM(employeeStandard.Id, 'Vision', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
       
        //Create a method associated to the V2MOM
        method  =  GenerateEnvironmentTest3.createMethod(v2momIndividual.Id, null, 1, 'Method', 'Description');
       
        //Create a Department
        department =  GenerateEnvironmentTest3.createDepartment('Test Department', false);
       
        //Create Competency Group
        CompetencyGroup__c competencyGroup = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
        System.assertEquals(competencyGroup.Name, 'CCCompGrp');
		insert competencyGroup;
		//Create Review Form Template
        ReviewFormTemplate__c reviewFormTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
        insert reviewFormTemplate;
      
        PerformanceReview__c performanceReview = new PerformanceReview__c(Name = 'Performance Review',
														   PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
														   V2MOM__c = v2momIndividual.Id,
														   CompetencyGroup__c = competencyGroup.Id,
														   ReviewFormTemplate__c = reviewFormTemplate.Id,
														   Employee__c = employeeStandard.Id,
														   Manager__c = managerStandard.Id,
														   SecondManager__c = secondManagerStandard.Id,
														   PCOMM__c = pcommStandard.Id,
														   Department__c = department.Id,
														   Status__c = statusThirdParty,
													       PreviousStatus__c = statusManagerAssessment);      
        
        PerformanceMethodController controller = new PerformanceMethodController(method ,performanceReview); 
      


        controller.setMethod(method);
        controller.getMethod();
        controller.setRating(rating1);
        controller.setWeight(weight);
        
        System.runAs(secondManagerStandard){
        controller.getRating();
        controller.getRatingShow();
        controller.getWeight();
        controller.setRating(-1);
        controller.getRating();
        }
        
        controller.getStatus();
        controller.getReview();
        controller.getMetrics();
        controller.getObstacles();
        controller.getShowValue();
        controller.getWeightShow();
        controller.getHistory();
        controller.setReview(review);
        controller.setHistory(history);
        controller.setMetrics(metrics);
        controller.setObstacles(obstacle);
        controller.setStatus(null);
        controller.getStatus();
        controller.setStatus(previousStatus);
        controller.getStatus();
        

        //Inner Class Method Review
        PerformanceMethodController.MethodReviewDate methodReviewDate = new PerformanceMethodController.MethodReviewDate(review);
        methodReviewDate.getMethodReview();
        methodReviewDate.getReviewerName();
        methodReviewDate.getCreatedDate();
        methodReviewDate.getLastModifiedDate();
        methodReviewDate.setCreatedDate('Date');
        methodReviewDate.setMethodReview(review);
        controller.getHistoryFormatted();
    }
}