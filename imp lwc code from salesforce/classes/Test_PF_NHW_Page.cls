@isTest(SeeAllData=false)
public class Test_PF_NHW_Page {
	private static testMethod void PF_NHW_PageTest() {
        Case ca;
        RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1];
        Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email='testmailapp@salesforce.com',RecordTypeId = employeeRT.Id);
        insert con;
        ca = new Case(contactId = con.Id,origin = 'Package Delivery',Type='Mail Services',ES_DJC_Topic__c='Package Delivery',REWS_Received_Location__c='Landmark',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
        insert ca;


        NHW_Lightning_Component__c lightningComponent = new NHW_Lightning_Component__c(Provisioning_Type__c=null,Configurator__c = 'PF_NHW_StartEndDateConfigurator', Id__c = 'pf_nhw_basic_information_business_site', Name = 'Business Site', Page__c = 'Basic Information', Fields__c = 'NH_Business_Site__c');
        insert lightningComponent;

        NHW_Lightning_Component_Configuration__c lightningComponentConfiguration = new NHW_Lightning_Component_Configuration__c(Attribute__c ='visible', Criteria__c ='Office_Country__c != Japan && Office_Country__c != JP && NHW_Job_Application__r.Job__r.Employment_Type__c !IN Intern|Contractor', NHW_Lightning_Component__c = lightningComponent.Id);        
        insert lightningComponentConfiguration;


        NHW_Lightning_Component_Configuration__c lightningComponentConfiguration2 = new NHW_Lightning_Component_Configuration__c(Attribute__c ='visible', Profile_Criteria__c = 'DeskPhoneHighUse', Criteria__c ='Office_Country__c != Japan && Office_Country__c != JP && NHW_Job_Application__r.Job__r.Employment_Type__c !IN Intern|Contractor', NHW_Lightning_Component__c = lightningComponent.Id);
        insert lightningComponentConfiguration2;



        PF_NHW_Page page = PF_NHW_Page.BASIC_INFORMATION;


        PF_NHW_LightningComponentConfiguration componentConfiguration = PF_NHW_LightningComponentsService.getComponentConfiguration(ca, 'pf_nhw_basic_information_business_site');
        List<PF_NHW_LightningComponentConfiguration> componentConfigurationList = PF_NHW_LightningComponentsService.getComponentsConfigForCaseAndPage(ca, page);
		PF_NHW_Page pfPageInstance = PF_NHW_Page.getPageNameByName('Basic Information');
        System.assertNotEquals(pfPageInstance, null);

       
    }  
}