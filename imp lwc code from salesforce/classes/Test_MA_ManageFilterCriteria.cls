/**
* Test Class for MA_ManageFilterCriteria
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         04-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class Test_MA_ManageFilterCriteria {
	
    @testSetup
    static void setuptestdata(){
        List<Acquisition_Company__c> lstCompany = MA_TestUtil.createAcquisitionCompany(1,true);
        MA_TestUtil.createAcqContact(1, lstCompany[0].Id, true);
        MA_TestUtil.createAcquisitionCompanyTask(lstCompany[0].Id,1,true);
    } 
    
    public static TestMethod void test_getFieldsSchema(){
        Test.StartTest();
        	String fieldSchema = MA_ManageFilterCriteria.getFieldsSchema('Acquisition_Contacts__c');
        Test.StopTest();
        Assert.isNotNull(fieldSchema);
    }
    
    public static TestMethod void test_getRecordDetails(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c 
                                                         FROM Acquisition_Company_Task__c];
        Test.StartTest();
        	sObject acqCompanyTask = MA_ManageFilterCriteria.getRecordDetails(listComptask[0].Id);
        Test.StopTest();
        Assert.areEqual(acqCompanyTask.Id , listComptask[0].Id);
        
        
    }
    
    public static TestMethod void test_updateFilterCriteriaJSON(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c, Filter_Criteria_JSON__c 
                                                         FROM Acquisition_Company_Task__c];

        String criteria = '{"Acquisition_Contacts__c":[{"fieldName":"Background_Check__c","fieldLabel":"Background Check","operator":"EQUALS","value":"Distributed to Employee","dataType":"PICKLIST","index":1}],"Acquisition_Provisioning__c":[],"Acquisition_Compensation__c":[],"CustomLogics":{"Acquisition_Contacts__c":"","Acquisition_Compensation__c":"","Acquisition_Provisioning__c":""}}';
        String querySring = 'SELECT Id, (SELECT Id FROM Acquisition_Compensation__r ) , (SELECT Id FROM Acquisition_Provisioning__r ) FROM Acquisition_Contacts__c WHERE Background_Check__c = \'Distributed to Employee\' AND Acquisition_Company__c = \'' + listComptask[0].Id +'\' AND Contact_Status__c != \'Cancelled\' ';
        Test.StartTest();
        	MA_ManageFilterCriteria.updateFilterCriteriaJSON(listComptask[0].Id, criteria, querySring);
        Test.StopTest();
        List<Acquisition_Company_Task__c> updatedlistComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c, Filter_Criteria_JSON__c 
                                                         FROM Acquisition_Company_Task__c];
        Assert.areEqual(updatedlistComptask[0].Filter_Criteria_JSON__c, criteria);
    }
    
    public static TestMethod void test_updateFilterCriteriaJSONException(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Status__c, Active__c 
                                                         FROM Acquisition_Company_Task__c];

        String criteria = '{"Acquisition_Contacts__c":[{"fieldName":"Background_Check__c","fieldLabel":"Background Check","operator":"EQUALS","value":"Distributed to Employee","dataType":"PICKLIST","index":1}],"Acquisition_Provisioning__c":[],"Acquisition_Compensation__c":[],"CustomLogics":{"Acquisition_Contacts__c":"","Acquisition_Compensation__c":"","Acquisition_Provisioning__c":""}}';
        String querySring = 'SELECT Id, (SELECT Id FROM Acquisition_Compensation__r ) , (SELECT Id FROM Acquisition_Provisioning__r ) FROM Acquisition_Contacts__c WHERE Background_Check__c = \'Distributed to Employee\' AND Acquisition_Company__c = ' + listComptask[0].Id +' AND Contact_Status__c != \'Cancelled\' ';
        try{
            Test.StartTest();
        	MA_ManageFilterCriteria.updateFilterCriteriaJSON(listComptask[0].Id, criteria, querySring);
        	Test.StopTest();
        }catch(Exception e){
            String expectedErrorMessage = 'Script-thrown exception';
            Assert.areEqual(expectedErrorMessage, e.getMessage());
        }
        
    }
    
    public static TestMethod void test_getFieldsSchemaException(){
        try{
            Test.StartTest();
        	MA_ManageFilterCriteria.getFieldsSchema('Acquisition_Contact__c');
        	Test.StopTest();
        }catch(Exception e){
            String expectedErrorMessage = 'Script-thrown exception';
            Assert.areEqual(expectedErrorMessage, e.getMessage());
        }
    }

}