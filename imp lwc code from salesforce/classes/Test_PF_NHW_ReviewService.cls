@isTest
public class Test_PF_NHW_ReviewService {

    @testSetup
    static void setupData() {
        String defaultEmail = 'standarduser@sandboxNHW.com';
        UserRole r = [select id from userrole where name = 'IT NH Admin'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email=defaultEmail, 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,userroleid = r.id,
            TimeZoneSidKey='America/Los_Angeles', UserName=defaultEmail);
        System.runAs(new User(id=UserInfo.getUserId())) {
               	   insert u;
        }
       Contact con = new Contact(Status__c = 'Active',Email = defaultEmail,lastname = 'ad', recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId());
        insert con;
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWLightningComponents();
        Case c = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        Tf2_Business_Site__c buSite = [select id,name from Tf2_Business_Site__c where id =: c.NH_Business_Site__c];
        buSite.Name = 'California';
        update buSite;
        c.Internal_Support_Category__c = 'New Hire Onboarding Request - Employee';
        c.Division__c = 'AMER';
        c.Business_Unit_NHW__c = '0001-Non Operating';
        c.Cost_Center_NHW__c = '0001-Non Operating';
        c.Existing_Equipment__c = false;
        c.Laptop_Type__c = '14“ MacBook M1 Pro';
        c.NHW_Organization__c = 'Sales';
        c.NHW_Role__c = 'Sales Leader';
        c.Offer_Type__c = 'External (normal) hire';
        c.Office_Address__c = 'Maple Lane';
        c.Office_City__c = 'Dublin';
        c.Shipping_Address__c = 'Maple Lane';
        c.NHW_Training__c = '[{"TrainingType":"Becoming Salesforce","org62ContactId":"","isEnrolled":false,"CampaignId":"701Q0000000TzHDIA7"}]';
                insert c;

        NHW_Provisioning__c prov = [select id from NHW_Provisioning__C where name = 'Org62' limit 1];
        NHW_Software_Access_Provisioning__c softacc = new NHW_Software_Access_Provisioning__c(Provisioning_Name__C = 'Org62',Provisioning_ID__c = prov.id,Configuration__c = 'Name: test user; UserName: test@peopleforce.com.pfdev5',selected__C = true,Provisioning_Case__c = c.id);
        insert softacc;
    }
    
    @istest
    static void validate_ReviewPage() {
        Case provisioningCase = [select id from Case];
        Test.startTest();
        provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
        PF_NHW_PageService pageService = new PF_NHW_ReviewService();
        Map<String, Object> pageinfo = pageService.getPageInformation('regular employee',provisioningCase.id);
        Map<String,Object>  compConfigList = (Map<String,Object>) pageinfo.get('PAGE_CONFIG');
        Test.stopTest();
        List<PF_NHW_ReviewService.ReviewItemGroup> config = (List<PF_NHW_ReviewService.ReviewItemGroup>)compConfigList.get('REVIEW_ITEMS');
        System.assertEquals('Test New Hire 1', config[0].reviewItems[0].value);
    }
    
    @istest
    static void validate_Submit() {
        Case provisioningCase = [select id from Case];
        Test.startTest();
        provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(provisioningCase.id);
        PF_NHW_PageService pageService = new PF_NHW_ReviewService();
        String s = pageService.processInformation(provisioningCase,null,false);
        Test.stopTest();
        provisioningCase = [select id,NHW_Access_COde__c from Case];
		System.assert(provisioningCase.NHW_Access_COde__c != null);
    }
}