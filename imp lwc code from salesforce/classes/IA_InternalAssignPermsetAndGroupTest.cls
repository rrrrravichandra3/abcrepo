/**
 * @author VenkateswaraReddy Komireddy
 * @date 28/09/2022
 *
 * @description : Assign Public group and permission set to Internal Candidate 
******/

@isTest
public class IA_InternalAssignPermsetAndGroupTest {
	
    @isTest
    static void assignPublicGroupOrPermSet(){
        User thisUser = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        User userWithRole;
        System.runAs(thisUser) {
	    Profile pr = [select id from Profile where name='System administrator']; 
        UserRole ur = [select id from UserRole where name='Do_NOT_Create_SubOrd_SharingRules'];
        userWithRole = new user( isActive =true, alias = 'test1234', email='test1234@noemail.com',emailencodingkey='UTF-8', firstName='Test user1', lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = pr.Id, country='United States',timezonesidkey='America/Los_Angeles', username='test012@noemail.com',userroleId =ur.Id ); 
        insert userWithRole;
        }
        
        Account acc = new Account(
        name = 'Test Account',
        ownerId = userWithRole.id
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
        
        con.MPA_App__c = wdApp.id;
        update con;
        
        Test.startTest();
		Insiders_Tracking__c tracking =new Insiders_Tracking__c (Invitation_Email_Sent__c =true,WD_Job_Application__c =wdApp.Id,
                                                                Invitation_History__c='Screen-Hiring Manager Review-'+System.now());
        insert tracking;
       
		List<PermissionSetAssignment> lstassignment=[SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =:userWithRole.id];
        system.assertEquals(true, lstassignment.size()>0, 'Permission Set assigned to Internal Candidate');
        Test.stopTest();
    }
}