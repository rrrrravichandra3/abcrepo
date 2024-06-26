@isTest
public class MA_TestUtil {
    
    public static List<Acquisition_Company__c> createAcquisitionCompany(Integer numberOfRecords, Boolean doInsert){
        List<Acquisition_Company__c> listCompany = new List<Acquisition_Company__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Acquisition_Company__c objComp = new Acquisition_Company__c();
            objComp.Acquisition_Company_Name__c = MA_TestUtilityValues.COMPANY_NAME+'_'+String.valueOf(i);
            objComp.Close_Date__c = System.today().addDays(60);
            objComp.M_A_HRIS_ID__c = MA_TestUtilityValues.M_A_HRIS_ID;
            objComp.Number_of_Employees__c  = MA_TestUtilityValues.NUMBER_OF_EMPLOYEES;
            objComp.Status__c = 'Integration Planning';
            listCompany.add(objComp);
        }
        if(doInsert){
            insert listCompany;
        }
        return listCompany;
    }
    
     public static List<Acquisition_Contacts__c> createAcqContact(Integer numberOfRecords,Id acqCompId, Boolean doInsert){
        List<Acquisition_Contacts__c> acqConList = new List<Acquisition_Contacts__c>();
        
         
        for(Integer i=0;i<numberOfRecords; i++){
     
            Acquisition_Contacts__c objContact = new Acquisition_Contacts__c(
                Acquisition_Company__c = acqCompId,
                Entity_Name__c= null,
                Employee_ID_Target__c='Emp198234',
                
                Notes__c= null,
                Background_Check__c='Distributed to Employee',
                Birth_Date__c= Date.valueOf('1989-02-01'),
                Email_Address_Target__c='testcommunity_'+String.valueOf(i)+ MA_TestUtilityValues.EMAILSUFFIX_TESTUSER,
                Business_Unit__c='B64',
                Contractor_Agency_Name__c= null,
                Continuous_Service_Date__c= Date.valueOf('2023-01-24'),
                Contractor_End_Date__c= null,
                Cost_Center__c='CC823',
                Phone_Number_Target__c='2025550103',
                Cube_Location_Floor__c= null,
                Office_Address_City_Target__c= null,
                Office_Address_Country_Target__c= null,
                Office_Address_State_Province_Target__c= null,
                Office_Address_Street_Target__c= null,
                Office_Address_Zip_Postal_Code_Target__c= null,
                Contractor_Start_Date__c= null,
                Day_1_Address_City__c= null,
                Day_1_Address_Country__c= null,
                Day_1_Address_State_Province__c= null,
                Day_1_Address_Street__c= null,
                Day_1_Address_Zip_Code__c= null,
                Day_1_Location__c= null,
                Department__c= null,
                Distance_from_SF_Office__c= null,
                Division__c= null,
                Founder_Type__c='Founder',
                Employee_ID__c='853887',
                Employee_Type__c='Fixed Term (Fixed Term)',
                Employment_Package__c= null,
                Manager_Name_Target__c= null,
               
                First_Name_Legal__c='PWWI',
                Gender__c='I prefer not to disclose',
                Hire_Reason__c='Hire Acquisition',
                Home_Address_City__c='City',
                Home_Address_Country__c='United States of America',
                Home_Address_Region__c='USA-TX',
                Home_Address_Street__c='Street Line 1',
                Home_Address_Zip_Postal_Code__c='73301',
                Home_Address_State_Province__c='State',
                ID_Type__c='USA-SSN',
                IT_Onboarding_Day_1_Date__c= null,
                Last_Name_Legal__c='Mark1',
                Middle_Name_Legal__c= null,
                SSN_ID_Number__c= null,
                Office_Address_City__c= null,
                Office_Address_Country__c='United States of America',
                Office_Address_State_Province__c= null,
                Office_Address_Street__c= null,
                Office_Address_Zip_Postal_Code__c= null,
                Onboarding_Group__c= null,
                Business_Title_Target__c='Senior Manager, Accounts Payable/Receivable',
                Remote__c= null,
                Original_Hire_Date__c= Date.valueOf('2023-06-12'),
               
                Executive__c= false,
                Personal_Email_Address__c='test_'+String.valueOf(i)+'@salesforce.com',
                Personal_Phone_Number__c='2025550104',
                First_Name_Preferred__c= null,
                Last_Name_Preferred__c= null,
                Primary_Coverage_Country__c='100-United States of America',
                Probation_End_Date__c= Date.valueOf('2023-08-30'),
                Leader__c= false,
                Manager_ID_Target__c= null,
                Rehire_Former_Worker__c= false,
                Remote_Non_Remote__c= null,
                Resource_Type__c= null,
                Business_Title__c='Software Engineer',
                Hire_Date__c= Date.valueOf('2023-06-19'),
                Manager_ID__c= null,
                Acquisition_Org__c='Acquisition Temp Org',
                Pay_Rate_Type__c='Hourly',
                Badge_Access_Required_Post_Day_1__c= false,
                Contact_Status__c='New',
                Hire_Date_Target__c= Date.valueOf('2023-01-24'),
                Team__c= null,
                Term_Date_Target__c= null,
                Transitional_Employee__c= true,
                Temporary_Password__c= null,
               
                Workday_Location__c='India - Mumbai',
                Salesforce_Email_Address__c= null,
                Employee_Type_Target__c= null,
                Company_Service_Date__c= Date.valueOf('2023-01-24'),
                Total_Years_of_Service__c= null,
                Visa_Type__c='USA_B1_VISA',
                Visa_Expiration_Date__c= Date.valueOf('2036-05-22'),
                Contractor_Status__c= null,
       
               
                Nationality__c= null,
                Marital_Status__c= null,
                People_Manager__c= false,
                
                Citizenship__c= null,
                Probation_Start_Date__c= Date.valueOf('2023-08-01'),
                Permanent_Residency_Process_Initiated__c= false,
                Home_Address_Street_Line_2__c='Street Line 2',
                Contractor_Type__c= null,
                University__c= null,
                Employment_End_Date__c= null,
                Background_Check_Notes__c= null,
                Transitional_Time_Period__c= null,
                Currently_Has_Badge_Access__c= null,
                Change_in_Control_CiC__c= false,
                CiC_Notes__c= null,
                CiC_End_Date__c= null,
                Leave_of_Absence_LOA__c= false,
                LOA_Type__c= null,
                LOA_Start_Date__c= null,
                LOA_End_Date_Estimated__c= null,
                Contractor__c= false,
                Additional_Field_1__c= null,
                Additional_Field_2__c= null,
                Additional_Field_3__c= null,
                Additional_Field_4__c= null,
                Additional_Field_5__c= null,
                Transitional_End_Date__c= null,
                Severance_Weeks__c= null,
                COBRA_Months__c= null,
                Outplacement_Months__c= null,
                Company__c='C4',
                Data_Centre__c= false,
                I_9_Right_to_Work_Verified__c= false,
                I_9_Right_to_Work_Notes__c= null,
                Benefits_Enrolled__c= false,
                First_Timesheet_Submitted__c= false,
                Arbitration_Agreement_Opt_Out__c= false,
                Key_Critical_Employee__c='Key',
                Manager_Name__c= null,
               
                Currently_Has_Network_Access__c= null,
                Currently_on_Payroll__c= null,
                Email_Address_Required_Post_Day_1__c= false,
                Network_Access_Required_Post_Day_1__c= false,
                Prior_Employee_of_Target_Company__c= false,
                Visa_Number__c= null,
                Workday_Setup_Required_Post_Day_1__c= false,
                Work_Location_Target__c= null,
                Last_Modified_in_Orgvue__c= null,
                MuleExtId__c='Emp198234=Tangile',
                Salesforce_Laptop_Selection__c= null,
                Temporary_Local_Password_Mac_Only__c= null,
                Confirmed_On__c= null,
                Full_Name_Preferred__c= null,
                Offer_Date_Target__c= null,
                PTO_Annual_Leave_Days__c= null,
                Remove_Community_Access__c= false,
                SSNID_Number__c= '950434721',
                Active_at_Close__c= false,
                Active_at_Harmonization__c= false,
                Department_Target__c= null,
                Time_Zone__c= null,
                User_Time_Zone_Updated__c= false,
                Enable_My_Team_Tab__c= false,
                Offer_Communicator__c= null,
                Offer_Managed_By__c= null,
                PTO_Annual__c= null,
                Recruiting__c= false,
                Number_of_Positions__c= null,
                Country_of_Birth__c='United Kingdom',
                Position_Request_Reason__c= null,
                Supervisory_Organization__c='Test',
                Work_Location_Status__c= null,
                Applicant_ID__c='APPLICANT-6-117041',
                Position_ID_CW__c='P-128184',
                Position_ID_FTE__c='P-128185'
            );
            
            acqConList.add(objContact);
        }
         if(doInsert){
             insert acqConList;
         }
         return acqConList;
    }
    
    public static List<User> createSystemAdminUser(Integer numberOfRecords,String profileId,String dummyRoleId, Boolean doInsert){
        List<User> sysAdminList = new List<User>();
        for(Integer i = 0; i < numberOfRecords; i++){
            User objUser = new User();
        	objUser.ProfileId = profileId;
            objUser.UserRoleId = dummyRoleId;
        	objUser.Username = 'testsysadminuser'+String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
        	objUser.Alias = 'admin'+String.valueOf(i);
        	objUser.Email= 'test_'+String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
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
    
    public static List<User> createPortalUser(Integer numberOfRecords, String profileId, String dummyRoleId, String contactId, Boolean doInsert){
        List<User> portalUserList = new List<User>();
        for(Integer i = 0; i < numberOfRecords; i++){
            User objUser = new User();
        	objUser.ProfileId = profileId;
            objUser.UserRoleId = dummyRoleId;
            objUser.ContactId = contactId;
        	objUser.Username = 'testportal'+String.valueOf(i)+'@community.com.wayfinder';
        	objUser.Alias = 'test'+String.valueOf(i);
        	objUser.Email= 'testcommunity_'+String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
            objUser.FederationIdentifier = 'testcommunity_'+String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
        	objUser.EmailEncodingKey='UTF-8';
        	objUser.Firstname='Community_'+String.valueOf(i);
        	objUser.Lastname='Portal_User_'+String.valueOf(i);
            objUser.CommunityNickname = 'test'+String.valueOf(i);
        	objUser.LanguageLocaleKey='en_US';
        	objUser.LocaleSidKey='en_US';
        	objUser.TimeZoneSidKey='America/Los_Angeles';
            objUser.IsActive = true;
            portalUserList.add(objUser);
        }
        if(doInsert){
            insert portalUserList;
        }
        return portalUserList;
    }
    
    public static List<User> createESUser(Integer numberOfRecords,String profileId,String roleId, Boolean doInsert, String name){
        List<User> esUserList = new List<User>();
        for(Integer i = 0; i < numberOfRecords; i++){
            User objUser = new User();
        	objUser.ProfileId = profileId;
            objUser.UserRoleId = roleId;
        	objUser.Username = name + String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
        	objUser.Alias = 'es'+String.valueOf(i);
        	objUser.Email= name + 'testES_'+String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
        	objUser.EmailEncodingKey='UTF-8';
        	objUser.Firstname= 'ES_'+String.valueOf(i);
        	objUser.Lastname='ES_User_'+String.valueOf(i);
        	objUser.LanguageLocaleKey='en_US';
        	objUser.LocaleSidKey='en_US';
        	objUser.TimeZoneSidKey='America/Chicago';
            esUserList.add(objUser);
        }
        if(doInsert){
            insert esUserList;
        }
        return esUserList;
    }
    
    public static List<Account> createAccount(Integer numberOfRecords, String accCompanyId, Boolean doInsert ){
        List<Account> listAccount = new List<Account>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Account account = new Account();
           	account.Name = 'MA';
            account.Acquisition_Companies__c = accCompanyId;
            account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(MA_TestUtilityValues.ACCOUNT_RECORD_TYPE).getRecordTypeId();
            listAccount.add(account);
        }
        if(doInsert){
            insert listAccount;
        }
        return listAccount;
    }
    
    public static List<Contact> createContact(Integer numberOfRecords, String accountId, String accContactId, Boolean doInsert ){
        List<Contact> listContact = new List<Contact>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Contact contact = new Contact();
           	contact.FirstName = 'Community';
            contact.Lastname = 'Contact';
            contact.AccountId = accountId;
            contact.Email = 'testcommunity_'+String.valueOf(i) + MA_TestUtilityValues.EMAILSUFFIX_TESTUSER;
            contact.Acquisition_Contacts__c = accContactId;
            contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(MA_TestUtilityValues.CONTACT_RECORD_TYPE_MA).getRecordTypeId();

            listContact.add(contact);
        }
        if(doInsert){
            insert listContact;
        }
        return listContact;
    }
    
    public static List<Case> createCase(Integer numberOfRecords, String contactId, String name, Boolean doInsert ){
        List<Case> listCase = new List<Case>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Case caseRec = new Case();
            caseRec.subject = name + i;
           	caseRec.Origin = 'Email';
            caseRec.Type = 'Benefits';
            caseRec.ContactId = contactId;
            caseRec.Status = 'Open';
            caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(MA_TestUtilityValues.CASE_RECORD_TYPE).getRecordTypeId();

            listCase.add(caseRec);
        }
        if(doInsert){
            insert listCase;
        }
        return listCase;
    }
    
    public static List<Acquisition_Company_Task__c> createAcquisitionCompanyTask(String acqCompanyId, Integer numberOfRecords, Boolean doInsert){
        List<Acquisition_Company_Task__c> listCompanytask = new List<Acquisition_Company_Task__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Acquisition_Company_Task__c objComptask = new Acquisition_Company_Task__c();
            objComptask.Acquisition_Company__c  = acqCompanyId;
            objComptask.Due_Date__c  = System.today().addDays(60);
            objComptask.Subject__c  = 'Acquisition_Company_Task_'+i;
            objComptask.Status__c = 'Not Started';
            objComptask.Active__c = true;
            listCompanytask.add(objComptask);
        }
        if(doInsert){
            insert listCompanytask;
        }
        return listCompanytask;
    }
    
    public static List<Acquisition_contact_task__c> createAcquisitionContactTask(String accCompTaskId, String accContactId, Integer numberOfRecords, Boolean doInsert){
        List<Acquisition_contact_task__c> listContacttask = new List<Acquisition_contact_task__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Acquisition_contact_task__c objContactTask = new Acquisition_contact_task__c();
            objContactTask.Acquisition_Contact__c   = accContactId;
            objContactTask.Acquisition_Company_Task__c   = accCompTaskId;
            objContactTask.Key_Identifier__c = accContactId+i;
            objContactTask.subject__c = 'TaskSubject'+i;
            objContactTask.Due_Date__c  = System.today().addDays(60);
            listContacttask.add(objContactTask);
        }
        if(doInsert){
            insert listContacttask;
        }
        return listContacttask;
    }
    
    public static List<MA_Community_Events__c> createCommunityEvents(String acqCompanyId,String name, Integer numberOfRecords, Boolean doInsert){
        List<MA_Community_Events__c> listComunityEvent = new List<MA_Community_Events__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            MA_Community_Events__c objComEvent = new MA_Community_Events__c();
            objComEvent.Acquisition_Company__c  = acqCompanyId;
            objComEvent.Name  = name + i;
            objComEvent.Start_Date__c  = System.today().addDays(1);
            objComEvent.Active__c = true;
            listComunityEvent.add(objComEvent);
        }
        if(doInsert){
            insert listComunityEvent;
        }
        return listComunityEvent;
    }
    
    public static PermissionSetAssignment createPermissionsetAssignment(String permissionSetId, String assigneeId, Boolean doInsert ){
        
        PermissionSetAssignment assignmentUser = new PermissionSetAssignment();
        assignmentUser.PermissionSetId = permissionSetId;
        assignmentUser.AssigneeId = assigneeId;
        
        if(doInsert){
            insert assignmentUser;
        }
        return assignmentUser;
    }
    public static List<Knowledge__kav> createKnowledgeArticle(Integer numberOfRecords, String title, Boolean doInsert ){
        List<Knowledge__kav> listArticles = new List<Knowledge__kav>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Knowledge__kav article = new Knowledge__kav();
           	article.Title = title;
			article.UrlName = title + '-article';
            article.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get(MA_TestUtilityValues.KNOWLEDGE_RECORD_TYPE).getRecordTypeId();
            listArticles.add(article);
        }
        if(doInsert){
            insert listArticles;
        }
        return listArticles;
    }
    public static List<ContentVersion> createContentVersion(Integer numberOfRecords, String title, Boolean doInsert ){
        List<ContentVersion> listcontents = new List<ContentVersion>();
        for(Integer i = 0; i < numberOfRecords; i++){
            ContentVersion content = new ContentVersion();
           	content.Title = title+i;
			content.PathOnClient = 'Pic.jpg';
            content.VersionData = Blob.valueOf('Test Content');
            content.IsMajorVersion = true;
            content.origin = 'H';
            listcontents.add(content);
        }
        if(doInsert){
            insert listcontents;
        }
        return listcontents;
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
    
}