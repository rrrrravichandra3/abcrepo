@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
@isTest
public class NHW_TestFactory{

    private static String TRAINING_BECOMING_SALESFORCE = 'Becoming Salesforce';
    
    public static Id accId{
        set;
        get{
            if(accId == null){
                Id accountOwnerProfileId = [Select Id from Profile where name = 'APEX Only - Peopleforce Account Owner' Limit 1].Id;
                String orgId = UserInfo.getOrganizationId();
    			String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    			Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    			String uniqueName = orgId + dateString + randomInt;
                User accountOwner =  new User(username=uniqueName + '@test' + orgId + '.org',
                                   lastName='testAccountOwner',
                                   email='testAccountOwner@salesforce.com.test',
                                   alias='tchmngr1',
                                   timeZoneSidKey='America/Los_Angeles',
                                   localeSidKey='en_US',
                                   emailEncodingKey='ISO-8859-1',
                                   LanguagelocaleKey='en_US',
                                   ProfileID = accountOwnerProfileId);
                User currUser = [select id from User where id=:userInfo.getUserId()];
                
                System.runAs(currUser) {
                insert accountOwner;  
                }
                
                Id accRId = [select Id,name  from RecordType where developerName='Candidate' and SobjectType='Account'].Id;
                acc = new Account(Name='Candidates',recordTypeId=accRId);
                system.runAs(accountOwner) {
                    insert acc;
                }
                accId = acc.Id;
                
            }
            return accId;
        }
    }
    
    public static TF2_Department__c costCenter;
    public static Business_Unit__c bUnit;
    public static Business_Unit__c NonMktbUnit;
    public static TF2_PCC__c pcc;
    public static TF2_Company__c company;
    public static TF2_Company__c Japancompany;
    public static Job_Profile__c jobProfile;
    public static TF2_Business_Site__c businessSite;
    public static TF2_Business_Site__c RemotebusinessSite;
    public static Contact con;
    public static Account acc;
    
    public static List<SObject> insertRecords(List<sObject> records){
        insert records;
        return records;
    }
    
    public static Id nhwPreBoardCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId();
    public static Id nhwOnBoardCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId();
    
    public static void prepareMockResponse(String resourceName, Integer statusCode){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(resourceName);
        mock.setStatusCode(statusCode);
        mock.setHeader('Content-Type', 'application/json');
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
    }
    
    public static string getMockCampaignsJSON(){
        
        system.debug(LOGGINGLEVEL.INFO,'Inside Mock Campaigns:');
        NHW_Org62Service.org62Data org62dataObj = new NHW_Org62Service.org62Data();
        NHW_Org62Service.CampaignResult nonSalesCampaign = new NHW_Org62Service.CampaignResult();
        NHW_Org62Service.CampaignResult SalesCampaign    = new NHW_Org62Service.CampaignResult();
        NHW_Org62Service.CampaignResult CSGBootCampaign = new NHW_Org62Service.CampaignResult();
        NHW_Org62Service.CampaignResult SalesBootCampaign    = new NHW_Org62Service.CampaignResult();   			
        NHW_Org62Service.CampaignResult seCampaign    = new NHW_Org62Service.CampaignResult();   			
        NHW_Org62Service.CampaignResult tp1Campaign    = new NHW_Org62Service.CampaignResult();   			
        NHW_Org62Service.CampaignResult tp2Campaign    = new NHW_Org62Service.CampaignResult();   			
        NHW_Org62Service.CampaignResult BecomingSalesforceCampaign   = new NHW_Org62Service.CampaignResult();   
        NHW_Org62Service.CampaignResult BecomingSalesforceCampaign2   = new NHW_Org62Service.CampaignResult();   			    
        
        CSGBootCampaign.MaxAttendees='100';
        CSGBootCampaign.campaignId='701Q0000000TzHDIA0';
        CSGBootCampaign.campaignItemId=null;
        CSGBootCampaign.campaignName=NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22);
        CSGBootCampaign.campaignStartDate=system.today()+22;
        CSGBootCampaign.campaignType=NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE;
        CSGBootCampaign.numberOfContacts='10';
        
