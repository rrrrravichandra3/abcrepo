/**
* W-12578116
* Test Utility Class for M&A Test data
* 
* 
* Version      Date            Author                  Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         21/04/2023      Manish Pal		       Test Utility Class for M&A Test data
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class MA_DS_TestUtility {
    
    //Variables
    public static String PACKAGE_NAME_SUFFIX = 'Package';
    public static List<String> PACKAGE_NAMES = new List<String> {'Western Europe', 'Central & Eastern Europe', 'Asia', 'Africa', 'Mediterranean & Middle East', 'Americas'};
    
    public static String DOCUMENT_PACKAGE  = 'Package Document';
    public static String DOCUMENT_SUMMARY  = 'Manager Summary';

    public static List<String> TEMPLATE_NAMES = new List<String> {'Offer Letter', 'Employment Contract', 'Equity Letter', 'PIIA', 'Remote Worker Addendum', 'Worker Compensation Guide', 'New Hire Security', 'Salesforce Code of Conduct', 'Salesforce Employee Handbook', 'Employee Rights', 'Manager Summary'};
    public static List<String> DOCUMENT_TYPES = new List<String> {DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_PACKAGE, DOCUMENT_SUMMARY};
    public static List<Boolean> MERGE_CAPABLE_LIST = new List<Boolean> {true, true, true, true, true, true, true, false, false, false, true};
    public static List<String> TEMPLATE_SAMPLE_SIZE = new List<String> {'2', '2', '2', '2', '2', '2', '2', '2', '2', '2', '2'};

    public static List<String> COMMON_TEMPLATE_NAMES = new List<String> {'Global Equity Letter', 'Global OBA Form', 'Global OBA Form_Key Employees', 'Global Security Best Practices', 'Global Code of Conduct', 'Global Employee Handbook', 'Health Insurance Marketplace Exchange Notice', 'Deemed Export Questionnaire'};
    public static List<Boolean> COMMON_MERGE_CAPABLE_LIST = new List<Boolean> {true, true, true, true, false, false, false, true};
    public static List<String> COMMON_TEMPLATE_SAMPLE_SIZE = new List<String> {'2', '2', '2', '2', '2', '2', '2', '2'};
    
    /**
* ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Method to set the commonIds, used by FailureHandlerJob to identify Acquisition Contacts to process for failure.
* ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
* @param    : null
* @return   : Return acquisition company
* ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static Acquisition_Company__c createAcqCompanies() {
        Acquisition_Company__c acqcmp = new Acquisition_Company__c();
        acqcmp.Name = 'MA';
        acqcmp.Acquisition_Company_Name__c = 'MA';
        acqcmp.Category_API_Name__c = 'MA';
        acqcmp.Close_Date__c = System.today()+30;
        return acqcmp;        
    }
    
    public static User getDSAdmin(String name){
        Profile objProfile = getUserProfile('System Administrator');
        UserRole objRole = getUserRoleByType('None');
        List<User> lstUser =  createSystemAdminUser(1, objProfile.Id, objRole.Id, true, name);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'MA_Docusign_CLM_Admin'];
        insert new PermissionSetAssignment(AssigneeId = lstUser[0].Id, PermissionSetId = ps.Id);
        return lstUser[0];
    }
    
    public static UserRole getUserRoleByType(String roletype){
        return [Select Id From UserRole Where PortalType = :roletype Limit 1];
    }
    public static UserRole getUserRoleByName(String roleName){
        return [Select Id From UserRole Where Name = :roleName Limit 1];
    }
    
    public static profile getUserProfile(String profileName){
        return [Select Id from Profile where name = :profileName];
    }
    
    public static List<User> createSystemAdminUser(Integer numberOfRecords,String profileId,String dummyRoleId, Boolean doInsert, String name){
        List<User> sysAdminList = new List<User>();
        for(Integer i = 0; i < numberOfRecords; i++){
            User objUser = new User();
        	objUser.ProfileId = profileId;
            objUser.UserRoleId = dummyRoleId;
        	objUser.Username = name+'_testadmin'+String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
        	objUser.Alias = 'admin'+String.valueOf(i);
        	objUser.Email = name+'test_'+String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
        	objUser.EmailEncodingKey='UTF-8';
        	objUser.Firstname='System_Admin_'+String.valueOf(i);
        	objUser.Lastname='Admin_User_'+String.valueOf(i);
        	objUser.LanguageLocaleKey='en_US';
        	objUser.LocaleSidKey='en_US';
        	objUser.TimeZoneSidKey='America/Chicago';
            sysAdminList.add(objUser);
        }
        if(doInsert){
            insert sysAdminList;
        }
        return sysAdminList;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create/return acquisition contacts
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    AcqCompaniesId	:  Parent company is passed to create the associated contacts
    * @param    noOfRecords     :  Defines no of contacts that needs to be created for test data
    * @return   Return list of acquisition contacts
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> createAcqContacts(Id AcqCompaniesId,Integer noOfRecords) {
        List<Acquisition_Contacts__c> listofAcqContacts = new List<Acquisition_Contacts__c>();
        for(Integer i=0;i<noOfRecords;i++){
            Acquisition_Contacts__c acqcontacts = new Acquisition_Contacts__c();
            acqcontacts.Name = 'Test Contact 1'+i;
            acqcontacts.Confirmed_On__c = System.now();
            acqcontacts.Acquisition_Company__c = AcqCompaniesId;
            acqcontacts.Acquisition_Org__c = 'Test Org'+i;
            acqcontacts.Active_at_Close__c = true;
            acqcontacts.Email_Address_Target__c = 'm.pal@salesforce.com';
            acqcontacts.Offer_Date_Target__c = System.today()+25;
            acqcontacts.Office_Address_City__c = 'Bangalore';
            acqcontacts.Office_Address_Country__c = 'India';
            acqcontacts.Office_Address_State_Province__c = 'KA';
            acqcontacts.Office_Address_Street__c = 'MG Road';
            acqcontacts.Office_Address_Zip_Postal_Code__c = '560099';
            acqcontacts.Onboarding_Group__c = 'MA Group';
            acqcontacts.MA_DS_BI_Initiation_URL__c = 'https://data.com';
            acqcontacts.MA_DS_Custom_Reminder_Email__c = 'm.pal@salesforce.com';
            acqcontacts.MA_DS_Custom_Welcome_Email__c = 'm.pal@salesfo.com';
            acqcontacts.MA_DS_Deem_Exp_Control_Questionnaire_Dec__c = 'Yes';
            acqcontacts.MA_DS_Docusign_Custom_Message__c = 'MA Group';
            acqcontacts.MA_DS_Email_Address_Type__c = 'Salesforce Email Address';
            acqcontacts.MA_DS_Envelope_Void_Period_Days__c = 3;
            acqcontacts.MA_DS_Manager_Summary_Async_Apex_Id__c = '001283720'+i;
            acqcontacts.MA_DS_Manager_Summary_Common_Id__c = '001283720'+i;
            acqcontacts.MA_DS_Manager_Summary_Email_Body__c = 'Salesforce Email';
            acqcontacts.MA_DS_Manager_Summary_Email_Subject__c = 'Salesforce Acquisition';
            acqcontacts.MA_DS_Manager_Summary_Stage__c = 'Not Started';
            acqcontacts.MA_DS_PIIA_Declared_By_Acquired_Contact__c = 'Yes';
            acqcontacts.MA_DS_Previous_Envelope_Void_Date__c = System.today()+25;
            acqcontacts.MA_DS_Reminder_Email_CC__c = 'Prepping';
            acqcontacts.Employee_ID_Target__c = '907647897';
            listofAcqContacts.add(acqcontacts);
        }
        return listofAcqContacts;    
    }
    
    public static List<MA_DS_Package__c> getMasterPackages() {
        List<MA_DS_Package__c> masterPackages = new List<MA_DS_Package__c>();
        for(String packageName : PACKAGE_NAMES) {
            MA_DS_Package__c masterPackage = new MA_DS_Package__c();
            masterPackage.MA_DS_Package_Type__c = 'Acquisition Master Package';
            masterPackage.Name = packageName + ' ' + PACKAGE_NAME_SUFFIX;
            masterPackage.MA_DS_Package_Description__c = packageName + ' ' + PACKAGE_NAME_SUFFIX + ' Description';
            masterPackages.add(masterPackage);
        }
        System.debug('masterPackages size : ' + masterPackages.size());
        return masterPackages;
    }

    public static List<MA_DS_Template__c> getMasterTemplates() {
        List<MA_DS_Template__c> masterTemplates = new List<MA_DS_Template__c>();
        for(String packageName : PACKAGE_NAMES) {
            masterTemplates.addAll(getMasterUniqueTemplates(packageName));
        }
        masterTemplates.addAll(getMasterCommonTemplates());
        System.debug('masterTemplates size : ' + masterTemplates.size());
        return masterTemplates;
    }

    public static List<MA_DS_Template__c> getMasterUniqueTemplates(String packageName) {
        List<MA_DS_Template__c> uniqueTemplates = new List<MA_DS_Template__c>();
        for(Integer i=0; i < TEMPLATE_NAMES.size(); i++) {
            MA_DS_Template__c uniqueTemplate = new MA_DS_Template__c();
            uniqueTemplate.MA_DS_Template_Type__c = 'Master Template';
            uniqueTemplate.Name = packageName + ' - ' + TEMPLATE_NAMES[i];
            uniqueTemplate.MA_DS_Merge_Capable__c = MERGE_CAPABLE_LIST[i];
            uniqueTemplate.MA_DS_Template_Document_Type__c = DOCUMENT_TYPES[i];
            //uniqueTemplate.MA_DS_Maximum_Sample_Size__c = TEMPLATE_SAMPLE_SIZE[i];
            uniqueTemplates.add(uniqueTemplate);
        }
        System.debug('uniqueTemplates size : ' + uniqueTemplates.size());
        return uniqueTemplates;
    }

    public static List<MA_DS_Template__c> getMasterCommonTemplates() {
        List<MA_DS_Template__c> commonTemplates = new List<MA_DS_Template__c>();
        for(Integer i=0; i < COMMON_TEMPLATE_NAMES.size(); i++) {
            MA_DS_Template__c commonTemplate = new MA_DS_Template__c();
            commonTemplate.Name = COMMON_TEMPLATE_NAMES[i];
            commonTemplate.MA_DS_Template_Type__c = 'Master Template';
            commonTemplate.MA_DS_Template_Document_Type__c = DOCUMENT_PACKAGE;
            commonTemplate.MA_DS_Merge_Capable__c = COMMON_MERGE_CAPABLE_LIST[i];
            commonTemplates.add(commonTemplate);
        }
        return commonTemplates;
    }

    public static List<MA_DS_In_Use_Template__c> getInUseMasterTemplates(List<MA_DS_Package__c> masterPackages, List<MA_DS_Template__c> masterTemplates) {
        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = new List<MA_DS_In_Use_Template__c>();
        for(MA_DS_Package__c masterPackage : masterPackages) {
            inUseMasterTemplates.addAll(getPackageInUseMasterTemplates(masterPackage, masterTemplates));
        }
        System.debug('inUseMasterTemplates size : ' + inUseMasterTemplates.size());
        return inUseMasterTemplates;
    }

    public static List<MA_DS_In_Use_Template__c> getPackageInUseMasterTemplates(MA_DS_Package__c masterPackage, List<MA_DS_Template__c> masterTemplates) {
        List<MA_DS_In_Use_Template__c> packageInUseMasterTemplates = new List<MA_DS_In_Use_Template__c>();
        for(MA_DS_Template__c masterTemplate : masterTemplates) {
            List<String> templateNameSplitList = masterTemplate.Name.split(' - ');
            if(templateNameSplitList.size() == 1 || templateNameSplitList[0].equalsIgnoreCase(masterPackage.Name.remove(' Package'))) {
                MA_DS_In_Use_Template__c packageInUseMasterTemplate = new MA_DS_In_Use_Template__c();
                packageInUseMasterTemplate.MA_DS_Package_Using__c = masterPackage.Id;
                packageInUseMasterTemplate.MA_DS_Template_Being_Used__c = masterTemplate.Id;
                packageInUseMasterTemplates.add(packageInUseMasterTemplate);
            }
        }
        return packageInUseMasterTemplates;
    }
    
    public static MA_DS_Package_Distribution__c createPackageDistribution(Id packageId) {
       	MA_DS_Package_Distribution__c pckgDistribution = new MA_DS_Package_Distribution__c();	
        pckgDistribution.Name = 'Test Distribution';
        pckgDistribution.MA_DS_Package_Distribution_Stage__c = 'In Definition';
        pckgDistribution.MA_DS_Package__c = packageId;
        pckgDistribution.MA_DS_Rules_Sync_Status__c = 'Need Sync - Package & Template Rules';
        pckgDistribution.MA_DS_Status__c = 'In Definition';
        pckgDistribution.MA_DS_Rules_Criteria_Query__c = '{"queryString":"SELECT Id, (SELECT Id FROM Acquisition_Compensation__r WHERE Car_Allowance_Amount__c > :var1 LIMIT 1) FROM Acquisition_Contacts__c WHERE (Office_Address_Country__c IN :var2 AND Office_Address_State_Province__c = :var3 AND Executive__c = :var4 AND Confirmed_On__c = :var5 AND Contractor_End_Date__c > :var6)","bindTypeMap":{"var6":"DATE","var5":"DATETIME","var4":"BOOLEAN","var3":"STRING","var2":"PICKLIST","var1":"CURRENCY"},"bindMap":{"var6":"2023-06-10","var5":"2023-05-02T08:13:00.000Z","var4":false,"var3":"Karnataka","var2":["India"],"var1":10.0}}';
        pckgDistribution.MA_DS_Rules_Criteria_JSON__c = '{"ruleLogicMap":{"Acquisition_Contacts__c":["1","AND","2","AND","3","AND","4","AND","5"],"Acquisition_Compensation__c":["1"]},"fieldValueMap":{"Acquisition_Contacts__ccontractor_end_date__c5":"2023-06-10","Acquisition_Contacts__cconfirmed_on__c4":"2023-05-02T13:43:00.000Z","Acquisition_Contacts__coffice_address_state_province__c2":"Karnataka","Acquisition_Contacts__coffice_address_country__c1":"India","Acquisition_Contacts__cexecutive__c3":"False","Acquisition_Compensation__ccar_allowance_amount__c1":"10"},"fieldRowMap":{"Acquisition_Contacts__c":[{"value":"office_address_country__c","type":"PICKLIST","name":"Office_Address_Country__c","label":"Office Address - Country"},{"value":"office_address_state_province__c","type":"STRING","name":"Office_Address_State_Province__c","label":"Office Address - State/Province"},{"value":"executive__c","type":"BOOLEAN","name":"Executive__c","label":"Executive"},{"value":"confirmed_on__c","type":"DATETIME","name":"Confirmed_On__c","label":"Acknowledged On"},{"value":"contractor_end_date__c","type":"DATE","name":"Contractor_End_Date__c","label":"Contractor End Date"}],"Acquisition_Compensation__c":[{"value":"car_allowance_amount__c","type":"CURRENCY","name":"Car_Allowance_Amount__c","label":"Allowance Amount"}]},"fieldOperatorMap":{"Acquisition_Contacts__ccontractor_end_date__c5":"GREATER THAN","Acquisition_Contacts__cconfirmed_on__c4":"EQUALS","Acquisition_Contacts__coffice_address_state_province__c2":"EQUALS","Acquisition_Contacts__coffice_address_country__c1":"CONTAINS","Acquisition_Contacts__cexecutive__c3":"EQUALS","Acquisition_Compensation__ccar_allowance_amount__c1":"GREATER THAN"},"customLogicMap":{"Acquisition_Contacts__c":true,"Acquisition_Compensation__c":false}}';
        return pckgDistribution;
     }
}