@isTest
public with sharing class NHW_CW_ContactCaseTests {

    private static final String DEPARTMENT_NAME = '2301 - Shared Services';
    private static final String BU_NAME = '1001 - BT Technology';
    private static final String EMAIL_DOMAIN = '@example.com';
    private static final String MAILING_STREET = '750 Bing dr';
    private static final String DIVISION = 'Americas - USA';
    private static final String CW_BS_NAME = 'Test Site';
    private static final String PCC = '100 - Salesforce';
    private static final String CW_HIRE_REASON = 'Badge-Only';
    private static final String RESOURCE_TYPE = 'Deliverable: Project';
    private static final String CASE_STATUS_CLOSED_CANCELLED = 'Closed - Cancelled';

    private static final String MSG_EXPECTING_CONTACT_TO_BE_CREATED = 'Expecting Contact to be created ';
    private static final String MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE = 'Expecting Contact status to NOT be active';
    private static final String MSG_EXPECTING_ONE_CASE_TO_BE_CREATED = 'Expecting One Case to be created ';
    private static final String MSG_EXPECTING_NO_CASES_TO_CREATED = 'Expecting no cases to created';
    private static final String MSG_EXPECTING_NO_CASE_TO_BE_CREATED = 'Expecting No Case to be created ';
    private static final String MSG_EXPECTING_NO_CASE_TO_BE_CREATED_AS_LOOKUPS_ARE_EMPTY = 'Expecting No Case to be created as lookups are empty';
    private static final String MSG_EXPECTING_ERROR_LOGS = 'Expecting error logs';
    private static final String MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST = 'Before Update a Case should exist';
    private static final String MSG_EXPECTING_UPDATES_TO_CASCADE_TO_CASE = 'Expecting updates to cascade to Case';
    private static final String MSG_EXPECTING_ONLY_ONE_CASE_TO_BE_CREATED = 'Expecting ONLY one Case to be created';
    private static final String MSG_BEFORE_UPDATE_TO_CW_ONLY_ONE_CASE_TO_BE_CREATED = 'Before Update to CW only one Cases to be created';
    private static final String MSG_ONLY_ONE_CASE_SHOULD_EXIST = 'Only one case should exist.';
    private static final String MSG_EXPECTING_TWO_CASES_TO_BE_CREATED = 'Expecting two Cases to be created';
    private static final String MSG_EXPECTING_NEW_CASE_TO_BE_CREATED_FOR_CW = 'Expecting new Case to be created for CW';
    private static final String MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW = 'Before Update to CW expecting one Case to be created for CW';
    private static final String MSG_START_DATES_FOR_CASE_SHOULD_MATCH = 'Start Dates for Case Should Match';
    private static final String MSG_EXPECTING_CASE_TO_BE_CLOSED_CANCELLED = 'Expecting Case to be Closed - Cancelled';
	private static final String THE_CASE_STATUS_SHOULD_BE_ON_HOLD = 'Expecting Case Status On Hold when contact is deactive';


    
        @TestSetup
        static void createFoundationData(){
            TF2_Business_Site__c Site = new TF2_Business_Site__c();
            Site.Street_Address__c ='50 Fremont';
            Site.City__c ='San Francisco';
            Site.Country__c ='California';
            Site.Postal_Code__c ='95051';
            Site.State_Province__c ='CA';
            Site.Active__c = true;
            Site.Business_Site_Id__c = 'Salesforce West - San Francisco';
            Site.Type__c = 'Office';
            insert Site;

            TF2_Department__c dept = new TF2_Department__c();
            dept.Department_Number__c ='2301';
            dept.Name = DEPARTMENT_NAME;
            dept.Active__c = true;
            insert dept;

            Business_Unit__c BU = new Business_Unit__c();
            BU.Active__c = true;
            BU.Name =  BU_NAME;
            bu.BU_Code__c = '1001';
            insert BU;

            TF2_Company__c comp = new TF2_Company__c();
            comp.Company_Code__c = '1002';
            comp.Active__c = true;
            comp.name = '100 - Salesforce All2';
            insert comp;

            Contact con = new Contact();
            con.FirstName = 'Manager';
            con.LastName ='TestData';
            con.email= 'managerTest@example.com';
            con.EmployeeNumber__c ='12345';
            con.recordTypeId = NHW_Util.getEmployeeContactRecordTypeId();
            insert con;
            
             Onboarding_Setting__c settings = new Onboarding_Setting__c(); 

            settings.SSOR_Feature_Flag__c = true;
            settings.Contractor_pre_boarding_window__c = 30;
            settings.Contractor_before_start_window__c = 30;
            insert settings; 
            
            

            
        }
        public static List<Contact> bulkPopulateContact (String WOStatus,Date StartDate,Integer numberOfRecords){
            Id businessSite = [SELECT id from TF2_Business_Site__c limit 1].Id;
            Id manager = [SELECT id from Contact where FirstName = 'Manager' limit 1].Id;
            Id businessUnit = [SELECT id from Business_Unit__c limit 1].id;
            Id DepartmentId = [SELECT id FROM TF2_Department__c limit 1].Id;
            Id companyId = [SELECT id FROM TF2_Company__c limit 1].Id;
            Id recordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contractor').getRecordTypeId();

            List<Contact> bulkCWContacts= new List<Contact>();
            for(Integer i = 0; i < numberOfRecords; i++){
                Contact CWCon = new Contact();

                CWCon.FirstName = 'Test Contact';
                CWCon.LastName = 'data'+numberOfRecords;


                CWCon.CW_Work_Order_Status__c = WOStatus;
                CWCon.Email = 'testOffice'+numberOfRecords+ EMAIL_DOMAIN;
                CWCon.Secondary_Email__c = 'testPersonal'+numberOfRecords+ EMAIL_DOMAIN;
                CWCon.CW_Hire_Reason__c = 'Standard';
                CWCon.CW_Type__c = 'SOW';
                CWCon.RecordTypeId = recordTypeId;
                CWCon.Start_Date__c = StartDate;
                CWCon.Term_Date__c = StartDate +90;

                CWCon.Resource_Type__c = 'CW';
                CWCon.Title = 'Standard';
                CWCon.EmployeeNumber__c = '789'+ String.valueOf(math.random()).left(6);
                CWCon.CW_Reason_for_Request__c = 'TBD';
                CWCon.MailingStreet =  MAILING_STREET;
                CWCon.MailingCity = 'Fremont';
                CWCon.MailingCountry = 'California';
                CWCon.MailingPostalCode = '95051';
                CWCon.MailingState = 'CA';

                CWCon.Division__c =  DIVISION;
                CWCon.CW_Business_Site_Name__c =  CW_BS_NAME;
                CWCon.Business_Site__c = businessSite;
                CWCon.ReportsToId = manager;

                CWCon.WD_Business_Unit__c = businessUnit;
                CWCon.ES_DJC_Business_Unit__c=  BU_NAME;

                CWCon.WD_Department__c = DepartmentId;
                CWCon.ES_DJC_Cost_Center__c=  DEPARTMENT_NAME;

                CWCon.CW_Company__c = companyId;
                CWCon.Primary_Country_of_Coverage_PCC__c =  PCC;
                bulkCWContacts.add(CWCon);               
            }

            return bulkCWContacts;
        }
        
        public static contact populateContact(String WOStatus,Date StartDate ){

            //Insert BS and COA object recs.
          //  createFoundationData()

            Contact CWCon = new Contact();

            CWCon.FirstName = 'Test Contact';
            CWCon.LastName = 'data'+String.valueOf(math.random()).left(6);
            

            CWCon.CW_Work_Order_Status__c = WOStatus;
            CWCon.Email = 'testOffice'+String.valueOf(math.random()).left(3)+ EMAIL_DOMAIN;
            CWCon.Secondary_Email__c = 'testPersonal'+String.valueOf(math.random()).left(3)+ EMAIL_DOMAIN;
            CWCon.CW_Hire_Reason__c = 'Standard';
            CWCon.CW_Type__c = 'SOW';
            CWCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contractor').getRecordTypeId();

            CWCon.Start_Date__c = StartDate;
            CWCon.Term_Date__c = StartDate +90;

            CWCon.Resource_Type__c = 'CW';
            CWCon.Title = 'Standard';
            CWCon.EmployeeNumber__c = '789'+ String.valueOf(math.random()).left(6);
            CWCon.CW_Reason_for_Request__c = 'TBD';
            CWCon.MailingStreet =  MAILING_STREET;
            CWCon.MailingCity = 'Fremont';
            CWCon.MailingCountry = 'California';
            CWCon.MailingPostalCode = '95051';
            CWCon.MailingState = 'CA';

            CWCon.Division__c =  DIVISION;
            CWCon.CW_Business_Site_Name__c =  CW_BS_NAME;
            CWCon.Business_Site__c = [SELECT id from TF2_Business_Site__c limit 1].Id;
            CWCon.ReportsToId = [SELECT id from Contact where FirstName = 'Manager' limit 1].Id;

            CWCon.WD_Business_Unit__c = [SELECT id from Business_Unit__c limit 1].id;
            CWCon.ES_DJC_Business_Unit__c=  BU_NAME;

            CWCon.WD_Department__c = [SELECT id FROM TF2_Department__c limit 1].Id;
            CWCon.ES_DJC_Cost_Center__c=  DEPARTMENT_NAME;

            CWCon.CW_Company__c = [SELECT id FROM TF2_Company__c limit 1].Id;
            CWCon.Primary_Country_of_Coverage_PCC__c =  PCC;

            


            return CWCon;
        }
    /*
    Overloaded Method to pass Contact into for data updates.
     */
    public static contact populateContact(String WOStatus,Date StartDate, Contact CWCon ) {



        CWCon.CW_Work_Order_Status__c = WOStatus;
        CWCon.Secondary_Email__c = 'testPersonal' + String.valueOf(math.random()).left(3) +  EMAIL_DOMAIN;
        CWCon.CW_Hire_Reason__c = 'Standard';
        CWCon.CW_Type__c = 'SOW';
        CWCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contractor').getRecordTypeId();

        CWCon.Start_Date__c = StartDate;
        CWCon.Term_Date__c = StartDate + 90;

        CWCon.Resource_Type__c = 'CW';
        CWCon.Title = 'Standard';
        CWCon.CW_Reason_for_Request__c = 'TBD';
        CWCon.MailingStreet =  MAILING_STREET;
        CWCon.MailingCity = 'Fremont';
        CWCon.MailingCountry = 'California';
        CWCon.MailingPostalCode = '95051';
        CWCon.MailingState = 'CA';

        CWCon.Division__c =  DIVISION;
        CWCon.CW_Business_Site_Name__c =  CW_BS_NAME;
        CWCon.Business_Site__c = [SELECT id from TF2_Business_Site__c limit 1].Id;
        CWCon.ReportsToId = [SELECT id from Contact where FirstName = 'Manager' limit 1].Id;

        CWCon.WD_Business_Unit__c = [SELECT id from Business_Unit__c limit 1].id;
        CWCon.ES_DJC_Business_Unit__c =  BU_NAME;

        CWCon.WD_Department__c = [SELECT id FROM TF2_Department__c limit 1].Id;
        CWCon.ES_DJC_Cost_Center__c =  DEPARTMENT_NAME;

        CWCon.CW_Company__c = [SELECT id FROM TF2_Company__c limit 1].Id;
        CWCon.Primary_Country_of_Coverage_PCC__c =  PCC;

        return CWCon;
    }

    public static Case populateExistingCase(Contact contractor, Case provisioningCase){
        Id caseRecordTypeId = NHW_Util.getnhwCaseRecordTypeId();

        List<NH_DataMapping__mdt> dataMappings = NHW_Util.getSourceFieldsFromNHDataMappingMDT('Contact', 'Case', 'CW Contact to Case');

        provisioningCase.Subject = 'New Hire Provisioning Request for ' + contractor.FirstName + ' ' + contractor.LastName;
        provisioningCase.RecordTypeId = caseRecordTypeId;
        provisioningCase.NHW_Employee_Type__c = 'contractor';
        provisioningCase.NHW_Page_Number__c = 0;
        provisioningCase.Origin = 'NHW';
        provisioningCase.Type = 'NHW';
        provisioningCase.Status = 'Closed';
        provisioningCase.ContactId = contractor.ReportsToId;
        provisioningCase.Description = '';
        provisioningCase.NHW_Employee__c = contractor.Id;
        provisioningCase.Job_Status__c = '';

        NHW_Util.updateValuesusingNHDataMappingMDT(contractor, provisioningCase, dataMappings);

        return provisioningCase;
    }

    public static List<Case> bulkpopulateOldCase(List<Contact> contractors){
        Id caseRecordTypeId = NHW_Util.getnhwCaseRecordTypeId();

        List<NH_DataMapping__mdt> dataMappings = NHW_Util.getSourceFieldsFromNHDataMappingMDT('Contact', 'Case', 'CW Contact to Case');

        List<Case> pastCases = new List<Case>();

        for(Contact contractor: contractors) {
            Case provisioningCase = new Case();

            provisioningCase.Subject = 'New Hire Provisioning Request for ' + contractor.FirstName + ' ' + contractor.LastName;
            provisioningCase.RecordTypeId = caseRecordTypeId;
            provisioningCase.NHW_Employee_Type__c = 'contractor';
            provisioningCase.NHW_Page_Number__c = 0;
            provisioningCase.Origin = 'NHW';
            provisioningCase.Type = 'NHW';
            provisioningCase.Status = 'Closed';
            provisioningCase.ContactId = contractor.ReportsToId;
            provisioningCase.Description = '';
            provisioningCase.NHW_Employee__c = contractor.Id;
            provisioningCase.Job_Status__c = '';

            NHW_Util.updateValuesusingNHDataMappingMDT(contractor, provisioningCase, dataMappings);
            pastCases.add(provisioningCase);
        }

        return pastCases;
    }

/** -----------------------  GENERAL CREATION OF NEW HIRE UNIT TESTS ----------------------- **/

    /**
     * Given: A Contractor Contact with CW Type (SOW) to WO Status mapping (Accepted)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void bulk_CreatedInOnboardingWindow(){
        //Create Contact.
        Integer numberOfRecords = 200;
        Date TenDaysInFuture = system.today()+ 10;
        List<Contact> CWContacts = bulkPopulateContact('Accepted',TenDaysInFuture,numberOfRecords);
        Test.startTest();
            INSERT CWContacts;
        Test.stopTest();//Async threads will end.

        List<Contact> cons = [ select Id, Status__c from Contact where Id IN:CWContacts];
        System.assertEquals(numberOfRecords,cons.size(),'Expecting all contacts defined in numberOfRecords to be created');
        Set<Id> contactIds = new Set<Id>();
        for(Contact c: cons){
            contactIds.add(c.Id);
        }
        List<Case> casesCreated = [SELECT Id FROM Case WHERE NHW_Employee__c IN: contactIds];

        System.AssertEquals(numberOfRecords,casesCreated.size(),'Expecting One Case to be created for Each Contact Created');

    }

    /**
     * Given: A Contractor Contact with CW Type (SOW) to WO Status mapping (Accepted)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void bulk_updatedInOnboardingWindow(){
        Integer numberOfRecords = 100;
        Date yearAgo = system.today()- 365;
        List<Contact> CWContacts = bulkPopulateContact('Closed',yearAgo,numberOfRecords);
        INSERT CWContacts;

        List<Case> pastCases = bulkpopulateOldCase(CWContacts);
        INSERT pastCases;

        Test.startTest();
        for(Contact cw: CWContacts){
            cw.Start_Date__c = System.today() + 10;
            cw.Term_Date__c = System.today() +365;
            cw.CW_Work_Order_Status__c = 'Accepted';
            cw.Previous_SF_Worker__c = true;
        }
        UPDATE CWContacts;

        Test.stopTest();//Async threads will end.

        List<Contact> cons = [ select Id, Status__c from Contact where Id IN:CWContacts];
        System.assertEquals(numberOfRecords,cons.size(),'Expecting all contacts defined in numberOfRecords to be created');
        Set<Id> contactIds = new Set<Id>();
        for(Contact c: cons){
            contactIds.add(c.Id);
        }
        List<Case> casesCreated = [SELECT Id FROM Case WHERE NHW_Employee__c IN: contactIds];

        System.AssertEquals(numberOfRecords*2,casesCreated.size(),'Expecting One Case to be created for Each Contact Created');
    }



    /**
     * Given: A Contractor Contact with CW Type (SOW) to WO Status mapping (Accepted)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void new_SOW_Accepted_CreatedInOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        Test.startTest();
            INSERT CWContact;
            Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
            System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
            System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact with CW Type (SOW) to WO Status mapping (Accepted)
     * When: is created in the with backdate start date
     * Then: a case should be created.
     */
    static testmethod void new_SOW_Accepted_backdatedStartDate(){
        //Create Contact.
        Date TenDaysInPast = system.today()- 10;
        Contact CWContact = populateContact('Accepted',TenDaysInPast);
        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact with CW Type (SOW) to WO Status mapping (Confirmed)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void new_SOW_Confirmed_CreatedInOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Confirmed',TenDaysInFuture);
        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact with CW Type (SOW) to WO Status mapping (Activated)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void new_SOW_Activated_CreatedInOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Activated',TenDaysInFuture);
        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact with CW Type (CW) to WO Status mapping (Accepted)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void new_CW_Accepted_CreatedinOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.CW_Type__c= 'CW';

        Test.startTest();
            INSERT CWContact;
            Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
            System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
            System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact with CW Type (CW) to WO Status mapping (Confirmed)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void new_CW_Confirmed_CreatedinOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Confirmed',TenDaysInFuture);
        CWContact.CW_Type__c= 'CW';

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact with a valid CW Type (CW) to WO Status mapping (Activated)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void new_CW_Activated_CreatedinOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Activated',TenDaysInFuture);
        CWContact.CW_Type__c= 'CW';

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact with a valid WO Type (PW) to WO Status mapping (Created)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void new_PW_CreatedStatus_InOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Created',TenDaysInFuture);
        CWContact.CW_Type__c= 'PW';

        Test.startTest();
            INSERT CWContact;
            Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
            System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
            System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contactor Contact is in start window with Accurate WO to CW Type Mapping and is Badge-Only
     * When: Hire Reason is updated to Standard
     * Then: a case should be created.
     */
    static testmethod void update_CW_fromBadgeOnlytoStandard_InWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.CW_Hire_Reason__c=  CW_HIRE_REASON;
        NHW_ContactHandler.isexecuted = false;
        INSERT CWContact;

        Test.startTest();
        Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
        System.AssertEquals(0,updateCont.EmlpoyeeCases__r.size(),'No case should exist before insert' );

        updateCont.CW_Hire_Reason__c = 'Standard';
        NHW_ContactHandler.isexecuted = false;
        UPDATE updateCont;
        Test.stopTest();//Async threads will end.

        Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r ) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),'Expecting case to be created.');
    }

    /**
     * Given: A Contactor Contact is in start window with Accurate WO to CW Type Mapping and is Badge-Only
     * When: Hire Reason is updated to Standard
     * Then: a case should be created.
     */
    static testmethod void update_CW_StartDatefromPasttoInsideOnboardingWindow(){
        //Create Contact.
        Date startDate = system.today()- 10;
        Contact CWContact = populateContact('Accepted',startDate);
        INSERT CWContact;

        Test.startTest();
        Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
        System.AssertEquals(0,updateCont.EmlpoyeeCases__r.size(),'No case should exist before insert' );

        updateCont.Start_Date__c = system.today() + 14;
        NHW_ContactHandler.isexecuted = false;
        UPDATE updateCont;
        Test.stopTest();//Async threads will end.

        Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r ) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),'Expecting case to be created.');
    }
    
    /**
     * Given: A Contractor Contact with CW Type (CW) to WO Status mapping (Accepted)
     * When: is created in the onboarding window
     * Then: a case should be created.
     */
    static testmethod void new_CaseCreationOnSD(){
        //Create Contact.
        Date TenDaysInFuture = system.today();
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        Test.startTest();
            INSERT CWContact;
            Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
            System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
            System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }


    /** -----------------------  GENERAL NO CASE CREATION UNIT TESTS ----------------------- **/

    /**
     * Given: A Contractor Contact with a Valid WO Type (CW) to WO Status mapping (Activated)
     * When: is created outside the onboarding window
     * Then: a case should not be created.
     */
    static testmethod void new_CW_ActivatedStatus_OUTSIDE_OnboardingWindow(){
        //Create Contact.
        Onboarding_Setting__c settings = Onboarding_Setting__c.getInstance();
        Date StartDate = System.today()+ Integer.valueOf(settings.Contractor_pre_boarding_window__c) + 1;
        Contact CWContact = populateContact('Activated',StartDate);

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,MSG_EXPECTING_NO_CASES_TO_CREATED);

    }

    /**
     * Given: A Contractor Contact with a Valid WO Type (CW) to WO Status mapping (Activated)
     * When: is created with start date in the past
     * Then: a case should not be created.
     */
    static testmethod void new_StartDateinPast_OutsideWindow(){
        //Create Contact.
        Date pastDate = system.today() - 31;
        Contact CWContact = populateContact('Activated',pastDate);

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,'Expecting one cases to created');

    }

    /**
     * Given: A Contractor Contact with a Valid WO Type (SOW) to WO Status mapping (Activated)
     * When: is created outside the onboarding window
     * Then: a case should not be created.
     */
    static testmethod void new_SOW_ActivatedStatus_OUTSIDE_OnboardingWindow(){
        //Create Contact.
        Onboarding_Setting__c settings = Onboarding_Setting__c.getInstance();
        Date StartDate = System.today()+ Integer.valueOf(settings.Contractor_pre_boarding_window__c) + 1;
        Contact CWContact = populateContact('Activated',StartDate);
        CWContact.CW_Type__c = 'SOW';

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,MSG_EXPECTING_NO_CASES_TO_CREATED);

    }

    /**
     * Given: A Contractor Contact with a Valid WO Type (PW) to WO Status mapping (Created)
     * When: is created outside the onboarding window
     * Then: a case should not be created.
     */
    static testmethod void new_PW_CreatedStatus_OUTSIDE_OnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 21;
        Contact CWContact = populateContact('Created',TenDaysInFuture);

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,MSG_EXPECTING_NO_CASES_TO_CREATED);

    }

    /**
     * Given: A Contractor Contact with a invalid WO Type (PW) to WO Status mapping (Activated)
     * When: is created in the onboarding window
     * Then: a case will be created.
     */
    static testmethod void new_PW_NonCreatedStatus_InOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Activated',TenDaysInFuture);
        CWContact.CW_Type__c= 'PW';

        Test.startTest();
            INSERT CWContact;
            Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
            System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
            System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_NO_CASES_TO_CREATED);

    }

    /**
     * Given: A Contractor Contact with an invalid WO Type (CW) to WO Status mapping (Created)
     * When: is created in the onboarding window
     * Then: a case should not be created.
     */
    static testmethod void new_CW_NonValidSatus_InOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Created',TenDaysInFuture);
        CWContact.CW_Type__c= 'CW';

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,MSG_EXPECTING_NO_CASES_TO_CREATED);

    }

    /**
     *
     * Given: A Contractor Contact with an invalid WO Type (SOW) to WO Status mapping (Created)
     * When: is created in the onboarding window
     * Then: a case should not be created.
     */
    static testmethod void new_SOW_NonValidStatus_InOnboardingWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Created',TenDaysInFuture);

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.
        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,MSG_EXPECTING_NO_CASES_TO_CREATED);

    }

    /**
     * Given: A Contractor Contact is created with WO Status = Created and Type = PW
     * When: is created with Hire Reason = Badge Only
     * Then: a case should not be created
     */
    static testmethod void new_PW_CreatedStatus_BadgeOnly_InOnboarindWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Created',TenDaysInFuture);
        CWContact.CW_Hire_Reason__c =  CW_HIRE_REASON;
        CWContact.CW_Type__c = 'PW';

        Test.startTest();
            INSERT CWContact;
            Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
            System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
            System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,MSG_EXPECTING_NO_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact is created with WO Status = Accepted and Type = SOW
     * When: is created with Hire Reason = Badge Only
     * Then: a case should not be created
     */
    static testmethod void new_SOW_CreatedStatus_BadgeOnly_InOnboarindWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.CW_Hire_Reason__c =  CW_HIRE_REASON;
        CWContact.CW_Type__c = 'SOW';

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.
        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,MSG_EXPECTING_NO_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact is created with WO Status = Accepted and Type = CW
     * When: is created with Hire Reason = Badge Only
     * Then: a case should not be created
     */
    static testmethod void new_CW_CreatedStatus_BadgeOnly_InOnboarindWindow(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.CW_Hire_Reason__c =  CW_HIRE_REASON;
        CWContact.CW_Type__c = 'CW';

        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.
        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),0,MSG_EXPECTING_NO_CASE_TO_BE_CREATED);

    }

    /**
     * Given: A Contractor Contact with WO Status and CW Type in the Onboarding Preboarding Window
     * When: is created without one of the Business Unit Lookup
     * Then: a provisioning case should not be created.
     */
   /* static testmethod void new_CW_null_BusinessUnit(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.WD_Business_Unit__c = null;
        System.Debug(CWContact);
        Test.startTest();
            INSERT CWContact;
            Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
            System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
            System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.
            con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(0,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_NO_CASE_TO_BE_CREATED_AS_LOOKUPS_ARE_EMPTY);
        List<PF_Debug_Log__c> logs = [select name ,description__c from PF_Debug_Log__c ];
        System.AssertNotEquals(0,logs.size(),MSG_EXPECTING_ERROR_LOGS);
    } */

    /**
     * Given: A Contractor Contact with WO Status and CW Type in the Onboarding Preboarding Window
     * When: is created without one of the ReportsTo Lookup
     * Then: a provisioning case should not be created.
     */
   /* static testmethod void new_CW_null_ReportsTo(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.ReportsToId = null;
        System.Debug(CWContact);
        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.
        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(0,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_NO_CASE_TO_BE_CREATED_AS_LOOKUPS_ARE_EMPTY);
        List<PF_Debug_Log__c> logs = [select name ,description__c from PF_Debug_Log__c ];
        System.AssertNotEquals(0,logs.size(),MSG_EXPECTING_ERROR_LOGS);
    }*/

    /**
     * Given: A Contractor Contact with WO Status and CW Type in the Onboarding Preboarding Window
     * When: is created without one of the Business Unit Lookup
     * Then: a provisioning case should not be created.
     */
    /*static testmethod void new_CW_null_Company(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.CW_Company__c = null;
        System.Debug(CWContact);
        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.
        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(0,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_NO_CASE_TO_BE_CREATED_AS_LOOKUPS_ARE_EMPTY);
        List<PF_Debug_Log__c> logs = [select name ,description__c from PF_Debug_Log__c ];
        System.AssertNotEquals(0,logs.size(),MSG_EXPECTING_ERROR_LOGS);
    }*/

    /**
     * Given: A Contractor Contact with WO Status and CW Type in the Onboarding Preboarding Window
     * When: is created without one of the Cost Center Lookup
     * Then: a provisioning case should not be created.
     */
    /*static testmethod void new_CW_null_CostCenter(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.WD_Department__c = null;
        System.Debug(CWContact);
        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.
        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(0,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_NO_CASE_TO_BE_CREATED_AS_LOOKUPS_ARE_EMPTY);
        List<PF_Debug_Log__c> logs = [select name ,description__c from PF_Debug_Log__c ];
        System.AssertNotEquals(0,logs.size(),MSG_EXPECTING_ERROR_LOGS);
    }*/

    /**
     * Given: A Contractor Contact with WO Status and CW Type in the Onboarding Preboarding Window
     * When: is created without one of the Business Site Lookup
     * Then: a provisioning case should not be created.
     */
    /*static testmethod void new_CW_null_BusinessSite(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        CWContact.Business_Site__c = null;
        System.Debug(CWContact);
        Test.startTest();
        INSERT CWContact;
        Contact con = [ select Id, Status__c from Contact where Id = :CWContact.Id ];
        System.AssertNotEquals(con,null,MSG_EXPECTING_CONTACT_TO_BE_CREATED);
        System.AssertNotEquals(con.Status__c,'Active',MSG_EXPECTING_CONTACT_STATUS_TO_NOT_BE_ACTIVE);
        Test.stopTest();//Async threads will end.
        con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(0,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_NO_CASE_TO_BE_CREATED_AS_LOOKUPS_ARE_EMPTY);
        List<PF_Debug_Log__c> logs = [select name ,description__c from PF_Debug_Log__c ];
        System.AssertNotEquals(0,logs.size(),MSG_EXPECTING_ERROR_LOGS);
    }*/

    /** -----------------------  GENERAL EXISTING CASE UNIT TESTS  ----------------------- **/

    /**
     * Given: A Contactor Contact has an existing provisioning case with WO Status Accepted
     * When: the WO Status is moved to Activated
     * Then: no action should happen, case should stay the same and no additional case should be created
     */
    static testmethod void update_ExistingCase_WOStatusAcceptedToActivated(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        NHW_ContactHandler.isexecuted = false;
        INSERT CWContact;

        Case existingCase = new Case();
        existingCase = populateExistingCase(CWContact, existingCase);
        INSERT existingCase;

        Test.startTest();
        Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
        System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );

        updateCont.CW_Work_Order_Status__c = 'Activated';
        NHW_ContactHandler.isexecuted = false;
        UPDATE updateCont;
        Test.stopTest();//Async threads will end.

        Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r ) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_ONLY_ONE_CASE_SHOULD_EXIST);
    }

    /**
     * Given: A Contactor Contact has an existing provisioning case
     * When: an update to one of the data mapping field is made
     * Then: the change should cascade to the provisioning case.
     */
    static testmethod void update_ExistingCaseDataCascadeToCase(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        INSERT CWContact;

        Case existingCase = new Case();
        existingCase = populateExistingCase(CWContact, existingCase);
        INSERT existingCase;

        Test.startTest();
            Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
            System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );

            updateCont.Resource_Type__c =  RESOURCE_TYPE;
            NHW_ContactHandler.isexecuted = false;
            UPDATE updateCont;
        Test.stopTest();//Async threads will end.

           Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r ) from Contact where Id = :CWContact.Id ];
        System.debug(con);

        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),'Expecting Case to be created' );
        System.AssertEquals(con.Resource_Type__c,con.EmlpoyeeCases__r[0].Resource_Type__c,MSG_EXPECTING_UPDATES_TO_CASCADE_TO_CASE);
    }

    /**
     * Given: A Contactor Contact has an existing provisioning case
     * When: the start date on the contactor is updated inside of the onboarding window
     * Then: the new start date should show up on the child case.
     */
    static testmethod void update_StartDateChangeInOnboardingWindowCascade(){

        Date TenDaysInFuture = system.today()+ 2;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        INSERT CWContact;

        Test.startTest();
            Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];

            updateCont.Start_Date__c = system.today()+10;
            NHW_ContactHandler.isexecuted = false;

            UPDATE updateCont;
        Test.stopTest();//Async threads will end.

        Contact con = [ select Id, Status__c,Start_Date__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_ONLY_ONE_CASE_TO_BE_CREATED );
        System.AssertEquals(con.Start_Date__c,con.EmlpoyeeCases__r[0].NHW_Start_Date__c,'Expecting SD updates to cascade to Case');

    }

    /**
     * Given: A Contractor Contact has an existing provisioning cases and Start Date was yesterday
     * When: the Start Date is updated to a date in the future less than 30 days
     * Then: The Start Date on the case should be update to the future date set on the contact.
     */
        static testmethod void existing_SD_Yesterday_UpdateSDtoFuturelessThan30(){

            Date today = system.today();
            Contact CWContact = populateContact('Accepted',today -1);
            NHW_ContactHandler.isexecuted = true;
            INSERT CWContact;

            Case existingCase = new Case();
            existingCase = populateExistingCase(CWContact, existingCase);
            INSERT existingCase;
            
            Test.startTest();
            Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
            System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );
            Date newStartDate = System.today() + 28;
            CWContact.Start_Date__c = newStartDate;
            NHW_ContactHandler.isexecuted = false;
            UPDATE CWContact;
            Test.stopTest();//Async threads will end.

            Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_ONLY_ONE_CASE_TO_BE_CREATED );
            System.AssertEquals(newStartDate,con.EmlpoyeeCases__r[0].NHW_Start_Date__c,'Expecting SD updates to cascade to Case');


        }

    /**
     * Given: A existing CW with Accepted WO Status has a start date 2 days ago with existing provisioning case
     * When: the Start Date is updated to a date in the future less than 30 days
     * Then: the new start date should cascade to the case and only one case should exist.
     */
    static testmethod void existing_StartDateChangeLessThan30withOpenCase() {
        Date today = system.today();
        Contact CWContact = populateContact('Accepted', today);
        CWContact.Start_Date__c = today - 2;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted = true;
        INSERT CWContact;

        Case existingCase = new Case();
        populateExistingCase(CWContact, existingCase);
        INSERT existingCase;

        Date newStartDate = System.today() + 5;
        Test.startTest();
        Contact con = [select Id, Status__c, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id];
        System.AssertEquals(1, con.EmlpoyeeCases__r.size(), MSG_BEFORE_UPDATE_TO_CW_ONLY_ONE_CASE_TO_BE_CREATED);

        CWContact.Start_Date__c = newStartDate;
        NHW_ContactHandler.isexecuted = false;

        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [select Id, Status__c, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id];

        System.AssertEquals(1, con.EmlpoyeeCases__r.size(), MSG_ONLY_ONE_CASE_SHOULD_EXIST);
        System.assertEquals(newStartDate,con.EmlpoyeeCases__r[0].NHW_Start_Date__c, 'Start Date on Case should match the new contact Start Date');
    }

    /**
     * Given: A existing CW with Accepted WO Status has a start date 2 days ago with existing provisioning case
     * When: the Start Date is updated to a date in the future greater than 30 days
     * Then: the new start date should NOT cascade to the case and no new case should be created
     */
    static testmethod void existing_StartDateChangeGreaterThan30() {
        Date today = system.today();
        Contact CWContact = populateContact('Accepted', today);
        CWContact.Start_Date__c = today - 2;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted=true;
        INSERT CWContact;

        Case existingCase = new Case();
        populateExistingCase(CWContact, existingCase);
        INSERT existingCase;

        Date newStartDate = System.today() + 30;
        Test.startTest();
        Contact con = [select Id, Status__c, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id];
        System.AssertEquals(1, con.EmlpoyeeCases__r.size(), MSG_BEFORE_UPDATE_TO_CW_ONLY_ONE_CASE_TO_BE_CREATED);

        CWContact.Start_Date__c = newStartDate;
        NHW_ContactHandler.isexecuted = false;

        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [select Id, Status__c, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id];

        System.AssertEquals(1, con.EmlpoyeeCases__r.size(), MSG_ONLY_ONE_CASE_SHOULD_EXIST);
        System.assertNotEquals(newStartDate,con.EmlpoyeeCases__r[0].NHW_Start_Date__c, 'Start Date on Case should not match the new contact Start Date');
    }


    /**
     * Given: A existing CW with Accepted WO Status has a start date 2 days ago with existing CLOSED provisioning case
     * When: the Start Date is updated to a date in the future less than 30 days
     * Then: the new start date should cascade to the case and only one case should exist.
     */
    static testmethod void existing_StartDateChangeLessThan30withClosedCase() {
        Date today = system.today();
        Contact CWContact = populateContact('Accepted', today);
        CWContact.Start_Date__c = today - 2;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted = true;
        INSERT CWContact;

        Case existingCase = new Case();
        populateExistingCase(CWContact, existingCase);
        existingCase.Status = 'Closed';
        INSERT existingCase;

        Date newStartDate = System.today() + 5;
        Test.startTest();
        Contact con = [select Id, Status__c, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id];
        System.AssertEquals(1, con.EmlpoyeeCases__r.size(), MSG_BEFORE_UPDATE_TO_CW_ONLY_ONE_CASE_TO_BE_CREATED);

        CWContact.Start_Date__c = newStartDate;
        NHW_ContactHandler.isexecuted = false;

        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [select Id, Status__c, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id];

        System.AssertEquals(1, con.EmlpoyeeCases__r.size(), MSG_ONLY_ONE_CASE_SHOULD_EXIST);
        System.assertEquals(newStartDate,con.EmlpoyeeCases__r[0].NHW_Start_Date__c, 'Start Date on Case should match the new contact Start Date');
    }
    
    /**
     * Given: A Contactor Contact has an existing provisioning case with WO Status Closed
     * When: EI updates  Resouce Type ,Start Date on contact Contact is updated
     * Then: SD and NON SD changes should cascade to case
     */
    static testmethod void update_ExistingCase_WOStatusClosed(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
        NHW_ContactHandler.isexecuted = false;
        INSERT CWContact;

        Case existingCase = new Case();
        existingCase = populateExistingCase(CWContact, existingCase);
        INSERT existingCase;

        Test.startTest();
        Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
        System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );

        updateCont.Resource_Type__c =  RESOURCE_TYPE;
        updateCont.start_date__c = system.today() + 15;
        NHW_ContactHandler.isexecuted = false;
        UPDATE updateCont;
        Test.stopTest();//Async threads will end.

        Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r ) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(RESOURCE_TYPE, con.EmlpoyeeCases__r[0].Resource_Type__c,'Expecting NON SD changes flows to contact');
        System.AssertEquals(system.today() + 15, con.EmlpoyeeCases__r[0].NHW_Start_Date__c,'Expecting SD changes flows to contact');
    }
    
    /**
     * Given: A Contactor Contact has an existing provisioning case with WO Status Created
     * When: EI updates  WO Status to Accepted on contact
     * Then: Additional Provisioning cases should not be created.
     */
    static testmethod void update_ExistingCase_WOStatusCreatedToAccepted(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Created',TenDaysInFuture);
        INSERT CWContact;

        Case existingCase = new Case();
        existingCase = populateExistingCase(CWContact, existingCase);
        INSERT existingCase;

        Test.startTest();
            Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
            System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );

            updateCont.CW_Work_Order_Status__c = 'Accepted';
            NHW_ContactHandler.isexecuted = false;
            UPDATE updateCont;
        Test.stopTest();//Async threads will end.

           Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r ) from Contact where Id = :CWContact.Id ];
        System.debug(con);

        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),'Expecting no new Cases to be created' );
    }
    
    /**
     * Given: A Contactor Contact has SD less than 14 days from today, WO is Accepted and Hire reason is Standard
     * When: EI updates  Hire Reason to Badge only on contact
     * Then: Provisioning cases should not be created.
     */
    static testmethod void update_ExistingCase_HireReasonStandardToBadgeOnly(){
        //Create Contact.
        Date TenDaysInPast = system.today() - 14;
        Contact CWContact = populateContact('Created',TenDaysInPast);
        INSERT CWContact;

        Test.startTest();
            Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
            System.AssertEquals(0,updateCont.EmlpoyeeCases__r.size(),'Before Update no Case should exist' );

            updateCont.CW_Hire_Reason__c =  CW_HIRE_REASON;
            NHW_ContactHandler.isexecuted = false;
            UPDATE updateCont;
        Test.stopTest();//Async threads will end.

           Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r ) from Contact where Id = :CWContact.Id ];
        System.debug(con);

        System.AssertEquals(0,con.EmlpoyeeCases__r.size(),'Expecting no new Cases to be created' );
    }

    /** -----------------------  GENERAL REHIRE CASE UNIT TESTS  ----------------------- **/

    /**
     * Given: There is existing CW whose term date was 10 days ago
     * When: rehire flag is checked with the Start Date in onboarding period and valid WO status mapping
     * Then: New case should be created
     */
    static testmethod void rehire_withGap(){

        Date today = system.today();
        Contact CWContact = populateContact('Accepted',today);
        CWContact.Start_Date__c = today - 365;
        CWContact.Term_Date__c = today - 10;
        CWContact.CW_Work_Order_Status__c = 'Closed';
        INSERT CWContact;

        Case pastCase = new Case();
        populateExistingCase(CWContact,pastCase);
        INSERT pastCase;

        Test.startTest();
        Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_ONLY_ONE_CASE_TO_BE_CREATED );



        //Set Rehire Flag and start date in the future.
        CWContact.CW_Work_Order_Status__c = 'Accepted';
        CWContact.Previous_SF_Worker__c = true;
        CWContact.Start_Date__c = today + 10;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted = false;

        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(2,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_TWO_CASES_TO_BE_CREATED );
    }

    /**
     * Given: There is existing CW whose term date was 10 days ago
     * When: rehire flag is checked with the Start Date in onboarding period and valid WO status mapping
     * Then: New case should be created
     */
    static testmethod void rehire_withGapConfirmedStatus(){

        Date today = system.today();
        Contact CWContact = populateContact('Accepted',today);
        CWContact.Start_Date__c = today - 365;
        CWContact.Term_Date__c = today - 10;
        CWContact.CW_Work_Order_Status__c = 'Closed';
        INSERT CWContact;

        Case pastCase = new Case();
        populateExistingCase(CWContact,pastCase);
        INSERT pastCase;

        Test.startTest();
        Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_ONLY_ONE_CASE_TO_BE_CREATED );



        //Set Rehire Flag and start date in the future.
        CWContact.CW_Work_Order_Status__c = 'Confirmed';
        CWContact.Previous_SF_Worker__c = true;
        CWContact.Start_Date__c = today + 10;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted = false;

        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(2,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_TWO_CASES_TO_BE_CREATED );
    }

    /**
     * Given: There is existing CW whose term date was 10 days ago
     * When: rehire flag is not checked with the Start Date in onboarding period and valid WO status mapping
     * Then: New case should be created
     */
    static testmethod void rehire_withOutRehireFlagChecked(){

        Date today = system.today();
        Contact CWContact = populateContact('Accepted',today);
        CWContact.Start_Date__c = today - 365;
        CWContact.Term_Date__c = today - 10;
        CWContact.CW_Work_Order_Status__c = 'Closed';
        INSERT CWContact;

        Case pastCase = new Case();
        populateExistingCase(CWContact,pastCase);
        INSERT pastCase;

        Test.startTest();
        Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_ONLY_ONE_CASE_TO_BE_CREATED );



        //Update WO Status and move start date to future.
        CWContact.CW_Work_Order_Status__c = 'Accepted';
        CWContact.Previous_SF_Worker__c = false;
        CWContact.Start_Date__c = today + 10;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted = false;

        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(2,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_TWO_CASES_TO_BE_CREATED );
    }

    /**
     * Given: There is existing CW whose term date was today
     * When: rehire flag is checked without the Start Date is being updated without gap and Hire reason is not changing
     * Then: no new cases should be created
     */
    static testmethod void extension_anotherAssignment(){

        Date today = system.today();
        Contact CWContact = populateContact('Accepted',today);
        CWContact.Start_Date__c = today - 365;
        CWContact.Term_Date__c = today;
        NHW_ContactHandler.isexecuted=true;
        INSERT CWContact;
        Case pastCase = new Case();
        populateExistingCase(CWContact,pastCase);

        INSERT pastCase;

        Test.startTest();
        Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );

        //Set Rehire Flag and start date in the future.

        CWContact.Term_Date__c = today +365;
        CWContact.CW_Business_Site_Name__c = 'New Business Site';

        NHW_ContactHandler.isexecuted = false;
        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,Term_Date__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c, End_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),'Expecting no new Cases to be created for CW' );
        System.assertNotEquals(con.Term_Date__c,con.EmlpoyeeCases__r[0].End_Date__c,'Term Date change should not have cascaded to case');
    }

    /**
     * Given: There is existing CW whose term date was today
     * When: rehire flag is checked without the Start Date is being updated without gap and Hire reason is not changing
     * Then: no new cases should be created
     */
        static testmethod void standardRehire_withoutGap(){
            
            Date today = system.today();
            Contact CWContact = populateContact('Accepted',today);
            CWContact.Start_Date__c = today - 365;
            CWContact.Term_Date__c = today;
            CWContact.CW_Work_Order_Status__c = 'Closed';
            NHW_ContactHandler.isexecuted=true;
            INSERT CWContact;
            Case pastCase = new Case();
            populateExistingCase(CWContact,pastCase);
            
            INSERT pastCase;
            
            Test.startTest();
            Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );

            //Set Rehire Flag and start date in the future.
            
            CWContact.Previous_SF_Worker__c = true;
            CWContact.CW_Work_Order_Status__c = 'Activated';
            CWContact.Start_Date__c= today + 1;
            CWContact.Term_Date__c = today +365;
            NHW_ContactHandler.isexecuted = false;
            UPDATE CWContact;
            
            Test.stopTest();//Async threads will end.
            
            con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            
            System.AssertEquals(2,con.EmlpoyeeCases__r.size(),'Expecting a new case to be created, since the Rehire Flag was checked.' );
        }

    /**
     * Given: There is existing CW who was a No Show
     * When: rehire flag is checked without the Start Date is being updated
     * Then: no new cases should be created
     */
    static testmethod void rehire_PreviousNoShowRehire(){

        Date today = system.today();
        Contact CWContact = populateContact('Closed',today);
        CWContact.Start_Date__c = today - 30;
        CWContact.Term_Date__c = today - 30;
        NHW_ContactHandler.isexecuted=true;
        INSERT CWContact;
        Case pastCase = new Case();
        populateExistingCase(CWContact,pastCase);
        pastCase.Status = 'Closed-Cancelled';

        INSERT pastCase;

        Test.startTest();
        Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );

        //Set Rehire Flag and start date in the future.

        CWContact.Previous_SF_Worker__c = true;
        CWContact.CW_Work_Order_Status__c = 'Accepted';
        CWContact.Start_Date__c= today + 5;
        CWContact.Term_Date__c = today +365;
        NHW_ContactHandler.isexecuted = false;
        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(2,con.EmlpoyeeCases__r.size(),'Expecting a new Cases to be created for CW' );
    }
    
    /**
     * Given: There is existing CW whose term date was yesterday
     * When: rehire flag is checked without the Start Date is being updated without gap and Hire reason is changing from badge to standard
     * Then: no new cases should be created
     */
        static testmethod void badgeToStdRehire_withoutGap(){
            
            Date today = system.today();
            Contact CWContact = populateContact('Accepted',today);
            CWContact.Start_Date__c = today - 365;
            CWContact.Term_Date__c = today;
            CWContact.CW_Work_Order_Status__c = 'Confirmed';
            CWContact.CW_Hire_Reason__c =  CW_HIRE_REASON;
            INSERT CWContact;
            Case pastCase = new Case();
            populateExistingCase(CWContact,pastCase);
            
            INSERT pastCase;
            
            Test.startTest();
            Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );

            //Set Rehire Flag and start date in the future.
            
            CWContact.Previous_SF_Worker__c = true;
            CWContact.CW_Work_Order_Status__c = 'Activated';
            CWContact.CW_Hire_Reason__c = 'Standard';
            CWContact.Start_Date__c= today + 1;
            CWContact.Term_Date__c = today +365;
            NHW_ContactHandler.isexecuted = false;
            UPDATE CWContact;
            
            Test.stopTest();//Async threads will end.
            
            con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            
            System.AssertEquals(2,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_NEW_CASE_TO_BE_CREATED_FOR_CW );
        }

    /**
     * Given: There is existing CW whose term date is today
     * When: rehire flag is checked with Start Date is being updated to future
     * Then: new cases should be created
     */
        static testmethod void rehireCWContactSDUpdatesInOnboardingWindow(){
            
            Date today = system.today();
            Contact CWContact = populateContact('Accepted',today);
            CWContact.Start_Date__c = today - 365;
            CWContact.Term_Date__c = today;
            CWContact.CW_Work_Order_Status__c = 'Confirmed';
            INSERT CWContact;
            Case pastCase = new Case();
            populateExistingCase(CWContact,pastCase);
            
            INSERT pastCase;
            
            Test.startTest();
            Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );
            
            
            
            //Set Rehire Flag and start date in the future.
            
            CWContact.Previous_SF_Worker__c = true;
            CWContact.CW_Work_Order_Status__c = 'Accepted';
            CWContact.Start_Date__c = today + 5;
            CWContact.Term_Date__c = today + 365;
            NHW_ContactHandler.isexecuted = false;
            UPDATE CWContact;
            
            Test.stopTest();//Async threads will end.
            
            con = [ select Id, Status__c,(Select id,status,NHW_Start_Date__c from EmlpoyeeCases__r order by NHW_Start_Date__c desc) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(2,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_NEW_CASE_TO_BE_CREATED_FOR_CW );
        }

    /**
     * Given: There is existing CW
     * When: rehire flag is checked with Start Date is being updated to outside onboarding window
     * Then: a new case should not be created.
     */
    static testmethod void rehireCWContactSDUpdatesOUTSIDEOnboardingWindow(){

        Date today = system.today();
        Contact CWContact = populateContact('Confirmed',today - 365);

        INSERT CWContact;
        Case pastCase = new Case();
        populateExistingCase(CWContact,pastCase);

        INSERT pastCase;

        Test.startTest();
        Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );



        //Set Rehire Flag and start date in the future.
        Onboarding_Setting__c settings = Onboarding_Setting__c.getInstance();
        Date StartDate = System.today()+ Integer.valueOf(settings.Contractor_pre_boarding_window__c) + 1;

        CWContact.Previous_SF_Worker__c = true;
        CWContact.CW_Work_Order_Status__c = 'Accepted';
        CWContact.Start_Date__c = StartDate;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted = false;
        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        con = [ select Id, Status__c,(Select id,status,NHW_Start_Date__c from EmlpoyeeCases__r order by NHW_Start_Date__c desc) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),'Expecting only old case since update was outside onboarding window' );
    }

    /**
     * Given: There is existing CW whose term date is today
     * When: rehire flag is checked with Start Date is being updated to future
     * Then: new cases should be created and start date updates should cascade to case
     */
        static testmethod void rehireCWContactSDUpdatesAfterDay1(){
            
            Date today = system.today();
            Contact CWContact = populateContact('Accepted',today);
            CWContact.Start_Date__c = today - 365;
            CWContact.Term_Date__c = today - 1;
            CWContact.CW_Work_Order_Status__c = 'Confirmed';
            INSERT CWContact;
            Case pastCase = new Case();
            populateExistingCase(CWContact,pastCase);
            
            INSERT pastCase;
            
            Test.startTest();
            Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );
            
            
            
            //Set Rehire Flag and start date in the future.
            
            CWContact.Previous_SF_Worker__c = true;
            CWContact.CW_Work_Order_Status__c = 'Accepted';
            CWContact.Start_Date__c = today + 1;
            CWContact.Term_Date__c = today + 365;
            NHW_ContactHandler.isexecuted = false;
            UPDATE CWContact;
            
            
            CWContact.Start_Date__c = today + 10;
            NHW_ContactHandler.isexecuted = false;
            UPDATE CWContact;
            Test.stopTest();//Async threads will end.
            
            con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r order by createdDate desc) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(2,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_NEW_CASE_TO_BE_CREATED_FOR_CW );
        }

    /**
     * Given: There is existing CW whose term date is today
     * When: rehire flag is checked with Start Date is being updated to future
     * Then: new cases should be created and non SD updates e.g. Resource type should cascade to case
     */
        static testmethod void rehireCWContactNonSDUpdatesAfterDay1(){
            
            Date today = system.today();
            Contact CWContact = populateContact('Accepted',today);
            CWContact.Start_Date__c = today - 365;
            CWContact.Term_Date__c = today - 1;
            CWContact.CW_Work_Order_Status__c = 'Confirmed';
            INSERT CWContact;
            Case pastCase = new Case();
            populateExistingCase(CWContact,pastCase);
            
            INSERT pastCase;
            
            Test.startTest();
            Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );
            
            
            
            //Set Rehire Flag and start date in the future.
            
            CWContact.Previous_SF_Worker__c = true;
            CWContact.CW_Work_Order_Status__c = 'Accepted';
            CWContact.Start_Date__c = today + 1;
            CWContact.Term_Date__c = today + 365;
            NHW_ContactHandler.isexecuted = false;
            UPDATE CWContact;
            
            
            CWContact.Resource_Type__c =  RESOURCE_TYPE;
            NHW_ContactHandler.isexecuted = false;
            UPDATE CWContact;
        	Test.stopTest();//Async threads will end.

            Contact conUpdated = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r order by createdDate desc) from Contact where Id = :CWContact.Id ];

            System.AssertEquals(2,conUpdated.EmlpoyeeCases__r.size(),MSG_EXPECTING_NEW_CASE_TO_BE_CREATED_FOR_CW );
            System.AssertEquals(conUpdated.Resource_Type__c,conUpdated.EmlpoyeeCases__r[0].Resource_Type__c,MSG_EXPECTING_UPDATES_TO_CASCADE_TO_CASE);
        }

    /**
     * Given: There is an existing rehired CW with Provisioning Case
     * When: the WO Status is set to Closed
     * Then: the case for tenure related to rehire should be close - cancelled
     */
    /*static testmethod void rehire_NoShowCloseCancel(){

        Date today = system.today();
        Contact CWContact = populateContact('Accepted',today);
        CWContact.Start_Date__c = today - 365;
        CWContact.Term_Date__c = today - 1;
        CWContact.CW_Work_Order_Status__c = 'Closed';
        INSERT CWContact;
        Case pastCase = new Case();
        populateExistingCase(CWContact,pastCase);

        INSERT pastCase;

        Test.startTest();
        Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_TO_CW_EXPECTING_ONE_CASE_TO_BE_CREATED_FOR_CW );



        //Set Rehire Flag and start date in the future.

        CWContact.Previous_SF_Worker__c = true;
        CWContact.CW_Work_Order_Status__c = 'Accepted';
        CWContact.Start_Date__c = today + 1;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted = true;
        UPDATE CWContact;

        Case newCase = new Case();
        populateExistingCase(CWContact,newCase);

        INSERT newCase;


        CWContact.CW_Work_Order_Status__c = 'Closed';
        NHW_ContactHandler.isexecuted = false;
        UPDATE CWContact;
        Test.stopTest();//Async threads will end.

        Contact conUpdated = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r order by createdDate desc) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(2,conUpdated.EmlpoyeeCases__r.size(),MSG_EXPECTING_NEW_CASE_TO_BE_CREATED_FOR_CW );
        System.AssertEquals(CASE_STATUS_CLOSED_CANCELLED,conUpdated.EmlpoyeeCases__r[0].Status,MSG_EXPECTING_UPDATES_TO_CASCADE_TO_CASE);
    }*/

    /**
     * Given: There is an existing CW with Hire Reason Badge Only
     * When: the CW is Rehired with Hire Reason still Badgle Only
     * Then: there should be no cases created for the Contractor
     */
    static testmethod void rehire_BadgeOnlytoBadgeOnly(){

        Date today = system.today();
        Contact CWContact = populateContact('Accepted',today - 365);
        CWContact.CW_Work_Order_Status__c = 'Closed';
        CWContact.CW_Hire_Reason__c =  CW_HIRE_REASON;

        INSERT CWContact;

        Test.startTest();
        Contact con = [ select Id, Status__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
        System.AssertEquals(0,con.EmlpoyeeCases__r.size(),'Before Update No Cases' );



        //Set Rehire Flag and start date in the future.

        CWContact.Previous_SF_Worker__c = true;
        CWContact.CW_Work_Order_Status__c = 'Accepted';
        CWContact.Start_Date__c = today + 1;
        CWContact.Term_Date__c = today + 365;
        NHW_ContactHandler.isexecuted = true;
        UPDATE CWContact;

        Test.stopTest();//Async threads will end.

        Contact conUpdated = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r order by createdDate desc) from Contact where Id = :CWContact.Id ];

        System.AssertEquals(0,conUpdated.EmlpoyeeCases__r.size(),'Expecting no cases'); }

    /** -----------------------  GENERAL RESCIND CASE UNIT TESTS  ----------------------- **/

    /**
     * Given: An Existing CW has an existing Provisioning Case with Start Date of Yesterday
     * When: the Contractor Work Order is Rescinded (Closed)
     * Then: no action because the Start Date is in the past and management of this will be done by SupportForce Team.
     */
        static testmethod void rescind_CWContactAfterDay1(){
            //Create Contact.
            Date startDate = system.today()+ -1;
            Contact CWContact = populateContact('Accepted',startDate);
            NHW_ContactHandler.isexecuted = true;
            INSERT CWContact;

            Case existingCase = new Case();
            existingCase = populateExistingCase(CWContact, existingCase);
            existingCase.Status = 'Closed';
            INSERT existingCase;


            Test.startTest();

            //Update Work Order Status to Closed
            Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
            System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );

            updateCont.CW_Work_Order_Status__c = 'Closed';
            NHW_ContactHandler.isexecuted = false;
            UPDATE updateCont;

            Test.stopTest();//Async threads will end.

            Contact con = [ select Id, Status__c,Start_Date__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
            System.AssertEquals(con.Start_Date__c,con.EmlpoyeeCases__r[0].NHW_Start_Date__c,MSG_START_DATES_FOR_CASE_SHOULD_MATCH);

            System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_ONLY_ONE_CASE_TO_BE_CREATED );
            System.AssertEquals('Closed',con.EmlpoyeeCases__r[0].Status,MSG_EXPECTING_CASE_TO_BE_CLOSED_CANCELLED);

        }

    /**
     * Given: An Existing CW has an existing Provisioning Case with Start Date of Tomorrow (Before Day 1)
     * When: the Contractor Work Order is Rescinded (Closed)
     * Then: the related Case should be set to close cancelled.
     */
       static testmethod void rescind_CWContactBeforeDay1(){
           //Create Contact.
           Date startDate = system.today()+ 10;
           Contact CWContact = populateContact('Accepted',startDate);
           NHW_ContactHandler.isexecuted = true;
           INSERT CWContact;

           Case existingCase = new Case();
           existingCase = populateExistingCase(CWContact, existingCase);
           INSERT existingCase;


           Test.startTest();

           //Update Work Order Status to Closed
           Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
           System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );

           updateCont.CW_Work_Order_Status__c = 'Closed';
           NHW_ContactHandler.isexecuted = false;
           UPDATE updateCont;

           Test.stopTest();//Async threads will end.

           Contact con = [ select Id, Status__c,Start_Date__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
           System.AssertEquals(con.Start_Date__c,con.EmlpoyeeCases__r[0].NHW_Start_Date__c,MSG_START_DATES_FOR_CASE_SHOULD_MATCH);

           System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_ONLY_ONE_CASE_TO_BE_CREATED );
           System.AssertEquals(CASE_STATUS_CLOSED_CANCELLED,con.EmlpoyeeCases__r[0].Status,MSG_EXPECTING_CASE_TO_BE_CLOSED_CANCELLED);

        }

    /**
     * Given: An Existing CW has an existing Provisioning Case with Start Date of Today (On Day 1)
     * When: the Contractor Work Order is Rescinded (Closed)
     * Then: the related Case should be set to close cancelled.
     */
       static testmethod void rescind_CWContactOnDay1(){
           //Create Contact.
           Date startDate = system.today();
           Contact CWContact = populateContact('Accepted',startDate);
           NHW_ContactHandler.isexecuted = true;
           INSERT CWContact;

           Case existingCase = new Case();
           existingCase = populateExistingCase(CWContact, existingCase);
           INSERT existingCase;


           Test.startTest();

           //Update Work Order Status to Closed
           Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
           System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );

           updateCont.CW_Work_Order_Status__c = 'Closed';
           NHW_ContactHandler.isexecuted = false;
           UPDATE updateCont;

           Test.stopTest();//Async threads will end.

           Contact con = [ select Id, Status__c,Start_Date__c,(Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) from Contact where Id = :CWContact.Id ];
           System.AssertEquals(con.Start_Date__c,con.EmlpoyeeCases__r[0].NHW_Start_Date__c,MSG_START_DATES_FOR_CASE_SHOULD_MATCH);

           System.AssertEquals(1,con.EmlpoyeeCases__r.size(),MSG_EXPECTING_ONLY_ONE_CASE_TO_BE_CREATED );
           System.AssertEquals(CASE_STATUS_CLOSED_CANCELLED,con.EmlpoyeeCases__r[0].Status,MSG_EXPECTING_CASE_TO_BE_CLOSED_CANCELLED);

        }

    /** -----------------------  GENERAL CONVERSION UNIT TESTS  ----------------------- **/

    /**
     * Given: An Existing FTE with Term Date in the past
     * When: the Contact is Converted to a CW and all data is present to create a case
                * with a start date in the onbaording window
     * Then: a case should be created
     */
    static testmethod void conversion_FTEtoCW(){
        Id employeeRTId = NHW_Util.getEmployeeContactRecordTypeId();
        //Create Employee RT Contact
        Contact empCon = new Contact();
        empCon.FirstName = 'Test';
        empCon.LastName = 'Employee1';
        empCon.Email = 'test_employee1@salesforce.com.invalid';
        empCon.Status__c = 'Deactive';
        empCon.RecordTypeId = employeeRTId;
        empCon.EmployeeNumber__c = '789'+ String.valueOf(math.random()).left(6);
        empcon.Start_Date__c = System.today() - 720;
        empCon.Term_Date__c = System.today() - 10;
        empCon.AccountId = Onboarding_Setting__c.getInstance().salesforce_accountId__c;

        INSERT empCon;

        Test.startTest();
        Date TenDaysInFuture = system.today()+ 10;
        empCon = populateContact('Accepted',TenDaysInFuture,empCon);
        empCon.Previous_SF_Worker__c = true;
        NHW_ContactHandler.isexecuted = false;
        UPDATE empCon;

        Test.stopTest();//Async threads will end.

        Contact con = [ select Id, Status__c,(Select id,status from EmlpoyeeCases__r) from Contact where Id = :empCon.Id ];
        System.AssertEquals(con.EmlpoyeeCases__r.size(),1,MSG_EXPECTING_ONE_CASE_TO_BE_CREATED);

    }

    /** -----------------------  VALIDATE RECORD STATUS UNIT TESTS  ----------------------- **/

    /**
     * Given: A Contractor Contact in context of SSOR being live
     * When: is created
     * Then: Record Status should be set to 'New'
     */
    static testmethod void new_CW_Created_RecordStatus_New(){
        //Create Contact.
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Activated',TenDaysInFuture);
        CWContact.CW_Type__c= 'CW';

        Test.startTest();
            INSERT CWContact;
        Test.stopTest();//Async threads will end.

        Contact con = [ select Id, Status__c, ES_DJC_Record_Status__c from Contact where Id = :CWContact.Id ];
        System.assertEquals(con.ES_DJC_Record_Status__c, 'New', 'Record Status should be defaulted to New on Create');

    }

    /**
     * Given: A Contractor Contact in context of SSOR being live
     * When: has a field updated
     * Then: Record Status should be set to 'New'
     */
    static testmethod void updated_CW_Created_RecordStatus_Updated(){
        ID ProfileID = [ Select id from Profile where name = 'Customer Portal Manager Custom'].id;
        
        
        //Create Contact.
        Test.startTest();
        Date TenDaysInFuture = system.today()+ 10;
        
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'IT_NH_Admin' Limit 1];
        
        User adminUser = [Select UserRoleId From User Where id =: UserInfo.getUserId()];
        
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        Contact CWContact;
        System.runAs(adminUser){
            Account A1 = new Account(Name = 'Test Account');
            insert A1;
            CWContact = populateContact('Activated',TenDaysInFuture);
            CWContact.CW_Type__c= 'CW';
            CWContact.AccountId = A1.Id;
            INSERT CWContact;
            User u1 = new User( email='test-user@fakemail.com', contactid = CWContact.id, profileid = profileid,
                               
                               UserName='test-user@fakemail.com', alias='tuser1', CommunityNickName='tuser2',
                               TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1',
                               LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User',Division = DIVISION );
            
            insert u1;
            NHW_ContactHandler.isExecuted=false;
            CWContact.ES_DJC_Business_Unit__c = '101-Test';
            Update CWContact;
            Test.stopTest();//Async threads will end.
            
            Contact con = [ select Id, Status__c, ES_DJC_Record_Status__c from Contact where Id = :CWContact.Id ];
            System.assertEquals('Updated',con.ES_DJC_Record_Status__c, 'Record Status should be set to Updated on update of Business Unit');
            
        }
        
    }
	//W-15308729 code added for SD changes > 30 requirements 
	 /**
     * Given: a contact gets deactivated when start date is updated beyond 30 days (to cover method :NHW_contactToCaseUtilperformUpdatesToCaseIfEmployeeContact)
     * When: an employee contact is activated or deactivated
     * Then: associated case status should be updated to 'On Hol' or back.
     */
    static testmethod void testCasestoOnHold(){
        
		TF2_Department__c dept = new TF2_Department__c(Department_Number__c = '7419', Name = 'IT Apps');
		Business_Unit__c BU = new Business_Unit__c(BU_Code__c = '2301', Name = 'Shared Services');
		TF2_Company__c Comp = new TF2_Company__c(Company_Code__c = '100', Name = '100-United States of America');
		TF2_PCC__c pcc = new TF2_PCC__c(name = '100-United States of America');
		TF2_Business_Site__c buSite = new TF2_Business_Site__c(name = 'Remote -California - San Francisco',Country__c = 'Unites States', Street_Address__c = '350 Mission St',  Type__c = 'City');
		insert dept;
		insert BU;
		insert COMP;
		insert PCC;
		insert buSite;
		
        Date TenDaysInFuture = system.today()+ 10;
        Contact CWContact = populateContact('Accepted',TenDaysInFuture);
		CWContact.Status__c ='Active';
		CWContact.recordTypeId=NHW_Util.getEmployeeContactRecordTypeId();
		CWContact.SF_Work_Email__c ='testemail12121@salesforce.com';
		CWContact.EmployeeNumber__c='testemail12121';
        insert CWContact;
		
		WDR_Job__c DefaultJobReq = new WDR_Job__c();
		DefaultJobReq.Name = 'Test JobReq';
		DefaultJobReq.Job_Title__c = 'MTS';
		DefaultJobReq.Job_Level__c = 'Grade 4';
		DefaultJobReq.Job_Code__c = '1235PQ';
		DefaultJobReq.Employment_Type__c = 'SFDC Employee';
		DefaultJobReq.PCC__c = pcc.id;
		DefaultJobReq.Region__c = 'AMER';
		DefaultJobReq.Division__c = 'Americas - All countries';
		DefaultJobReq.Target_Hire_Date__c = System.today().adddays(15);
		DefaultJobReq.Department__c = dept.id;
		DefaultJobReq.Business_Unit__c = bu.id;
		DefaultJobReq.Company__c = comp.id;
		DefaultJobReq.Hiring_Manager__c = UserInfo.getUserId();
		DefaultJobReq.Req_Creation_Reason__c = 'Regular';
		insert DefaultJobReq;
		
		WDR_Candidate__c DefaultCandidate = new WDR_Candidate__c();
		DefaultCandidate.First_Name__c = 'Test F';
		DefaultCandidate.Last_Name__c = 'Test L';
		DefaultCandidate.Name = 'Test F' + 'Test L';
		DefaultCandidate.Email__c = 'Test_F_L@salesforce.com';
		DefaultCandidate.Mailing_City__c = 'San Francisco';
		DefaultCandidate.Mailing_Country__c = 'United States of America';
		DefaultCandidate.Mailing_Postal_Code__c = '94002';
		DefaultCandidate.Mailing_State__c = 'CA';
		DefaultCandidate.Mailing_Street__c = '350 mission st';
		DefaultCandidate.Candidate_Contact__c = CWContact.Id;
		DefaultCandidate.Employee_Number__c='testemail12121';
		insert DefaultCandidate;
		
		WDR_Application__c DefaultJobApplication = new WDR_Application__c();
		DefaultJobApplication.Business_Site__c = buSite.id;
		DefaultJobApplication.Offer_Type__c = 'Perm/FTE';
		DefaultJobApplication.Offer_Status__c = 'Approved';
		DefaultJobApplication.Start_Date__c = System.Today().adddays(10);
		DefaultJobApplication.Candidate_Stage__c = 'Placement';
		DefaultJobApplication.Candidate__c = DefaultCandidate.Id;
		DefaultJobApplication.Job__c = DefaultJobReq.Id;
		insert DefaultJobApplication;
				

        Case existingCase = new Case();
		existingCase.Subject = 'New Hire Provisioning Request for test user' ;
        existingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId();
        existingCase.NHW_Employee_Type__c = 'contractor';
        existingCase.NHW_Page_Number__c = 0;
        existingCase.Origin = 'NHW';
        existingCase.Type = 'NHW';
        existingCase.Description = '';
        existingCase.Job_Status__c = '';
		existingCase.NHW_Start_Date__c =TenDaysInFuture;
		existingCase.NHW_Employee_Type__c='';
		existingCase.NHW_Employee__c =CWContact.id;
		existingCase.NHW_Job_Application__c =DefaultJobApplication.id;
		existingCase.Status='New';
	
		
        insert existingCase;
		Case te= [select Id, NHW_Employee__c,
							  NHW_Start_Date__c, 
							  Status,
							  Email_Address__c, 
							  NHW_Business_Unit__c, Business_Unit_NHW__c, 
							  NHW_Cost_Center__c, Cost_Center_NHW__c,
							  NH_Business_Site__c, Office_Address__c, Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c,
							  NHW_Job_Application__r.Candidate__c, NHW_Job_Application__r.Candidate__r.Name,
							  NHW_Job_Application__r.Candidate__r.Mailing_Street__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_City__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_State__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Country__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c
							  ,recordtype.DeveloperName,
							  Status_before_OnHold__c,
							  NHW_Employee__r.SF_Work_Email__c,
							  NHW_Employee__r.EmployeeNumber__c,
							  NHW_Job_Application__r.Candidate__r.Employee_Number__c
					  from case where id=:existingCase.id ];
        System.debug('test class case-->'+te);
		

        Test.startTest();
		
            Contact updateCont = [SELECT Id, (Select id,status,Resource_Type__c,NHW_Start_Date__c from EmlpoyeeCases__r) FROM Contact WHERE Id =: CWContact.Id];
			
            System.AssertEquals(1,updateCont.EmlpoyeeCases__r.size(),MSG_BEFORE_UPDATE_CASE_SHOULD_EXIST );
			updateCont.Status__c ='Deactive';
            NHW_ContactHandler.isexecuted = false;
            update updateCont;
			
			Case casecheck= [select Id, NHW_Employee__c,
							  NHW_Start_Date__c, 
							  Status,
							  Email_Address__c, 
							  NHW_Business_Unit__c, Business_Unit_NHW__c, 
							  NHW_Cost_Center__c, Cost_Center_NHW__c,
							  NH_Business_Site__c, Office_Address__c, Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c,
							  NHW_Job_Application__r.Candidate__c, NHW_Job_Application__r.Candidate__r.Name,
							  NHW_Job_Application__r.Candidate__r.Mailing_Street__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_City__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_State__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Country__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c
							  ,recordtype.DeveloperName,
							  Status_before_OnHold__c,
							  NHW_Employee__r.SF_Work_Email__c,
							  NHW_Employee__r.EmployeeNumber__c,
							  NHW_Job_Application__r.Candidate__r.Employee_Number__c
					  from case where id=:existingCase.id ];
			System.debug('test class case2-->'+casecheck);
			System.assertEquals(casecheck.Status,'New',THE_CASE_STATUS_SHOULD_BE_ON_HOLD);
			
			
			existingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId();
			existingCase.Status='On Hold';
			update existingCase;
			Case tes= [select Id, NHW_Employee__c,
							  NHW_Start_Date__c, 
							  Status,
							  Email_Address__c, 
							  NHW_Business_Unit__c, Business_Unit_NHW__c, 
							  NHW_Cost_Center__c, Cost_Center_NHW__c,
							  NH_Business_Site__c, Office_Address__c, Office_City__c, Office_Country__c, Office_State_Province__c, Office_Zip_Postal_Code__c,
							  NHW_Job_Application__r.Candidate__c, NHW_Job_Application__r.Candidate__r.Name,
							  NHW_Job_Application__r.Candidate__r.Mailing_Street__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_City__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_State__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Country__c,
							  NHW_Job_Application__r.Candidate__r.Mailing_Postal_Code__c
							  ,recordtype.DeveloperName,
							  Status_before_OnHold__c,
							  NHW_Employee__r.SF_Work_Email__c,
							  NHW_Employee__r.EmployeeNumber__c,
							  NHW_Job_Application__r.Candidate__r.Employee_Number__c
					  from case where id=:existingCase.id ];
			System.debug('test class case2-->'+tes);
			
			updateCont.Status__c ='Active';
			NHW_ContactHandler.isexecuted = false;
			update updateCont;
			
			updateCont.Status__c ='Deactive';
            NHW_ContactHandler.isexecuted = false;
            update updateCont;
			
			
        Test.stopTest();//Async threads will end.

           Contact con = [ select Id, Status__c,Resource_Type__c,(Select id,status,Resource_Type__c from EmlpoyeeCases__r ) from Contact where Id = :CWContact.Id ];
			System.debug(con);



    }
}