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
private class TestPF_IndividualDevPlanController_QE {

	/**
		As an employee, share a career plan with a user that's not on his team
	**/
    static testMethod void shareWithSomeoneNotFromYourTeam() {
        User employee = GenerateEnvironmentTest.getEmployeeStandard();
        User employee2 = getNewUser();
        MyCarrerPlan__c plan;
        System.runAs(employee){
        	plan = new MyCarrerPlan__c();
        	plan.Compensation__c = 'compensation comment';
        	insert plan;
        }
        System.runAs(employee2){
        	System.assertEquals('compensation comment', plan.Compensation__c);
        }
        
        List<MyCarrerPlan__Share> shares = [select userOrGroupId from MyCarrerPlan__Share where parentId=:plan.Id];
        for(MyCarrerPlan__Share s : shares){
        	System.debug('***share with user: ' + s.UserOrGroupId);
        }
    }
    
     private static User getNewUser(){
        User manager = GenerateEnvironmentTest.getManager();
        User reviewManager = GenerateEnvironmentTest.getSecondManager();
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        User u =  new User(username='test__changeManager11@peopleforce.com.qa',
                                    lastName='testChangeManager22',
                                    email='testChangeManager2@salesforce.com.qa',
                                    alias='tchmngr',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id,
                                    Manager__c = manager.Id,
                                    reviewManager__c = reviewManager.Id);
                                    
                                  
        insert u;   
        
        return u;                   
    }
}