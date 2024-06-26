@isTest 

public class Test_ESDJC_CaseTierAge {
    
    private static User currentUser = [select userroleId,userrole.name from User where Id = : userinfo.getUserId()]; 
    //data preparation for testmethods happens in init method.. 
    private static Contact apacContact; 
    private static void init(){
        Id TechAnalystRole = [select Id from UserRole where Name='ES Tech Analyst'].Id;
        Id  conRecordTypeId = [select Id from RecordType where name='Employee'].Id;
        ESDJC_TestUtil.init(); 
        //create contact record...  
        apacContact = new Contact(); 
        apacContact.AccountId = (ESDJC_TestUtil.createAccount()).Id;
        apacContact.FirstName = 'DJC';
        apacContact.LastName = 'Dream Job Central';
        apacContact.RecordTypeId = conRecordTypeId;
        apacContact.Division__c = 'APAC - All Countries';
        insert apacContact;

        //update current userrole.. 
        System.runAs(currentUser){
         if(currentUser.userrole.Name!='ES Tech Analyst'){
            currentUser.userRoleId = TechAnalystRole;
            update currentUser;
         } 
        }
    }

    /*
        For cases where Tier never gets updated from case creation.. Example, case got created with Tier = 'Tier 1', 
        then after each run of TierBatch job, Tier age is now()-createddate.. 
    */
    private static testMethod void testCaseDefaultTierAge(){
        //datasetup 
        init();
        Id apacRTID = [select Id from RecordType where developerName = 'ES_DJC_All_Case_Types_except_ER_APAC'].Id;
        Case ca1;
        ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        System.runAs(currentUser){
            ca1 = new Case(Origin='Web',Type='Benefits',RecordTypeId=apacRTID,Subject='Testing Case Tier calculations',Tier__c='Tier 1');
            if( apacContact!=null){
                ca1.contactId = apacContact.Id;
            }
            insert ca1; 
        }
        System.assertEquals(ca1.Tier__c,'Tier 1');
        Test.startTest();
        String soqlQ = 'SELECT Id,CreatedDate,IsStopped,BusinessHoursId,Tier__c,Tier_1_Age__c,Tier_2_Age__c,Tier_3_Age__c,Tier_4_Age__c from Case where isClosed = false and Tier__c!=null and Tier__c!=\'Unknown\'  and createdDate >'+ 
                        DateTime.newInstance(settings.Tier_Age_Date_Filter__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-dd-MM')+'T00:00:01.000Z'; 
        Database.ExecuteBatch(new ES_DJC_TierAgeBatch(soqlQ));
        Test.stopTest(); 
        ca1 = [select Tier_1_Age__c,Tier_2_Age__c,Tier_3_Age__c,Tier_4_Age__c from Case where id = : ca1.Id]; 
        System.assert( ca1.Tier_3_Age__c == null); 
    }


    /*
        When case is closed, Tier ages should calculated almost real-time (used future to trigger this calculations).. 
    */

    private static testMethod void testTierAgeWhenCaseIsClosed(){
            //datasetup 
        init();
        Id apacRTID = [select Id from RecordType where developerName = 'ES_DJC_All_Case_Types_except_ER_APAC'].Id;
        Case ca1;
        System.runAs(currentUser){
            ca1 = new Case(Origin='Web',Type='Benefits',ES_DJC_Topic__c='Medical',ES_DJC_Sub_Topic__c='COBRA',RecordTypeId=apacRTID,Subject='Testing Case Tier calculations',Tier__c='Tier 1',Status='New',DJC_Is_Survey_Email_Sent__c=true); 
            if( apacContact!=null){
                ca1.contactId = apacContact.Id;
            }
            insert ca1; 
        }
        Test.startTest();
        ca1.Status='Closed'; 
        ca1.PII__c = 'No';
        update ca1;
        Test.stopTest();
        ca1 = [select isClosed,Tier__c,Tier_1_Age__c from Case where id=:ca1.Id];
        System.assertEquals(ca1.Tier__c,'Tier 1');
        System.assertEquals(ca1.isClosed,true);
        System.assert(ca1.Tier_1_Age__c>0);
    }
}