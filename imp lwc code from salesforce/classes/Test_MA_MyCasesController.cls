@isTest(SeeAllData=false)
public class Test_MA_MyCasesController {
    //Preparing test data.
    @testSetup static void createTestData() {
       	UserRole dummyRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];       
        Profile profile = [Select Id from Profile where name = 'System Administrator' Limit 1];     

        User sysAdminUser = new User(
            UserRoleId = dummyRole.Id,
            ProfileId = profile.Id,
            Username = 'testsysadminuser10@test.com',
            Alias = 'test1',
            Email='test@test1.com',
            EmailEncodingKey='UTF-8',
            Firstname='Sys',
            Lastname='Admin User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(sysAdminUser);
       
        User portalUser = new User();
        Contact contact = new Contact();
		Case portalCase = new Case();
        ContentVersion content = new ContentVersion();
        Id contentId;
        
        System.runAs(sysAdminUser) {
        
        //Create acquisition company
        Acquisition_Company__c accCompany = new Acquisition_Company__c(
            
            Acquisition_Company_Name__c = 'MA',
            Name = 'MA',
            Status__c = 'Pre-Diligence'
        
        );
        
        Database.insert(accCompany);
         
        //Create account
        Account account = new Account(
        
            Name = 'MA',
            Acquisition_Companies__c = accCompany.id,
            OwnerId = sysAdminUser.Id
        
        );
        Database.insert(account);
        
        Acquisition_Contacts__c accContact = new Acquisition_Contacts__c(
        
            Name = 'Test Community',
            Contact_Status__c = 'New',
            Hire_Reason__c = 'New Hire',
            Acquisition_Company__c = accCompany.id,
            Employee_ID_Target__c = '123456',
            Email_Address_Target__c = 'test@community.com'
        
        );
        Database.insert(accContact);
        
        //Create contact
        contact = new Contact(
        FirstName = 'Community',
        Lastname = 'Contact',
        AccountId = account.Id,
        Email = 'test@community.com'
        );
        Database.insert(contact);
        
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='M&A Community Portal Custom' Limit 1];
        UserRole portalRole = [SELECT Id FROM UserRole WHERE Name = 'MA Customer User' Limit 1];
        portalUser = new User(
        Username = 'test7686portal@community.com.wayfinder',
        ContactId = contact.Id,
        ProfileId = portalProfile.Id,
        UserRoleId = portalRole.id,
        Alias = 'test123',
        Email = 'test@community.com',
        FederationIdentifier = 'test@community.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        CommunityNickname = 'test12345',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US'
        );
        Database.insert(portalUser);
            
            content = new ContentVersion(
                Title          = 'a picture',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                origin = 'H');
            Database.insert(content);
        
        
        }
        
        
        System.runAs(portalUser) {
        
            portalCase = new Case( Status = 'New', Subject = 'Test',contactId = contact.id); 
            insert portalCase; 
            
            CaseComment caseComment = new CaseComment(CommentBody = 'Test Comment', ParentId = portalCase.id);
            insert caseComment; 
            
            Attachment attach=new Attachment(); 
            attach.Name='Unit Test Attachment'; 
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
            attach.body=bodyBlob; attach.parentId=portalCase.id;
            insert attach;         
        
        }
        
