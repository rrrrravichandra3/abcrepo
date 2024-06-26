@isTest
Private class IDP_MuleSyncService_Test {
	@testSetup static void createTestData(){
        //data creation of IDP,IDP Objective and IDP Action
        IDP__c recIDP = new IDP__c(QuipId__c ='test1',Employee_Number__c ='546', Quip_Document_Id__c ='WD123');
        insert recIDP;
        IDP_Objective__c recObj = new IDP_Objective__c(IDP__c=recIdp.Id,QuipId__c ='test1');
        insert recObj;
        IDP_Action__c recAct1 = new IDP_Action__c(IDP_Objective__c=recObj.Id,QuipId__c ='test1', workdayId__c='wd1234',
                                                  Action__c='Action1',Synced__c =false,Support__c ='test support',
                                                 Status__c ='In Progress',isDeleted__c=false,Completed_Date__c=datetime.now().date());
        Insert recAct1;
        IDP_Action__c recAct2 = new IDP_Action__c(IDP_Objective__c=recObj.Id,QuipId__c ='test2',workdayId__c='WD2345', 
                                                  Action__c='Action2',Synced__c =false,Support__c ='test support',
                                                 Status__c ='In Progress',isDeleted__c=false,Completed_Date__c=datetime.now().date());
        Insert recAct2;
    } 
    
    @isTest static void testSchedule() {
        IDP_Action__c recAct1=[SELECT Id,Synced__c FROm IDP_Action__c LIMIT 1];
        System.assertEquals(false,recAct1.Synced__c);
        Test.setMock(HttpCalloutMock.class, new IDP_MuleSyncService_Mock());
		Test.StartTest();
        datetime dt=datetime.now().addSeconds(10);
		system.schedule('Job : Running at '+dt.format(), dt.format('s m H d M ? yyyy'), new IDP_MuleSyncService());
		Test.StopTest();
        recAct1=[SELECT Id,Synced__C FROm IDP_Action__c where id=:recAct1.Id];
        System.assert(true,recAct1.Synced__c);
	}  
}