        SalesBootCampaign.MaxAttendees='100';
        SalesBootCampaign.campaignId='701Q0000000TzHDIA1';
        SalesBootCampaign.campaignItemId=null;
        SalesBootCampaign.campaignName=NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(22);
        SalesBootCampaign.campaignStartDate=system.today()+22;
        SalesBootCampaign.campaignType=NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE;
        SalesBootCampaign.numberOfContacts='10';	
        
        seCampaign.MaxAttendees='100';
        seCampaign.campaignId='701Q0000000TzHDIA2';
        seCampaign.campaignItemId=null;
        seCampaign.campaignName=NHW_Util.INTERNAL_TRAINING_SEBOOTCAMP_CAMPAIGN_TYPE+'-'+system.today().adddays(30);
        seCampaign.campaignStartDate=system.today()+30;
        seCampaign.campaignType=NHW_Util.INTERNAL_TRAINING_SEBOOTCAMP_CAMPAIGN_TYPE;
        seCampaign.numberOfContacts='10';
        
        TP1Campaign.MaxAttendees='100';
        TP1Campaign.campaignId='701Q0000000TzHDIA3';
        TP1Campaign.campaignItemId=null;
        TP1Campaign.campaignName=NHW_Util.INTERNAL_TRAINING_TPBOOTCAMP1_CAMPAIGN_TYPE+'-'+system.today().adddays(30);
        TP1Campaign.campaignStartDate=system.today()+30;
        TP1Campaign.campaignType=NHW_Util.INTERNAL_TRAINING_TPBOOTCAMP1_CAMPAIGN_TYPE;
        TP1Campaign.numberOfContacts='10';
        
        TP2Campaign.MaxAttendees='100';
        TP2Campaign.campaignId='701Q0000000TzHDIA4';
        TP2Campaign.campaignItemId=null;
        TP2Campaign.campaignName=NHW_Util.INTERNAL_TRAINING_TPBOOTCAMP2_CAMPAIGN_TYPE+'-'+system.today().adddays(30);
        TP2Campaign.campaignStartDate=system.today()+30;
        TP2Campaign.campaignType=NHW_Util.INTERNAL_TRAINING_TPBOOTCAMP2_CAMPAIGN_TYPE;
        TP2Campaign.numberOfContacts='10';
        
        nonSalesCampaign.MaxAttendees='100';
        nonSalesCampaign.campaignId='701Q0000000TzHDIA5';
        nonSalesCampaign.campaignItemId=null;
        nonSalesCampaign.campaignName=TRAINING_BECOMING_SALESFORCE+'-'+system.today().month();
        nonSalesCampaign.campaignStartDate=system.today()+20;
        nonSalesCampaign.campaignType=NHW_Util.INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE;
        nonSalesCampaign.numberOfContacts='10';
        
        SalesCampaign.MaxAttendees='100';
        SalesCampaign.campaignId='701Q0000000TzHDIA6';
        SalesCampaign.campaignItemId=null;
        SalesCampaign.campaignName=TRAINING_BECOMING_SALESFORCE+'-'+system.today().month()+'-'+'Sales';
        SalesCampaign.campaignStartDate=system.today()+20;
        SalesCampaign.campaignType=NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE;
        SalesCampaign.numberOfContacts='10';
        
        BecomingSalesforceCampaign.MaxAttendees='100';
        BecomingSalesforceCampaign.campaignId='701Q0000000TzHDIA7';
        BecomingSalesforceCampaign.campaignItemId=null;
        BecomingSalesforceCampaign.campaignName=TRAINING_BECOMING_SALESFORCE;
        BecomingSalesforceCampaign.campaignStartDate=system.today()+20;
        BecomingSalesforceCampaign.campaignType=TRAINING_BECOMING_SALESFORCE;
        BecomingSalesforceCampaign.numberOfContacts='10';
        
