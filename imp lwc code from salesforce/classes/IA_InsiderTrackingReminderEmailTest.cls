@isTest
public class IA_InsiderTrackingReminderEmailTest {
	@testSetup
    static void setup() {
        
        User thisUser = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        List<User> usersList = new List<User>();
        System.runAs(thisUser) {
            Profile pr = [SELECT id FROM Profile WHERE name='System administrator' limit 1]; 
            UserRole ur = [SELECT id FROM UserRole WHERE name='Do_NOT_Create_SubOrd_SharingRules'];

            for (Integer i = 0; i < 2; i++) {
                User userWithRole = new User(alias = 'test0'+i,
                                    email ='testinvitation' + i + '@abc.com',
                                    emailencodingkey = 'UTF-8',
                                    firstName = 'Test invitation'+i,
                                    lastname = 'Testinvitation0'+i,
                                    languagelocalekey = 'en_US',
                                    localesidkey = 'en_US',
                                    profileid = pr.Id,
                                    country = 'United States',
                                    timezonesidkey = 'America/Los_Angeles',
                                    username = 'testinvitation' + i + '@abc.com',
                                    userroleId = ur.Id);
                usersList.add(userWithRole);
            }
            insert usersList;
        }

        Account acc = new Account(
            name = 'Test Account',
            ownerId = usersList[0].id
        );
        insert acc;
            

        List<Contact> testContactList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = new Contact(firstname = 'Test' + i,
                                    lastname = 'Contact' + i,
                                    AccountId = acc.id,
                                    email = 'testcontactemail'+i+'@test.com',        
                                    recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('WDR_Candidate')
        .getRecordTypeId());
            testContactList.add(con);
        }
        insert testContactList;

        List<WDR_Job__c> testWDRJobList = new List<WDR_Job__c>();
        for (Integer i = 0; i < 2; i++) {
            WDR_Job__c job = new WDR_Job__c (Name = 'Test Job'+i,
                                          Job_Code__c = '123456'+i,
                                          Hiring_Manager__c = thisUser.Id,
                                          Job_Family_Group__c ='CSG',
                                          Job_Level__c = '3',
                                          Division__c = 'Americas - USA');
            testWDRJobList.add(job);
        }
        insert testWDRJobList;

        //Insert WDR Candidate
        List<WDR_Candidate__c> testWDRCandidateList = new List<WDR_Candidate__c>();
        for (Integer i = 0; i < 2; i++) {
            WDR_Candidate__c wdCandidate = new WDR_Candidate__c(Name = 'test candidate',
                                                            First_Name__c ='test',
                                                            Last_Name__c = 'candidate',
                                                            Email__c = 'testvin@test.com',
                                                            Candidate_Contact__c = testContactList[i].Id);
            testWDRCandidateList.add(wdCandidate);
        }        
        insert testWDRCandidateList;

        //Insert WDR Application
        List<WDR_Application__c> testWDRApplicationList = new List<WDR_Application__c>();
        for (Integer i = 0; i < 2; i++) {
            WDR_Application__c wdApp = new WDR_Application__c (Candidate__c = testWDRCandidateList[i].Id,
                                                            Job__c = testWDRJobList[i].Id,
                                                            Candidate_Stage__c = 'Interview',
                                                            Application_Step__c = 'additional Interviews',
                                                            Offer_type__c = 'FTE',
                                                            Boomerang__c = false,
                                                            Internal_Candidate__c = false,
                                                            Confidential__c = false,
                                                            is_New__c =true,
                                                            WD_Job_App_Reference_Id__c='773888333'+i,
                                                            WD_Job_App_WDI__c ='987773388'+i,
                                                            Ready_to_Process__c =true);
            testWDRApplicationList.add(wdApp);
        }
        insert testWDRApplicationList;
        
		Insiders_Tracking__c tracking =new Insiders_Tracking__c (Invitation_Email_Sent__c =true,WD_Job_Application__c =testWDRApplicationList[0].Id,
                                                                 Candidate_Login__c=System.now(),
                                                                 Invitation_History__c='Screen-Hiring Manager Review-'+System.now()
                                                                );
        insert tracking;
    }
    
    @IsTest
    static void IA_InsiderTrackingReminderEmailHandlerTest(){
        List<WDR_Application__c> jobApps = [SELECT Id FROM WDR_Application__c limit 2];
        string records='';
        for(WDR_Application__c jobapp : jobApps)
        {
            if(records==''){
                records=jobapp.id;
            }	
            else{
                records=records+';'+jobapp.id;
            }
        }
        List<Insiders_Tracking__c> lsttracking=[select id,name,Candidate_Login__c,Candidate_Email__c,Reminder_Email_Sent__c from Insiders_Tracking__c]; 
        IA_InsiderTrackingReminderEmailHandler.invokeReminderEmailTrigger(lsttracking);
        
    }
}