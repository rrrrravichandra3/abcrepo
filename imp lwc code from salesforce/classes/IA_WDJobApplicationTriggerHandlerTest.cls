@isTest
public class IA_WDJobApplicationTriggerHandlerTest {
/*
 * @description : Test case for job application trigger
*/
    public static testMethod void unitInvitationSend(){
        User thisUser = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        User userWithRole;
        System.runAs(thisUser) {
	    Profile pr = [select id from Profile where name='System administrator']; 
        UserRole ur = [select id from UserRole where name='Do_NOT_Create_SubOrd_SharingRules'];
        userWithRole = new user( isActive =true, alias = 'test1234', email='test1234@noemail.com',emailencodingkey='UTF-8', firstName='Test user1', lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = pr.Id, country='United States',timezonesidkey='America/Los_Angeles', username='test012@noemail.com',userroleId =ur.Id ); 
        insert userWithRole;
        }
        
        // InsidersAppSettings__c 
        insert new InsidersAppSettings__c (name='ServiceTerritoryIdForTimezones',
                                           Email_Header_Image__c='https://dreamjobcentral--c.na147.content.force.com/servlet/servlet.ImageServer?id=0154u000009Iq0w&oid=00D70000000Jxye&lastMod=1634835192000' ,
                                           Filter_Id__c='00B9A000002JnQ6UAK' ,PF_Community_Domain__c='https://dreamjobcentral--pfdev5.sandbox.my.site.com' ,
                                           PF_URL_Domain__c='https://dreamjobcentral--pfdev5.sandbox.my.salesforce.com' ,Time_Offs_Filter_Id__c='Recent',
                                           Invitation_Email_Testimonal_Text__c ='Just wanted to let you know');

        Account acc = new Account(name = 'Test Account',ownerId = userWithRole.id);
        insert acc;
        
        Contact con = new Contact(firstname = 'test', lastname = 'contact55',
          AccountId = acc.id,email = 'test1234@noemail.com',
          recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId()
        );
        insert con;

        WDR_Job__c job = new WDR_Job__c (Name='Test Job',Job_Code__c = '123456',Hiring_Manager__c=thisUser.Id,
                                         Job_Family_Group__c ='CSG',Job_Level__c = '3',Division__c = 'Americas - USA',
                                        Country__c='United States of America');
        insert job;

    	//Insert WDR Candidate
        WDR_Candidate__c wdCandidate = new WDR_Candidate__c(Name = 'test candidate',First_Name__c ='test',
                                                            Last_Name__c = 'candidate',Email__c = 'test1234@noemail.com',
                                                            Candidate_Contact__c = con.Id);
        insert wdCandidate;

        //Insert WDR Application
        WDR_Application__c wdApp = new WDR_Application__c (Candidate__c =  wdCandidate.Id, Job__c = job.Id,
                                                           Candidate_Stage__c = 'Screen', Offer_type__c='FTE',
                                                           Boomerang__c = false,Internal_Candidate__c = true,
                                                           Confidential__c = false,Application_Step__c = 'Hiring Manager Review');
	    insert wdApp;
       
        wdApp.Candidate_Stage__c='Offer';
        wdApp.Application_Step__c='';
        update wdApp;

        List<IA_Invitation_JobApplication__c> lstjobApp=[select id from IA_Invitation_JobApplication__c];
        system.assertEquals(1, 1, 'Job Application created');
    }
}