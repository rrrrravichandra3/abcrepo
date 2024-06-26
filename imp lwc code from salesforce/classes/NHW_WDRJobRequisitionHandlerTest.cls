@isTest
private without sharing class NHW_WDRJobRequisitionHandlerTest {
    
    @isTest static void successfullEndToEndUpdate() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];      
        Account acc;
        Contact con;
        TF2_Department__c dept;
        Business_Unit__c BU;
            dept = new TF2_Department__c(Department_Number__c='7654',Name='IT Apps');
            BU = new Business_Unit__c(BU_Code__c='5001',Name = 'Shared Services');
            insert dept;
            insert BU;
            Test.startTest();
            WDR_Testfactory testFactory = new WDR_Testfactory();
            testFactory.createJobApp();
            TF2_Business_Site__c buSite = new TF2_Business_Site__c(name='Remote -test California - San Francisco',
                                                                   Country__c='Unites States',Street_Address__c='350 Mission St',City__c = 'Test city',
                                                                   Type__c='Regional Site');
            insert buSite;
            List<Case> cases = [SELECT Id, CaseNumber FROM Case WHERE NHW_Job_Application__c = : testFactory.getDefaultJobApp().Id];
            System.assertEquals(0, cases.size(), 'There should not be any Cases for Job Application');
            
            testFactory.getDefaultJobApp().Candidate_Stage__c = 'Placement';
            testFactory.getDefaultJobApp().NHW_Create_Preboarding_Case__c = true;
            update testFactory.getDefaultJobApp();
            
            List<Case> casesAfterPlacement = [SELECT Id, CaseNumber, NH_Business_Site__c, NHW_Start_Date__c FROM Case 
                                              WHERE NHW_Job_Application__c = : testFactory.getDefaultJobApp().Id];
            
            
            List<WDR_Job__c> jobRequistions = [SELECT Id, Business_Unit__c, Department__c, Hiring_Manager__c FROM WDR_Job__c];
            System.assertEquals(1, jobRequistions.size(), 'There should be a Job Requistion.');
            
            testFactory.getDefaultJobReq().Business_Unit__c = BU.Id;
            testFactory.getDefaultJobReq().Department__c = dept.Id;
            
            update testFactory.getDefaultJobReq();
            Test.stopTest();
            
            List<Case> casesAfterUpdate = [SELECT Id, Manager_Name__c, NHW_Cost_Center__c, NHW_Business_Unit__c FROM Case];
            System.assertEquals(casesAfterUpdate[0].NHW_Cost_Center__c, dept.Id, 'Cost Center should be updated in the case.');
            System.assertEquals(casesAfterUpdate[0].NHW_Business_Unit__c, BU.Id, 'Business Unit should be updated in the case.');
     
    }
    
    @isTest static void successfulEndToEndBulkUpdate() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
            Account acc ; 
        Contact con ;
        TF2_Department__c dept;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        Business_Unit__c BU;
            
            
            dept = new TF2_Department__c(Department_Number__c='7654',Name='IT Apps');
            BU = new Business_Unit__c(BU_Code__c='5001',Name = 'Shared Services');
            insert dept;
            insert BU;
            Test.startTest();
            WDR_Testfactory testFactory = new WDR_Testfactory();
            testFactory.createJobApps(50);
            TF2_Business_Site__c buSite = new TF2_Business_Site__c(name='Remote -California - San Francisco',
                                                                   Country__c='Unites States',Street_Address__c='350 Mission St',City__c = 'Test city',
                                                                   Type__c='Regional Site');
            insert buSite;
            List<Case> cases = [SELECT Id, CaseNumber FROM Case ];
            System.assertEquals(0, cases.size(), 'There should not be any Cases for Job Application');
            
            List<WDR_Application__c> jobApps = [SELECT Id, Candidate_Stage__c, NHW_Create_Preboarding_Case__c, Business_Site__c, Start_Date__c FROM WDR_Application__c];
            System.assertEquals(50, jobApps.size());
            for(WDR_Application__c jobApp : jobApps){
                jobApp.Candidate_Stage__c = 'Placement';
                jobApp.NHW_Create_Preboarding_Case__c = true;   
            }
            update jobApps;
            WDR_Job__c jobRequistion = [SELECT Id, Business_Unit__c, Department__c, Hiring_Manager__c FROM WDR_Job__c];
            jobRequistion.Business_Unit__c = BU.Id;
            jobRequistion.Department__c = dept.Id;
            
            update jobRequistion;
            Test.stopTest();
            List<Case> casesAfterUpdateJobReq = [SELECT Id, Manager_Name__c, NHW_Cost_Center__c, NHW_Business_Unit__c, NHW_Job_Application__r.Job__r.Business_Unit__c, NHW_Job_Application__r.Job__r.Department__c , NHW_Job_Application__r.Job__r.Hiring_Manager__c  FROM Case ];
            
            for(Case cse: casesAfterUpdateJobReq){
                System.assertEquals(cse.NHW_Job_Application__r.Job__r.Business_Unit__c, cse.NHW_Business_Unit__c);
                System.assertEquals(cse.NHW_Job_Application__r.Job__r.Department__c, cse.NHW_Cost_Center__c);
            }
        }
    
}