/**
* @author Vinod Chokkula
* @date 12/14/2020
*
* @description Test Class for IA_BlockAuthBatch
*
*
*/
@isTest(isParallel=false) 
public class IA_BlockAuthBatchTest {
    /*******************************************************************************************************
* @description setup test data
*/
    @testSetup
    static void setup() {
        String timeZone = 'America/Los_Angeles';
        String country = 'United States';
        //create job application and refere from contact and link the contact to user
        Account acc = new Account(
            name = 'Test Account'
        );
        insert acc;
        Profile pr = [select id from Profile where name='System administrator']; 
        User opUser = new user(alias = 'test123', email='test123@noemail.com',emailencodingkey='UTF-8',Available_for_CEMCI_Account_Assignment__c = true, firstName='Test user', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = pr.Id, country=country,timezonesidkey=timeZone, username='test011@noemail.com' ); 
        insert opUser;
        User opUser1 = new user(alias = 'test123', email='test1231@noemail.com',emailencodingkey='UTF-8',Available_for_CEMCI_Account_Assignment__c = true, firstName='Test user11', lastname='Testing11', languagelocalekey='en_US',localesidkey='en_US', profileid = pr.Id, country=country,timezonesidkey=timeZone, username='test0111@noemail.com' ); 
        insert opUser1;
        User opUser2 = new user(alias = 'test123', email='test12312@noemail.com',emailencodingkey='UTF-8',Available_for_CEMCI_Account_Assignment__c = true, firstName='Test user12', lastname='Testing12', languagelocalekey='en_US',localesidkey='en_US', profileid = pr.Id, country=country,timezonesidkey=timeZone, username='test123121@noemail.com' ); 
        insert opUser2;
        assignPS(opUser.id);
        assignPG(opUser.id);
        assignPS(opUser1.id);
        assignPG(opUser1.id);
        assignPS(opUser2.id);
        assignPG(opUser2.id);
        WDR_Job__c job = new WDR_Job__c (
            Name='Test Job',
            Job_Code__c = '123456',
            Hiring_Manager__c=opUser.Id
        );
        insert job;
        
        //Insert WDR Candidate
        WDR_Candidate__c wdCandidate = new WDR_Candidate__c(
            Name = 'test candidate',
            First_Name__c ='test',
            Last_Name__c = 'candidate',
            Email__c = 'test123@noemail.com'
        );
        insert wdCandidate;
        
        //Insert WDR Candidate
        WDR_Candidate__c wdCandidate1 = new WDR_Candidate__c(
            Name = 'test candidate1',
            First_Name__c ='test',
            Last_Name__c = 'candidate',
            Email__c = 'test1231@noemail.com'
        );
        insert wdCandidate1;
        
        //Insert WDR Candidate
        WDR_Candidate__c wdCandidate2 = new WDR_Candidate__c(
            Name = 'test candidate2',
            First_Name__c ='test',
            Last_Name__c = 'candidate',
            Email__c = 'test123120@noemail.com'
        );
        insert wdCandidate2;
        
        //Insert WDR Application
        WDR_Application__c wdApp = new WDR_Application__c (
            Candidate__c =  wdCandidate.Id,
            Job__c = job.Id,
            Candidate_Stage__c = 'Screen',
            Internal_Candidate__c = true,
            Offer_type__c='FTE'
        );
        insert wdApp;
        
        //Insert WDR Application
        WDR_Application__c wdApp2 = new WDR_Application__c (
            Candidate__c =  wdCandidate2.Id,
            Job__c = job.Id,
            Candidate_Stage__c = 'Screen',
            Internal_Candidate__c = true,
            Offer_type__c='FTE'
        );
        insert wdApp2;
        
        //Insert WDR Application
        WDR_Application__c wdApp1 = new WDR_Application__c (
            Candidate__c =  wdCandidate1.Id,
            Job__c = job.Id,
            Candidate_Stage__c = 'Declined by Candidate',
            Internal_Candidate__c = false,
            Offer_type__c='FTE'
        );
        insert wdApp1;
        
        Contact con = new Contact(
            firstname = 'test',
            lastname = 'contact55',
            AccountId = acc.id,
            email = 'testvin12345@test.com',
            MPA_App__c = wdApp.Id,
            recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('WDR_Candidate')
            .getRecordTypeId()
        );
        insert con;
        
        Contact con1 = new Contact(
            firstname = 'test',
            lastname = 'contact55',
            AccountId = acc.id,
            email = 'testvin123456@test.com',
            MPA_App__c = wdApp1.Id,
            recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('WDR_Candidate')
            .getRecordTypeId()
        );
        insert con1;
        
        Contact con2 = new Contact(
            firstname = 'test',
            lastname = 'contact55',
            AccountId = acc.id,
            email = 'testvin12345610@test.com',
            MPA_App__c = wdApp2.Id,
            recordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('WDR_Candidate')
            .getRecordTypeId()
        );
        insert con2;
        
        UserRole testUserRole = [SELECT Id  FROM UserRole  LIMIT 1];
        User thisUser = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Profile p1 = [SELECT id FROM Profile WHERE name = 'Customer Portal Manager Custom'];
            
            User usr = new user(
                alias = 'testvin4',
                email = 'testvin12345@test.com',
                emailencodingkey = 'UTF-8',
                firstName = 'VinTest',
                lastname = 'Testing',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = p1.Id,
                country = country,
                timezonesidkey = timeZone,
                username = 'testvin1234@test.com',
                contactId = con.Id,
                UserRoleId = testUserRole.Id
            );
            insert usr;
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Insiders_App_Candidate'];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps1.Id);
            
            UserRole testUserRole1 = [SELECT Id  FROM UserRole  LIMIT 1];
            User thisUser1 = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(thisUser1) {
                Profile p11 = [SELECT id FROM Profile WHERE name = 'Customer Portal Manager Custom'];
                User usr1 = new user(
                    alias = 'testvin4',
                    email = 'testvin1234565@test.com',
                    emailencodingkey = 'UTF-8',
                    firstName = 'VinTest',
                    lastname = 'Testing',
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_US',
                    profileid = p11.Id,
                    country = country,
                    timezonesidkey = timeZone,
                    username = 'testvin1234569@test.com',
                    contactId = con1.Id,
                    UserRoleId = testUserRole1.Id
                );
               // insert usr1;
                PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'Insiders_App_Candidate'];
               // insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps11.Id);
            }
            
