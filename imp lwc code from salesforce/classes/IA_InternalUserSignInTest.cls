/**
 * @description       : Test Class for IA_InternalUserSignIn
 * @author            : m.pal@salesforce.com
 *
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-29-2022   m.pal@salesforce.com                 Initial version
 */
@isTest
public class IA_InternalUserSignInTest {
	private static final String MSG_EXPECTING_APPS_TO_BE_RETURNED = 'Expecting returned applications not empty';
    @isTest
    static void getAllApplication() {
        
        User thisUser = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        
         Account acc = new Account(
        name = 'Test Account'
        );
        insert acc;

        Contact con = new Contact(
          firstname = 'test',
          lastname = 'contact55',
          AccountId = acc.id,
          email = 'test1234@noemail.com',
          //MPA_App__c = wdApp.Id,
          recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('WDR_Candidate')
            .getRecordTypeId()
        );
        insert con;

        WDR_Job__c job = new WDR_Job__c (
        Name='Test Job',
        Job_Code__c = '123456',
        Hiring_Manager__c=thisUser.Id,
        Job_Family_Group__c ='CSG',
        Job_Level__c = '3',
        Division__c = 'Americas - USA'

        //Employment_Type__c = 
        );
        insert job;

    	//Insert WDR Candidate
        WDR_Candidate__c wdCandidate = new WDR_Candidate__c(
        Name = 'test candidate',
        First_Name__c ='test',
        Last_Name__c = 'candidate',
        Email__c = 'test1234@noemail.com',
        Candidate_Contact__c = con.Id
        );
        insert wdCandidate;

        //Insert WDR Application
        WDR_Application__c wdApp = new WDR_Application__c (
            Candidate__c =  wdCandidate.Id,
            Job__c = job.Id,
            Candidate_Stage__c = 'Screen',
            Offer_type__c='FTE',
            Boomerang__c = false,
            Internal_Candidate__c = true,
            Confidential__c = false,
            Application_Step__c = 'Hiring Manager Review'
        );
	    insert wdApp;
    
        Test.startTest();
        Set<String> appsSet = IA_InternalUserSignIn.getAllInternalApplication('test1234@noemail.com');
        System.Assert(!appsSet.isEmpty() ,MSG_EXPECTING_APPS_TO_BE_RETURNED);
        Test.stopTest();
    }
    
}