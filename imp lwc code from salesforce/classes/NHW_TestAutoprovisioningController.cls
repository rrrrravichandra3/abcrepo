@istest
public with sharing class NHW_TestAutoprovisioningController {

    public static contact adminContact;
    //Grab the NH Admin users in the expected role.
    public static list<User> NHAdmins = [select Email,IsActive,contactid 
                                         from User 
                                         where userrole.name='IT NH Admin' limit 1];
    @testsetup
    public static void createAdminUsers(){
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        //Create a contact for any one of above users.
        admincontact = new Contact( AccountID = TestAcc.id, FirstName = 'Test', LastName = 'IT NH Admin',Status__c='Active',
                            email = NHAdmins[0].email,RecordTypeId=[select id,name from RecordType where sObjectType='Contact' and Name='Employee'].Id );
        insert admincontact;
    }

    public testmethod static  void  TestWDR_AutoProvisioningNotification(){

        admincontact = [select id,name from contact where email= :NHAdmins[0].email];

        WDR_TestFactory testdata = new WDR_TestFactory();
        testdata.setStartDate(system.today().adddays(5));
        testdata.setCandidateStage('Placement');
        
        Test.starttest();      
            testdata.createJobApp();
            WDR_Application__c jobApp = testdata.getDefaultJobApp();
        Test.stoptest();
        list<case> cases = [select id ,status,subject from case where NHW_Job_Application__c = :jobApp.id];
        system.assertNotEquals(cases.size(),0,'Expecting preboarding case'); 

        for(case c:cases ){
            c.status='Closed';
        }
        update cases ;    


        NHW_WDRAutoprovisioningNotification provcls = new NHW_WDRAutoprovisioningNotification();
        provcls.sendAutoProvisioningReportEmail();

        list<PF_Debug_Log__c> logs = [select Error_Type__c,description__c 
                                      from PF_Debug_Log__c ];

        system.assertEquals(logs.size(),0,'no error'+logs);

  


        JobApp = [ select id,start_date__c,Auto_Provisioning_Email_Sent__c,(select id,contactid from cases__r)
                                      from WDR_Application__c];       

        system.assertEquals(JobApp.Auto_Provisioning_Email_Sent__c,true,'Expecting auto prov notification');
        
        list<Delegate__c> del = [select id,name from  delegate__c 
                                 where manager__c=:JobApp.cases__r[0].contactid
                                 and Delegate__c = :admincontact.id];
        //list<Delegate__c> del = [select id,name,manager__c,Delegate__c from delegate__c];                         
        //system.assertequals(del.size(),0,'Expecting NH Admin to be inserted as delegate'+del+JobApp.cases__r[0].contactid+NHAdmins[0].contactid);

         
    }   
}