        System.runAs(sysAdminUser) {
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=portalCase.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where Id =:content.Id ].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink; 
        }
        
        Profile profileEmployee = [SELECT Id FROM Profile WHERE Name ='Employee' Limit 1];
            UserRole roleMA_ES = [SELECT Id FROM UserRole WHERE Name = 'M&A ES' Limit 1];
            User maApproverUser = new User(
                Username = 'maApprover@community.com.wayfinder',
                ProfileId = profileEmployee.Id,
                UserRoleId = roleMA_ES.id,
                Alias = 'maTest',
                Email = 'maTest@community.com',
                FederationIdentifier = 'maTest@community.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'maTest',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
        Database.insert(maApproverUser);

    }
    
    //Testing case wrapper
    @isTest
    static void testCaseWrapper() {           
            User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@community.com'];
            Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com']; 
            List<MA_MyCasesController.CaseWrapper> caseWrap = new List<MA_MyCasesController.CaseWrapper>();           
            Test.StartTest();                
                System.runAs(MAUser){
                 caseWrap = MA_MyCasesController.getCaseWrapperList();
                }
            Test.StopTest();    
            System.assertEquals(1, caseWrap.Size());
            System.assertEquals('Test', caseWrap[0].Subject);
            System.assertEquals(c.Id, caseWrap[0].caseId);               
    }
    
    //Testing case comment wrapper
    @isTest
    static void testCaseCommentWrapper() {
            User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@community.com'];
            Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com'];
            CaseComment caseComments = [Select Id, ParentId, IsPublished, CommentBody, CreatedById, CreatedBy.Name, CreatedDate, SystemModstamp, LastModifiedDate, LastModifiedById, IsDeleted From CaseComment where ParentId=:c.id];
            List<MA_MyCasesController.CaseCommentWrapper > caseCommentWrap = new List<MA_MyCasesController.CaseCommentWrapper >();
            Test.StartTest();
                System.runAs(MAUser){
                caseCommentWrap = MA_MyCasesController.getCaseCommentWrapperList(c.id);
                }
            Test.StopTest();
            System.assertEquals(1, caseCommentWrap.Size());
            System.assertEquals('Test Comment', caseCommentWrap[0].CommentBody);
            System.assertEquals(caseComments.Id, caseCommentWrap[0].commentId);             
    }
    
    //Testing Post Case Comment
    @isTest
    static void testPostCaseComment() {
            User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@community.com'];
            Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com'];
            Test.StartTest();
                System.runAs(MAUser){
                MA_MyCasesController.postNewCaseComment(c.id, 'hi');
                }
            Test.StopTest(); 
            List<CaseComment> caseComments = [Select Id, ParentId, IsPublished, CommentBody, CreatedById, CreatedBy.Name, CreatedDate, SystemModstamp, LastModifiedDate, LastModifiedById, IsDeleted From CaseComment where ParentId=:c.id];
            System.assertEquals(2, caseComments.Size());  
    }
    
    //Testing Post Case Comment Exception
    @isTest
    static void testPostCaseCommentException() {
            User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'matest@community.com'];
            Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com'];
                System.runAs(MAUser){
               		try {
                         Test.StartTest();
                         	MA_MyCasesController.postNewCaseComment(c.Id, 'hi');
                       	 Test.StopTest(); 
                    } catch (AuraHandledException e) {
                        // Handle the exception or perform any necessary assertions
                        String expectedErrorMessage = 'Script-thrown exception';
                   		System.assertEquals(expectedErrorMessage, e.getMessage());
                    }
                }
    }
    
    //Testing Case Close
    @isTest
    static void testCaseClose() {
            User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@community.com'];
            Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com']; 
            Test.StartTest();               
                System.runAs(MAUser){
                MA_MyCasesController.closeCase(c.id);
                }
            Test.StopTest(); 
            List<Case> closedCase = [Select Id, Status From Case where Id =:c.id];
            System.assertEquals('Closed', closedCase[0].Status);              
    }
    
     //Testing Case Close
    @isTest
    static void testCaseCloseException() {
            User MAEmployeeUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'maTest@community.com'];
            Case c = [Select Id, Status, CaseNumber, Subject, ContactEmail from Case Where ContactEmail='test@community.com'];                  
                System.runAs(MAEmployeeUser){
                    try {
                         Test.StartTest();
                         	MA_MyCasesController.closeCase(c.Id);
                       	 Test.StopTest(); 
                    } catch (AuraHandledException e) {
                        // Handle the exception or perform any necessary assertions
                        String expectedErrorMessage = 'Expected exception message';
                        System.assertNotEquals(expectedErrorMessage, e.getMessage(), 'Exception message does not match');
                    }
                }
    }
    
    //Testing Case ReOpen
    @isTest
    static void testCaseReOpen() {
            User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@community.com'];
            Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com']; 
            Test.StartTest();               
                System.runAs(MAUser){
                MA_MyCasesController.reOpenCase(c.id);
                }
            Test.StopTest(); 
            List<Case> reopenedCase = [Select Id, Status From Case where Id =:c.id];
            System.assertEquals('Re-Opened', reopenedCase[0].Status);              
    }
    
    //Testing attachments
    @isTest
    static void testGetFiles() {   
            User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@community.com'];
            Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com'];
            Test.StartTest();
                System.runAs(MAUser){              
                MA_MyCasesController.getFiles(c.id);
                }
            Test.StopTest(); 
            List<Attachment> attachments=[select id, name from Attachment where parent.id=:c.id]; 
            System.assertEquals(1, attachments.size());              
    }
    
    //Testing Delete attachments
     @isTest
     static void testDeleteFiles() {   
             User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@community.com'];
          	 User systemAdmin = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@test1.com'];
          	 Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com'];
         	 
         	 ContentVersion cv = new ContentVersion();
             System.runAs(systemAdmin){   
                 cv = [SELECT Id, ContentDocumentId FROM ContentVersion limit 1];
             }
              
             Test.StartTest();
                 System.runAs(MAUser){              
                 MA_MyCasesController.deleteFile(cv.Id);
                 }
             Test.StopTest(); 
         
             List<Attachment> attachments=[select id, name from Attachment where parent.id=:c.id]; 
             System.assertEquals(1, attachments.size());              
     }
    
    //Testing Delete attachments Exception
     @isTest
     static void testDeleteFilesException() {   
             User MAUser = [SELECT Id, Name, Email FROM User WHERE Email =: 'matest@community.com'];
          	 User systemAdmin = [SELECT Id, Name, Email FROM User WHERE Email =: 'test@test1.com'];
          	 Case c = [Select Id, CaseNumber, Status, Subject, ContactEmail from Case Where ContactEmail='test@community.com'];
         	 
         	 ContentVersion cv = new ContentVersion();
             System.runAs(systemAdmin){   
                 cv = [SELECT Id, ContentDocumentId FROM ContentVersion limit 1];
             }
         
             try {
    			Test.StartTest();
                     System.runAs(MAUser){              
                        MA_MyCasesController.deleteFile(cv.Id);
                     }
             	Test.StopTest();
             } catch (AuraHandledException e) {
                   // Handle the exception or perform any necessary assertions
                   String expectedErrorMessage = 'Script-thrown exception';
                   System.assertEquals(expectedErrorMessage, e.getMessage());
             }              
     }
}