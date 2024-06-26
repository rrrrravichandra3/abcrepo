@istest
public with sharing class Test_SEF_Ext_NHW_HM_TaskHub_Builder {
    
    static final string ASSERT_MSG = 'Activity generated';
    
    @testSetup
    static void createData() {    
        Contact manager = new Contact(LastName = 'Test');
        insert manager;
        Case provCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provCase.Manager_Name__c = manager.id;
        insert provCase;
    }
    

    
    @istest
    static void testCompleteNHWActivity() {
        Case c = [select id from case];
        List<SEF_Ext_Service_Input> sefInput = new List<SEF_Ext_Service_Input>();
        SEF_Ext_Service_Input i = new SEF_Ext_Service_Input();
        i.SystemName = 'NHW';
        i.activityTypeName = 'nhw-complete-new-hire-wizard-activity';
        i.sObjId = c.id;
        i.isComplete = false;
        sefInput.add(i);
        SEF_Ext_ActivityStream_Builder builder = new SEF_Ext_NHW_HM_TaskHub_Builder();
        builder.setActivityType('SEF_Ext_Activity_Type_HM_Complete_NHW');
        List<SEF_ActivityStream> activity = builder.build(sefInput);
        System.assert(activity.size() > 0 , ASSERT_MSG);
    }
    
    @istest
    static void testRedHotNHActivity() {
        Case c = [select id from case];
        List<SEF_Ext_Service_Input> sefInput = new List<SEF_Ext_Service_Input>();
        SEF_Ext_Service_Input i = new SEF_Ext_Service_Input();
        i.SystemName = 'NHW';
        i.activityTypeName = 'nhw-red-hot-new-hire-activity';
        i.sObjId = c.id;
        i.isComplete = false;
        sefInput.add(i);
        SEF_Ext_ActivityStream_Builder builder = new SEF_Ext_NHW_HM_TaskHub_Builder();
        builder.setActivityType('SEF_Ext_Activity_Type_HM_RedHot_NH');
        List<SEF_ActivityStream> activity = builder.build(sefInput);
        System.assert(activity.size() > 0 , ASSERT_MSG);
    }
    
}