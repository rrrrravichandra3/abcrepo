@istest
public class Test_PF_NHW_TrainingsPageService {

    private static String TRAINING_BECOMING_SALESFORCE = 'Becoming Salesforce';
         
	@testSetup 
    static void setupData() {
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWProvisionings();
        Test_PF_NHW_ProvisioningTypeTestFactory.createNHWLightningComponents();
        NHW_Lightning_Component__c lc1 = [select id from NHW_Lightning_Component__c where id__c = 'pf_nhw_training'];
        NHW_Lightning_Component_Configuration__c lcc1 = new NHW_Lightning_Component_Configuration__c();
        lcc1.Attribute__c = 'pastSubEditable';
        lcc1.CurrencyIsoCode='USD';
        lcc1.Criteria__c = 'NHW_Employee_Type__c != Contractor';
        lcc1.NHW_Lightning_Component__c = lc1.id;
        insert lcc1;
        NHW_Lightning_Component_Configuration__c lcc2 = new NHW_Lightning_Component_Configuration__c();
        lcc2.Attribute__c = 'visible';
        lcc2.CurrencyIsoCode='USD';
        lcc2.Criteria__c = 'NHW_Job_Application__r.Job__r.Employment_Type__c !IN Intern|Contractor';
        lcc2.NHW_Lightning_Component__c = lc1.id;
        insert lcc2;
		Onboarding_Setting__c setting = new Onboarding_Setting__c();
        setting.JWT_Aud_Endpoint__c = 'https://testtest.com';
        setting.JWT_User_Name__c = 'test@salesforce.com';
        setting.Org62_Consumer_Key__c = 'testkey';
        setting.Org62_Service_Endpoint__c = 'https://test.com';
        setting.Org62_Token_Endpoint__c = 'https://test.com';
        setting.PF_Certificate__c = 'NHW_CERTIFICATE';
        insert setting;   
                insert new Contact(email = 'trail@guide.com', lastName = 'buddy');
    }
    
    @isTest
    public static void validate_Trainings_Visible_FTE() {
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        Test.startTest();
        //set base PF_NHW_PageService base class attributes
        PF_NHW_PageService pageService = new PF_NHW_TrainingsPageService();
        Map<String, Object> pageinfo = pageService.getPageInformation('regular employee',provisioningCase.id);
        Object compConfigList = pageinfo.get('PAGE_CONFIG');
        Test.stopTest();
    	Map<String, Object> m = (Map<String, Object>) compConfigList;
        System.assertEquals(m.get('pageTitle'),System.Label.NHW_Page_4_title_FTE, 'Page title should be FTE');
    }
    
    @isTest
    public static void validate_Submit_Button_FTE() {
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Trail_Guide__c = [select id from contact where email = 'trail@guide.com'].id;
        Test.startTest();
        //set base PF_NHW_PageService base class attributes
        PF_NHW_PageService pageService = new PF_NHW_TrainingsPageService();
        Map<String,Object> additionalInfo = new Map<String,Object>();
        List<PF_NHW_TrainingProvisioningTypeService.TrainingOptions> TrainingOptions = new List<PF_NHW_TrainingProvisioningTypeService.TrainingOptions>();
        PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning info = new PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning(TrainingOptions,TRAINING_BECOMING_SALESFORCE,false,
                                    TRAINING_BECOMING_SALESFORCE,true,TRAINING_BECOMING_SALESFORCE,'contactid',null);
        Object o = info;
        additionalInfo.put('TRAININGSELECTIONS',new List<Object>{o});
        string caseid = pageService.processInformation(provisioningCase,additionalInfo,false);
        Test.stopTest();
        Case c = [select id,Onboarding_Buddy_Email__c,NH_Training_Email_Merge__c from case];
        System.assertEquals(c.Onboarding_Buddy_Email__c, 'trail@guide.com', 'Email should be populated');
        System.assert(c.NH_Training_Email_Merge__c.contains(TRAINING_BECOMING_SALESFORCE), 'NH Training Email should contain Training Title');

    }
    
    @isTest
    public static void validate_ReviewList() {
        Case provisioningCase = Test_PF_NHW_ProvisioningTypeTestFactory.getMockProvisioningCase();
        provisioningCase.NHW_Trail_Guide__c = [select id from contact where email = 'trail@guide.com'].id;
        Test.startTest();
        //set base PF_NHW_PageService base class attributes
        PF_NHW_PageService pageService = new PF_NHW_TrainingsPageService();
        Map<String,Object> additionalInfo = new Map<String,Object>();
        List<PF_NHW_TrainingProvisioningTypeService.TrainingOptions> TrainingOptions = new List<PF_NHW_TrainingProvisioningTypeService.TrainingOptions>();
        PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning info = new PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning(TrainingOptions,TRAINING_BECOMING_SALESFORCE,false,
                                    TRAINING_BECOMING_SALESFORCE,true,TRAINING_BECOMING_SALESFORCE,'contactid',null);
        Object o = info;
        additionalInfo.put('TRAININGSELECTIONS',new List<Object>{o});
        string caseid = pageService.processInformation(provisioningCase,additionalInfo,false);
        List<PF_NHW_PageService.ReviewItem> reviewList = pageService.getReviewList(provisioningCase,PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c));
        Test.stopTest();
        System.assertEquals(TRAINING_BECOMING_SALESFORCE, reviewList[0].label, TRAINING_BECOMING_SALESFORCE);
        System.assertEquals('buddy', reviewList[1].value, 'buddy');

    }


}