            UserRole testUserRole2 = [SELECT Id  FROM UserRole  LIMIT 1];
            User thisUser2 = [SELECT Id,UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(thisUser2) {
                Profile p112 = [SELECT id FROM Profile WHERE name = 'Customer Portal Manager Custom'];
                User usr2 = new user(
                    alias = 'testvin4',
                    email = 'testvin1234561@test.com',
                    emailencodingkey = 'UTF-8',
                    firstName = 'VinTest',
                    lastname = 'Testing',
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_US',
                    profileid = p112.Id,
                    country = country,
                    timezonesidkey = timeZone,
                    username = 'testvin12345611@test.com',
                    contactId = con2.Id,
                    UserRoleId = testUserRole2.Id
                );
               // insert usr2;
                PermissionSet ps112 = [SELECT Id FROM PermissionSet WHERE Name = 'Insiders_App_Candidate'];
                //insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps112.Id);
            }
        }
    }
    
    @isTest
    static void removePermsetTest() {
        test.startTest();
        IA_BlockAuthBatch batch = new IA_BlockAuthBatch();
        batch.failedDeleteRecords.put('test','test');
        DataBase.executeBatch(batch); 
        test.stopTest();
    }
    @future
    static void assignPS(id userId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Insiders_App_Candidate'];
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
    }
    
    @future
    static void assignPG(id userId){
        list<groupMember> groupList = new list<groupMember>();
        Group grp = [select id from Group where name = 'Insiders Candidates'];
                    groupMember gp = new groupMember(groupId = grp.Id);
                    gp.UserOrGroupId = userId;
                    groupList.add(gp);
        
            insert groupList;
    }
}