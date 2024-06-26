@SuppressWarnings('PMD.ExcessiveParameterList')
global class  ESDJC_New_User_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    private ESDJC_Integration_Log__c log;
    private ESDJC_Settings__c settings; 
    private String batchStatus {get;set;}
    Map<String, Contact> empNo2ContactMap = new Map<String, Contact>();
    Map<Id, Contact> employeeConMap = new Map<Id, Contact>();
    Map<String, Contact> empNo2WContactMap = new Map<String, Contact>();
    Set<Id> newEmployeeContact = new Set<Id>();
    Map<String, String> empNo2ContactIdMap = new Map<String, String>();
    ID employeeProfileID;
    Id preboardingProfileId;
    List<String> businessUnits = new List<String>(); // business units to be excluded
    Set<String> businessUnitsSet = new Set<String>(); 	
    global static String SUCCESS_MESSAGE = 'New - Completed';
    global static String ERROR_MESSAGE = 'New - ERROR: ';
    public static String  EMPLOYEE_NUMBER_ERROR = ERROR_MESSAGE + ' - User creation failed. Employee Number is empty or not a numeric';
    public static String  EMPLOYEE_BUSINESSUNIT_ERROR = ERROR_MESSAGE + ' - User creation failed. Business unit is missing or Not qualified for user creation';
    public static String  EMPLOYEE_USER_ERROR =  ERROR_MESSAGE + ' - Contact\'s non portal user does not exist';
    public static String  CONTACT_STRING = 'Contact : ';
    public static String  RECORD_PROCESSING_STRING = ' record processing Failed with message : ';
    public String errorMessage = '';
    global ESDJC_New_User_Batch(ESDJC_Integration_Log__c log) {
        this.log = log;
        settings = ESDJC_Settings__c.getInstance();   
        employeeProfileID = settings.Portal_User_Profile_Id__c;
        preboardingProfileId = settings.Preboarding_ProfileId__c;  
        batchStatus = 'Success';        
        log.DJC_New_User_Batch_Job_Start_Time__c = DateTime.now();
        log.DJC_New_User_Job_Status__c = 'In Progress';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bC){
        System.debug('+++ESDJC_New_User_Batch start');
        DateTime cutoffDate = DateTime.valueOf(settings.Phoenix_ESDJC_Batch_Cutoff_Date__c );
        System.debug('+++ cutoffDate' + cutoffDate);
        return Database.getQueryLocator([SELECT Name,FirstName,LastName,Email, ES_DJC_Business_Unit__c,EmployeeNumber__c,Id,ES_DJC_Is_Manager__c, ReportsTo.Name, Secondary_Email__c ,Start_Date__c, Division__c, Boomerang__c, Title,ES_DJC_Cost_Center__c,Primary_Country_of_Coverage_PCC__c   FROM Contact 
                                         WHERE (ES_DJC_Record_Status__c = 'New' OR ES_DJC_Record_Status__c = 'Updated') AND RecordType.name='Employee' 
                                         AND Status__c = 'Active' AND LastModifiedDate > :cutoffDate AND Start_Date__c >= :Date.today().addDays(-2) ]);
    }
    
    
    global void execute(Database.BatchableContext bc,  List<sObject> scope){
        try {
            System.debug('+++ESDJC_New_User_Batch execute scope.size()='+scope.size());
            List<Database.UpsertResult> upsertResults;
            Database.UpsertResult upsertResult;
            
            
            excludeBusinessUnits();
            
            Contact aContact;   
            for(Sobject s : scope){
                aContact = (Contact) s;
                filterContacts(aContact);
            }
            
            //Query to fetch WDR contacts for Email & Boomerang field which are having same employeenumber as Employee Contact
            List<Contact> wdrContactList = new List<Contact>();
            wdrContactList = [Select ID, Email,Boomerang__c,EmployeeNumber__c from Contact where RecordType.Name = 'WDR Candidate' AND EmployeeNumber__c IN:empNo2ContactIdMap.keySet()];
            for(Contact wdrCon: wdrContactList){
                empNo2WContactMap.put(wdrCon.EmployeeNumber__c,wdrCon);
            }
            system.debug('empNo2WContactMap-->'+empNo2WContactMap.size());
            
            
            if(Schema.Sobjecttype.User.isCreateable() && Schema.Sobjecttype.User.isUpdateable()){
                //-------------Create User List -------------------//
                
                List<User> newUsers = new List<User>();
                List<User> existingEmpPortalUsers = [SELECT Username, Division, ContactId, Email, Name,FirstName, LastName, Alias, CommunityNickname,languagelocalekey,localesidkey, timeZoneSidKey, emailEncodingKey , CurrencyIsoCode , IsActive, EmployeeNumber, FullPhotoUrl, UserPermissionsChatterAnswersUser FROM User WHERE profileId =: employeeProfileID  AND IsActive = false AND EmployeeNumber IN:empNo2ContactIdMap.keySet()];
                
                populateSetOfNewContacts(existingEmpPortalUsers);
                
                /* Query to check existing preborading portal users associate to employee contacts
If records are found, those employee contacts will get removed & making them active from the newEmployeeContact set */
                
                reactivatePreboardingPortalUsers(newUsers);
                
                /* Rehire user updation - modified as a part of project phoenix enhancement
*/
                createUserForRehires(existingEmpPortalUsers,newUsers);
                
                
                /* Create Preboarding user records based out of newEmployeeContact Set 
If contact is created on day 1, will create user based out of customer portal manager custom,
Regional permset, email will be salesforce email */
                
                createUserfromContact(newUsers);
                
                upsertResults = Database.upsert(newUsers,User.Fields.Username,false);
                system.debug('upsertResults-->'+upsertResults);
                processUpsertResults(upsertResults,newUsers,upsertResult,aContact);
            }
            else {
                ESDJC_Util.displayAccessPrivilegeError('Create User');
                errorMessage += 'Record status update failed with following error message : User started the batch do not have previlage to create users in the org';
            }
        } catch (Exception e) {
            System.debug('An Exception Occurred: '+ e.getMessage()+ '\n'+ e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext bC){
        System.debug('+++Batch complete empNo2ContactMap='+empNo2ContactMap.size());
        try{
            Database.update(empNo2ContactMap.values(), false);
        }catch(Exception ex){
            batchStatus = 'Failure';
            errorMessage += 'Record status update failed with following error message : ' + (ex.getMessage().length()> 255 ? ex.getMessage().substring(0,255) : ex.getMessage());
        }
        
        
        if(Schema.Sobjecttype.ESDJC_Integration_Log__c.isUpdateable()){
            log.DJC_New_User_Batch_Job_Finish_Time__c = DateTime.now();
            log.DJC_New_User_Job_Status__c = batchStatus;
            
            String[] bodyLines =  new String[] {
                'ESDJC Integration Log Id: '+ log.Id,
                    'ESDJC Integration Log Name: '+ log.Name,
                    '\n',
                    'Integration Start Time: '+log.Integration_Start_Time__c,
                    'Integration Finish Time: '+log.Integration_Finish_Time__c,
                    'Integration Status: '+log.Integration_Status__c,
                    '\n',
                    'DJC New User Batch Job Start Time: '+ log.DJC_New_User_Batch_Job_Start_Time__c,
                    'DJC New User Batch Job Finish Time: '+log.DJC_New_User_Batch_Job_Finish_Time__c,
                    'DJC New User Batch Job Status: '+log.DJC_New_User_Job_Status__c,
                    '\n ************* If batch is failed, Please check following message for Records and corresponding errors:\n',
                    errorMessage
                    };
                        
                        ESDJC_Util.sendStatusEmail(BC, 'ESDJC New User Batch: '+log.Name, new String[] {settings.Batch_Job_Report_Email__c}, bodyLines);        
            update log;
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update ESDJC_Integration_Log__c');
        }
    }
    
    public void excludeBusinessUnits() {
        if(settings.BU_Exclusion_list__c!=null){
            businessUnits = settings.BU_Exclusion_list__c.split(';',-1);
        }
        
        for(String s : businessUnits){
            businessUnitsSet.add(s.trim()); // set to hold Exact Target employees: we are not creating portal users for ET employees. 
        }
    }
    
    
    
    public void processUpsertResults(List<Database.UpsertResult> upsertResults,List<User> newUsers,Database.UpsertResult upsertResult,Contact aContact) {
        User aUser;
        for(Integer i = 0; i < upsertResults.size(); i++){
            try {
                upsertResult = upsertResults.get(i);
                aUser = newUsers.get(i);
                aContact =  empNo2ContactMap.get(aUser.EmployeeNumber);
                if(upsertResult.success){
                    aContact.ES_DJC_Record_Status__c = SUCCESS_MESSAGE;
                    aContact.ES_DJC_Portal_User_Language__c= aUser.languagelocalekey;
                    if(empNo2WContactMap.get(aUser.EmployeeNumber)!=null) {
                        aContact.Boomerang__c = empNo2WContactMap.get(aUser.EmployeeNumber).Boomerang__c;
                    }
                } else {
                    batchStatus = 'Failure';
                    String errorMessageHere = ERROR_MESSAGE+upsertResult.getErrors()[0].getMessage();   
                    aContact.ES_DJC_Record_Status__c = errorMessageHere.length()> 255 ? errorMessageHere.substring(0,255) : errorMessageHere;
                    errorMessage += CONTACT_STRING + aContact.Name + ' -- ' + aContact.EmployeeNumber__c + RECORD_PROCESSING_STRING+ aContact.ES_DJC_Record_Status__c+ '\n';
                }
            } catch (Exception e) {
                System.debug('An Exception Occurred: '+ e.getMessage()+ '\n'+ e.getStackTraceString());
            }
        }
    }
    
    
    
    public void createUserfromContact(List<User> newUsers) {
        if(newEmployeeContact.size()==0){
            return;
        }
        for(Id empCon: newEmployeeContact){
            try{
                User pbUser = new User();
                Contact pbContact = employeeConMap.get(empCon);
                pbUser.FirstName = pbContact.FirstName;
                pbUser.LastName = pbContact.LastName;
                system.debug('employeeConMap.get(empCon).Email-->'+pbContact.Email);
                String email = pbContact.Email;
                String djcORG = '@'+settings.SSO_Dreamjobcentral_ID__c;
                List<String> emailTokens = email.split('@');
                String userName = emailTokens[0]+ djcORG;
                pbUser.Username = userName;
                pbUser.Alias = pbContact.Email.left(5);
                if((pbContact.Start_Date__c != NULL) && Date.today().daysBetween(pbContact.Start_Date__c) <= 1){
                    pbUser.profileId = employeeProfileID;
                    pbUser.Email = pbContact.Email;
                }
                else{
                    pbUser.ProfileId = preboardingProfileId;
                    string personalEmail = pbContact.Secondary_Email__c;
                    if(String.isBlank(personalEmail) && empNo2WContactMap.get(pbContact.EmployeeNumber__c) != null) {
                        pbUser.Email = empNo2WContactMap.get(pbContact.EmployeeNumber__c).Email;
                    } else {
                        pbUser.Email = pbContact.Secondary_Email__c;
                    }
                }
                pbUser.ContactId = empCon;
                pbUser.CommunityNickname = ESDJC_Util.getNickname(8);
                pbUser.IsActive = true;
                pbUser.EmployeeNumber = pbContact.EmployeeNumber__c;
                pbUser.Division = pbContact.Division__c;
                pbUser.UserPermissionsChatterAnswersUser = true;
                pbUser.FederationIdentifier = pbContact.EmployeeNumber__c;
                pbUser.Cost_Center__c = pbContact.ES_DJC_Cost_Center__c;
                pbUser.Business_Unit__c = pbContact.ES_DJC_Business_Unit__c;
                pbUser.Title = pbContact.Title;
                pbUser.Primary_Coverage_Country_PCC__c = pbContact.Primary_Country_of_Coverage_PCC__c;
                pbUser.LocaleSidKey = settings.Preboarding_LocaleSidKey__c;
                pbUser.LanguageLocaleKey = settings.Preboarding_LanguageLocaleKey__c;
                pbUser.TimeZoneSidKey = settings.Preboarding_TimeZoneSidKey__c;
                pbUser.EmailEncodingKey = settings.Preboarding_EmailEncodingKey__c;
                newUsers.add(pbUser);
            }
            catch (Exception e) {
                System.debug('An Exception Occured: '+ e.getMessage()+ '\n'+ e.getStackTraceString());
            }
        }
    }
    
    
    public void createUserforRehires(List<User> existingEmpPortalUsers,List<User> newUsers) {
        for(User pfUser : existingEmpPortalUsers){
            try{
                pfUser.ContactId = empNo2ContactIdMap.get(pfUser.EmployeeNumber);
                pfUser.CommunityNickname = ESDJC_Util.getNickname(8);
                if(empNo2ContactMap.get(pfUser.EmployeeNumber).Start_Date__c!= NULL && Date.today().daysBetween(empNo2ContactMap.get(pfUser.EmployeeNumber).Start_Date__c) <= 1){
                    pfUser.profileId = employeeProfileID;
                    pfUser.Email = empNo2ContactMap.get(pfUser.EmployeeNumber).Email;
                }
                else{
                    pfUser.profileId = preboardingProfileId;
                    string personalEmail = empNo2ContactMap.get(pfUser.EmployeeNumber).Secondary_Email__c;
                    if(String.isBlank(personalEmail)) {
                        pfUser.Email = empNo2WContactMap.get(pfUser.EmployeeNumber).Email;
                    } else {
                        pfUser.Email = personalEmail;
                    }
                }
                pfUser.IsActive = true;
                pfUser.UserPermissionsChatterAnswersUser = true;
                pfUser.FederationIdentifier = pfUser.EmployeeNumber;
                pfUser.Division = empNo2ContactMap.get(pfUser.EmployeeNumber).Division__c;
                pfUser.Cost_Center__c = empNo2ContactMap.get(pfUser.EmployeeNumber).ES_DJC_Cost_Center__c;
                pfUser.Business_Unit__c = empNo2ContactMap.get(pfUser.EmployeeNumber).ES_DJC_Business_Unit__c;
                pfUser.Title = empNo2ContactMap.get(pfUser.EmployeeNumber).Title;
                pfUser.Primary_Coverage_Country_PCC__c = empNo2ContactMap.get(pfUser.EmployeeNumber).Primary_Country_of_Coverage_PCC__c;
                newUsers.add(pfUser);
            }
            catch (Exception e) {
                System.debug('An Exception Occured: '+ e.getMessage()+ '\n'+ e.getStackTraceString());
            }
        }
        
    }
    
    public void reactivatePreboardingPortalUsers(List<User> newUsers) {
        List<user> preboardingUsers = [SELECT Username, Division, ContactId, Email, Name,FirstName, LastName, Alias, CommunityNickname, 
                                       languagelocalekey,localesidkey, timeZoneSidKey, emailEncodingKey , CurrencyIsoCode , IsActive, 
                                       EmployeeNumber, FullPhotoUrl, UserPermissionsChatterAnswersUser FROM User where ContactId in: newEmployeeContact and profile.id =:preboardingProfileId];
        System.debug('preboardingUsers-->'+preboardingUsers.size());
        System.debug(newEmployeeContact);
        if(preboardingUsers.size()> 0){
            for(USER u : preboardingUsers){
                newEmployeeContact.remove(u.ContactId);
                if(!u.IsActive) {
                    u.IsActive = TRUE;
                    newUsers.add(u);
                }
            }
        }
    }
    
    
    public void populateSetOfNewContacts(List<User> existingEmpPortalUsers) {
        //Create set of employee query returned. So that we can compare with Employee Numbers of the contact. 
        Set<String> setOfExistingEmpPortalUsersEmpNo = new Set<String>();
        for(User usr: existingEmpPortalUsers){
            setOfExistingEmpPortalUsersEmpNo.add(usr.EmployeeNumber);
        }
        
        for(String contactEmpNumber: empNo2ContactIdMap.keySet()){
            if(!setOfExistingEmpPortalUsersEmpNo.contains(contactEmpNumber)){
                /* Creating a set of Contact ID, for which there's no existing employee portal user present */
                newEmployeeContact.add(empNo2ContactIdMap.get(contactEmpNumber));
            }
        }
    }
    
    
    public void filterContacts(Contact aContact) {
        /*Exclude contacts where business units defined in custom settings */
        if( (aContact.ES_DJC_Business_Unit__c == null) || (businessUnitsSet==null) ||  (aContact.ES_DJC_Business_Unit__c!=null &&  !businessUnitsSet.contains(aContact.ES_DJC_Business_Unit__c))){
            if (
                aContact.EmployeeNumber__c!=null &&
                aContact.EmployeeNumber__c.isNumeric() &&
                !aContact.EmployeeNumber__c.startsWith('00000%')
            ){
                employeeConMap.put(aContact.id,aContact);
                empNo2ContactIdMap.put(aContact.EmployeeNumber__c, aContact.Id);
                empNo2ContactMap.put(aContact.EmployeeNumber__c, aContact);
            }else{
                //Add error message to Contact Record Status is Employee NUmber does not exist
                aContact.ES_DJC_Record_Status__c = EMPLOYEE_NUMBER_ERROR;
                empNo2ContactMap.put(aContact.EmployeeNumber__c, aContact);
                batchStatus = 'Failure';
                errorMessage += CONTACT_STRING + aContact.Name + ' -- ' + aContact.EmployeeNumber__c + RECORD_PROCESSING_STRING+ EMPLOYEE_NUMBER_ERROR+ '\n';
            }
        }else{
            aContact.ES_DJC_Record_Status__c = EMPLOYEE_BUSINESSUNIT_ERROR;
            empNo2ContactMap.put(aContact.EmployeeNumber__c, aContact);
            batchStatus = 'Failure';
            errorMessage += CONTACT_STRING + aContact.Name + ' -- ' + aContact.EmployeeNumber__c + RECORD_PROCESSING_STRING+ EMPLOYEE_BUSINESSUNIT_ERROR+ '\n';
        }		
    }
    
}