        BecomingSalesforceCampaign2.MaxAttendees='100';
        BecomingSalesforceCampaign2.campaignId='701Q0000000TzHDIA7';
        BecomingSalesforceCampaign2.campaignItemId=null;
        BecomingSalesforceCampaign2.campaignName=TRAINING_BECOMING_SALESFORCE;
        BecomingSalesforceCampaign2.campaignStartDate=system.today()+100;
        BecomingSalesforceCampaign2.campaignType=TRAINING_BECOMING_SALESFORCE;
        BecomingSalesforceCampaign2.Location = 'Trailhead';
        BecomingSalesforceCampaign2.numberOfContacts='10';
        
        org62dataObj.campaignList = new list<NHW_Org62Service.CampaignResult>(); 			
        org62dataObj.campaignList.add(nonSalesCampaign);
        org62dataObj.campaignList.add(SalesCampaign);
        org62dataObj.campaignList.add(SalesBootCampaign);
        org62dataObj.campaignList.add(CSGBootCampaign);
        org62dataObj.campaignList.add(seCampaign);
        org62dataObj.campaignList.add(TP1Campaign);
        org62dataObj.campaignList.add(TP2Campaign);
        org62dataObj.campaignList.add(BecomingSalesforceCampaign);
        org62dataObj.campaignList.add(BecomingSalesforceCampaign2);
        
        org62dataObj.contactId = '70668449214yyu';
        
        return JSON.serialize(org62dataObj);
        
    }
    public static string getCustomMockCampaignsJSON(map<string,set<Date>> mCampaignTypetoStartDateList){
        
        system.debug(LOGGINGLEVEL.INFO,'Inside Custom Mock Campaigns:');
        NHW_Org62Service.org62Data org62dataObj = new NHW_Org62Service.org62Data();
        org62dataObj.campaignList = new list<NHW_Org62Service.CampaignResult>(); 			   	    
        integer i=0;
        
        for(string campaignType:mCampaignTypetoStartDateList.keyset()){
            for(Date StartDate: new list<Date>(mCampaignTypetoStartDateList.get(campaignType))){
                NHW_Org62Service.CampaignResult CampaignResultObj = new NHW_Org62Service.CampaignResult();           		
                CampaignResultObj.MaxAttendees='100';
                CampaignResultObj.campaignId='701Q0000000TzHDIA'+i;
                CampaignResultObj.campaignItemId=null;
                CampaignResultObj.campaignName=campaignType+'-'+StartDate;
                CampaignResultObj.campaignStartDate=StartDate;
                CampaignResultObj.campaignType=campaignType;
                CampaignResultObj.numberOfContacts='10';            	
                
                org62dataObj.campaignList.add(CampaignResultObj);
                i++;
            }
        }
        
        return JSON.serialize(org62dataObj);
        
    }
    public static void populateNHSetting(){
        NH_Settings__c NHSetting = new NH_Settings__c();
        NHSetting.NoOfDaysBeforeStartDateToSendRemindEmail__c=5;
        insert NHSetting;
        
    }
    public static void populateOnBoardingSetting(){
        Onboarding_Setting__c setting = new Onboarding_Setting__c();
        setting.JWT_Aud_Endpoint__c = 'https://testtest.com';
        setting.Candidate_Record_Type__c = '012700000005kJT';
        setting.JWT_User_Name__c = 'test@salesforce.com';
        setting.Org62_Consumer_Key__c = 'testkey';
        setting.Org62_Service_Endpoint__c = 'https://test.com';
        setting.Org62_Token_Endpoint__c = 'https://test.com';
        setting.PF_Certificate__c = 'NHW_CERTIFICATE';
        setting.Pre_boarding_window__c = 30;
        setting.Invalid_Offer_Types__c = 'M&A;Internal transfer;Inter-department Transfer;Intra-department Transfer;Salesforce Core to .Org Transfer;.Org to Salesforce Core Transfer';
        setting.Onboarding_Record_Type_Id__c = nhwOnBoardCaseRecordTypeId;
        setting.Contractor_pre_boarding_window__c = 15;
        try{
            insert setting; 
            
            NHW_Exact_Target_BU__c ETBU = new NHW_Exact_Target_BU__c();
            ETBU.Business_Unit__c = '1605-Email';
            ETBU.Name='ET';
            insert ETBU;
            List<sObject> Ts2Setting = Test.loadData(TF2Settings__c.sObjectType, 'Ts2SettingsTest');
            TF2Settings__c ts = [select Employee_Account__c,Recruiting_Account_Id__c from TF2Settings__c limit 1];
            ts.Employee_Account__c = accId;
            ts.Recruiting_Account_Id__c = accId;
            update ts;
            
            User  u = [select Management_Level__c from user where Id=:userInfo.getUserId()]; 
            u.Management_Level__c ='1.1 CEO & Chairman';
            update u;
            
            //TODO:
            costCenter= new TF2_Department__c(Name='9997-dreamjob central' ,Active__c = true);
            insert costCenter;
            bUnit = new Business_Unit__c(Name='1605-Email',Active__c = true,BU_Code__c='9999');
            insert bUnit;
            NonMktbUnit = new Business_Unit__c(Name='1099-Sales-Other',Active__c = true,BU_Code__c='9998');
            insert NonMktbUnit;
            
            pcc = new TF2_PCC__c(Name = '128-Brazil',Active__c = true);
            insert pcc;
            company = new TF2_Company__c(Active__c = true,Company_Code__c='011',Name='100-SFDC Inc.',Region__c='AMER');
            Japancompany = new TF2_Company__c(Active__c = true,Company_Code__c='300',Name='300-SFDC Japan',Region__c='Japan');
            list<TF2_Company__c> companies = new list<TF2_Company__c>{company,Japancompany};
                insert companies;
            
            jobProfile = new Job_Profile__c(Active__c=true,Job_Code__c='152C16',Job_Grade__c='10',Name='Software Engineering MTS',Management_Level__c='3.3 Senior Manager');
            insert jobProfile;
            
            businessSite = new TF2_Business_Site__c (Active__c=true,City__c='test',Country__c='Business unit Country',Name='test Site',Type__c='Regional Site',Street_Address__c='Test Address');
            RemotebusinessSite = new TF2_Business_Site__c (Active__c=true,City__c='test',Country__c='Business unit Remote Country',Name='Remote test Site',Type__c='Telecommuter',Street_Address__c='Test Address');
            list<TF2_Business_Site__c> bizSites = new list<TF2_Business_Site__c>();
            bizSites.add(businessSite);
            bizSites.add(RemotebusinessSite);
            insert bizSites;
            
            con = new  Contact(recordTypeId='012700000005kJT',AccountId=accId,Email='SalesForceUAT_candidate@test.com',FirstName='test',LastName='Candidate',MailingCountry='Candidate Country',MailingState='CA',EmployeeNumber__c='12345');
            insert con;
        }
        catch(Exception ex){
            system.debug('******Exception in populateOnBoardingSetting ' + ex.getMessage()+ex.getLineNumber());
            throw ex;
            
        }
        
    }
    
    public static Case createPreBoardingTktEmpId(Id conId){
        Case c = new Case();
        c.recordTypeId = nhwPreBoardCaseRecordTypeId; 
        c.NHW_Employee__c = conId;
        c.subject = 'New Hire Preboarding Request for ' +con.FirstName+' '+con.LastName;
        c.Status = 'Closed';
        return c;
        
    }
    
    
    public static Contact createCandidate(String fName, String lName,String email){
        
        Contact conT = new  Contact(recordTypeId=NHW_Util.getEmployeeContactRecordTypeId(),AccountId=accId,Email=email,FirstName=fName,LastName=lName,MailingCountry='US',MailingState='CA');
        return conT;
    }
    
    public static  Business_Unit__c createBusinessUnit() {
        Business_Unit__c businessUnit = null;
        List<Business_Unit__c> businessUnitList = [select id,name,BU_Code__c from Business_Unit__c Where BU_Code__c ='1901'];
        if (businessUnitList != null && businessUnitList.size() > 0) {
            businessUnit = businessUnitList.get(0);
        } else {
            businessUnit = new Business_Unit__c(Name='1901-Heroku',BU_Code__c='1901');
            insert businessUnit;
        }
        return businessUnit;
    }
    
    
}