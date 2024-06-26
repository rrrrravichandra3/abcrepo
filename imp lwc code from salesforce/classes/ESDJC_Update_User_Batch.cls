@SuppressWarnings('PMD.ExcessiveParameterList')
global class  ESDJC_Update_User_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private ESDJC_Integration_Log__c log;
    private ESDJC_Settings__c settings;
    private String batchStatus {get;set;}
    global static String SUCCESS_MESSAGE = 'Updated - Completed';
    global static String ERROR_MESSAGE = 'ERROR: ';
    global static String UPDATED_STATUS = 'Updated';
    public static String  EMPLOYEE_NUMBER_ERROR = ERROR_MESSAGE + ' - User update failed. Employee Number is empty or not a numeric';
    public static String  EMPLOYEE_USER_NOT_MATCHING_ERROR = ERROR_MESSAGE + ' - User update failed. Contact\'s employee number is not found in User table.' ;
    public Static String CONTACT_STRING = 'Contact : ';
    public static String ERROR_MSG2 = ' record processing Failed with message : ';
    private Id empRecordTypeId;
    public String errorMessage = '';
    Map<String, Contact> empNo2ContactMap = new Map<String, Contact>();
    Map<String, String> userId2empNoMap = new Map<String, String>();
    Set<Id> afterAndDay1Contacts = new Set<Id>();
    Map<Id,User> usersToBeUpdatedIdToUser = new Map<Id,User>();
    List<Contact> processedContacts = new List<Contact>();
    Map<String, Integer> jobGradeMap = new Map<String, Integer>();
    public ESDJC_Update_User_Batch(ESDJC_Integration_Log__c log) {
        System.debug('+++ESDJC_Update_User_Batch constructor log='+log);
        List<RecordType> recTypes = [SELECT ID,DEVELOPERNAME,NAME FROM RECORDTYPE WHERE DEVELOPERNAME='EMPLOYEE' AND SOBJECTTYPE='Contact'];
        if(recTypes!=null && recTypes.size()>0){
          empRecordTypeId = recTypes[0].Id;
        }
        this.log = log;
        settings = ESDJC_Settings__c.getInstance();
        batchStatus = 'Success';
        log.DJC_Update_User_Batch_Job_Start_Time__c = DateTime.now();
        log.DJC_Update_User_Job_Status__c = 'In Progress';
        jobGradeMap.put('COMP_GRADE_11', 11);
        jobGradeMap.put('COMP_GRADE_12', 12);
        jobGradeMap.put('COMP_GRADE_13', 13);
        jobGradeMap.put('COMP_GRADE_14', 14);
   }

   global Database.QueryLocator start(Database.BatchableContext bC){
        System.debug('+++ESDJC_Update_User_Batch start');
        Decimal updateUserBatchRecordLimit = 10000;
        if (settings.Update_User_Batch_Record_Limit__c != null){
           updateUserBatchRecordLimit = settings.Update_User_Batch_Record_Limit__c;
        }
        DateTime cutoffDate = DateTime.valueOf(settings.Phoenix_ESDJC_Batch_Cutoff_Date__c);
        return Database.getQueryLocator([SELECT Id,  Name, ES_DJC_Record_Status__c, ES_DJC_Is_Manager__c,Division__c, Email,FirstName, LastName, Status__c, EmployeeNumber__c, ES_DJC_Grade__c,
                                        Title, ES_DJC_Business_Unit__c, ES_DJC_Cost_Center__c,Start_Date__c,Secondary_Email__c,Employment_Type__c,Futureforce__c FROM Contact WHERE ES_DJC_Record_Status__c In ('Updated','New - Completed') 
                                        AND RecordTypeId=:empRecordTypeId and LastModifiedDate > :cutoffDate order by LastModifiedDate asc limit :Integer.valueOf(updateUserBatchRecordLimit)]);
   }

   global void execute(Database.BatchableContext bC,  List<sObject> scope){
        System.debug('+++ESDJC_Update_User_Batch execute');
        List<Database.SaveResult> saveResults;
        Database.SaveResult result;
        Contact aContact;

        for(Sobject s : scope){
            aContact = (Contact) s;
            filterContacts(aContact);
            processedContacts.add(aContact);
        }

        Map<Id,User> portalUsers = new Map<ID, User>([SELECT Division, Email,FirstName, LastName, IsActive, EmployeeNumber, Title,Business_Unit__c, Cost_Center__c, 
                                UserName,Start_Date__c,profileId FROM User WHERE EmployeeNumber IN:empNo2ContactMap.keySet() and IsPortalEnabled = true]);
        
        filterNoUserContacts(portalUsers.values());                        


        for(Contact c:empNo2ContactMap.values()) {
            if(c.Start_Date__c <= Date.Today().addDays(1)) {
               afterAndDay1Contacts.add(c.Id);
            }
        }
        if(Schema.Sobjecttype.User.isUpdateable()){
            processContacts(portalUsers.values(),aContact);
            System.debug('+++ESDJC_Update_User_Batch execute usersToBeUpdated size = '+usersToBeUpdatedIdToUser.values().size());
            saveResults = Database.update(usersToBeUpdatedIdToUser.values(),false);
            //-------------Process user update result -------------------       
            processUpdateResults(saveResults,result,portalUsers.values(),aContact);

        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update User');
        }
        if(!Schema.Sobjecttype.PermissionSetAssignment.isCreateable()){
            ESDJC_Util.displayAccessPrivilegeError('Create PermissionSetAssignment');
            errorMessage += 'Record status update failed with following error message : User started the batch do not have previlage to update the PermissionSetAssignment\n';
            return;
        }

        handlePermissionSetAssignment(portalUsers);
                   
   }

   private String getKey(PermissionSetAssignment perm) {
        return perm.AssigneeId+''+perm.PermissionSetId;
   }

   public void updateContactStatus(Contact aContactForStatus) {
        if( aContactForStatus.ES_DJC_Record_Status__c == SUCCESS_MESSAGE && !afterAndDay1Contacts.contains(aContactForStatus.Id)){ //if contact status is "updated-completed" but it is before their Start Date, then keep the status as "Updated"
            aContactForStatus.ES_DJC_Record_Status__c = UPDATED_STATUS;
        }
   }


   global void finish(Database.BatchableContext bC){
        if(Schema.Sobjecttype.Contact.isUpdateable()){
            try{
                for(Contact aContactForStatus : processedContacts){
                    updateContactStatus(aContactForStatus);
                }
                update processedContacts;
                System.debug('processedContacts in finish method  --->'+processedContacts);

            }catch(Exception ex){
                batchStatus = 'Failure';
                errorMessage += 'Record processing Failed with message : '+ (ex.getMessage().length()> 255 ? ex.getMessage().substring(0,255) : ex.getMessage()) + '\n';
            }
        }else{
            batchStatus = 'Failure';
            errorMessage += 'Record processing Failed with message :  User does not have access to update Contacts.\n';
        }

        if(Schema.Sobjecttype.ESDJC_Integration_Log__c.isUpdateable()){
            log.DJC_Update_User_Batch_Job_Finish_Time__c = DateTime.now();
            log.DJC_Update_User_Job_Status__c = batchStatus;

            String[] bodyLines =  new String[] {
                'ESDJC Integration Log Id: '+ log.Id,
                'ESDJC Integration Log Name: '+ log.Name,
                '\n',
                'Integration Start Time: '+log.Integration_Start_Time__c,
                'Integration Finish Time: '+log.Integration_Finish_Time__c,
                'Integration Status: '+log.Integration_Status__c,
                '\n',
                'DJC Update User Batch Job Start Time: '+ log.DJC_Update_User_Batch_Job_Start_Time__c,
                'DJC Update User Batch Job Finish Time: '+log.DJC_Update_User_Batch_Job_Finish_Time__c,
                'DJC Update User Batch Job Status: '+log.DJC_Update_User_Job_Status__c,
                '\n ************* If batch is failed, Please check following message for Records and corresponding errors:\n',
                errorMessage
            };
            ESDJC_Util.sendStatusEmail(BC, 'ESDJC Update User Batch: '+log.Name, new String[] {settings.Batch_Job_Report_Email__c}, bodyLines);     
            update log;
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update ESDJC_Integration_Log__c');
        }
   }


    public void removeRegionalPermSets(User updateUser,Map<String, PermissionSetAssignment> uidpid2PermissionSetAssignmentIdMap, List<PermissionSetAssignment> deletePermSetAssignment) {
        List<String> regionalPermSetIds = new List<String>{settings.Portal_User_Amer_Permset_Id__c,settings.Portal_User_Apac_Permset_Id__c,settings.Portal_User_Japan_Permset_Id__c,settings.Portal_User_Emea_Permset_Id__c};
        for(String region: regionalPermSetIds) {
            PermissionSetAssignment permSet = new PermissionSetAssignment();
            permSet.AssigneeId = updateUser.Id;
            permSet.PermissionSetId = region;
            if(uidpid2PermissionSetAssignmentIdMap.get(getKey(permSet)) != null){
                deletePermSetAssignment.add(uidpid2PermissionSetAssignmentIdMap.get(getKey(permSet)));
            }
        }
    }


   public void addRegionalPermSet(User updateUser,Map<String, PermissionSetAssignment> uidpid2PermissionSetAssignmentIdMap,List<PermissionSetAssignment> addPermSetAssignment) {
            PermissionSetAssignment permSet = new PermissionSetAssignment();
            permSet.AssigneeId = updateUser.Id;
            if(ESDJC_Util.getRegionFromDivision(updateUser.Division) == ESDJC_Util.REGION_AMER || ESDJC_Util.getRegionFromDivision(updateUser.Division) == ESDJC_Util.REGION_LACA){
                permSet.PermissionSetId = settings.Portal_User_Amer_Permset_Id__c;
            } else if(ESDJC_Util.getRegionFromDivision(updateUser.Division) == ESDJC_Util.REGION_EMEA){
                permSet.PermissionSetId = settings.Portal_User_Emea_Permset_Id__c;
            } else if(ESDJC_Util.getRegionFromDivision(updateUser.Division) == ESDJC_Util.REGION_APAC){
                permSet.PermissionSetId = settings.Portal_User_Apac_Permset_Id__c;  
            } else if(ESDJC_Util.getRegionFromDivision(updateUser.Division) == ESDJC_Util.REGION_JAPAN){
                permSet.PermissionSetId = settings.Portal_User_Japan_Permset_Id__c; 
            }
            if(uidpid2PermissionSetAssignmentIdMap.get(getKey(permSet)) == null){
                addPermSetAssignment.add(permSet);
            }
   }
    

    private Boolean getIsInternOutsideAMER(User updateUser){
        return ( empNo2ContactMap.get(updateUser.EmployeeNumber).Employment_Type__c == 'Intern (Fixed Term)' 
            && empNo2ContactMap.get(updateUser.EmployeeNumber).Futureforce__c == true 
            && empNo2ContactMap.get(updateUser.EmployeeNumber).Division__c != 'Americas - USA');
    }

    public void handlePermSetAssignmentForAfterStartDate(User updateUser, Map<String, PermissionSetAssignment> uidpid2PermissionSetAssignmentIdMap,List<PermissionSetAssignment> addPermSetAssignment, List<PermissionSetAssignment> deletePermSetAssignment,PermissionSetAssignment managerPerm ) {
        removeRegionalPermSets(updateUser, uidpid2PermissionSetAssignmentIdMap, deletePermSetAssignment);
        addRegionalPermSet(updateUser,uidpid2PermissionSetAssignmentIdMap,addPermSetAssignment);

        //promoted to Manager
        if(empNo2ContactMap.get(updateUser.EmployeeNumber).ES_DJC_Is_Manager__c == true && uidpid2PermissionSetAssignmentIdMap.get(getKey(managerPerm)) == null) {
            addPermSetAssignment.add(managerPerm);
        }
        //demoted from Manager
        if(empNo2ContactMap.get(updateUser.EmployeeNumber).ES_DJC_Is_Manager__c != true && uidpid2PermissionSetAssignmentIdMap.get(getKey(managerPerm)) != null) {
            deletePermSetAssignment.add(uidpid2PermissionSetAssignmentIdMap.get(getKey(managerPerm)));
        }
        updatePreboardingPermSet(updateUser,uidpid2PermissionSetAssignmentIdMap,addPermSetAssignment,deletePermSetAssignment,true);
    }
    
    public void handlePermSetAssignmentForBeforeStartDate(User updateUser, Map<String, PermissionSetAssignment> uidpid2PermissionSetAssignmentIdMap,List<PermissionSetAssignment> addPermSetAssignment, List<PermissionSetAssignment> deletePermSetAssignment,PermissionSetAssignment managerPerm ) {
        removeRegionalPermSets(updateUser, uidpid2PermissionSetAssignmentIdMap, deletePermSetAssignment);
        if(uidpid2PermissionSetAssignmentIdMap.get(getKey(managerPerm)) != null) {
            deletePermSetAssignment.add(uidpid2PermissionSetAssignmentIdMap.get(getKey(managerPerm)));
        }
        if(jobGradeMap.get(empNo2ContactMap.get(updateUser.EmployeeNumber).ES_DJC_Grade__c) >= 11
        || getIsInternOutsideAMER(updateUser)) {
            updatePreboardingPermSet(updateUser,uidpid2PermissionSetAssignmentIdMap,addPermSetAssignment,deletePermSetAssignment,true);           
        } else {
            updatePreboardingPermSet(updateUser,uidpid2PermissionSetAssignmentIdMap,addPermSetAssignment,deletePermSetAssignment,false);           
        }
    }


   public void handlePermissionSetAssignment(Map<Id,User> portalUsers) {
    //-------------Updates Permission Sets -------------------   
    List<PermissionSetAssignment> permSetAssignments = [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :portalUsers.keySet()];
    Map<String, PermissionSetAssignment> uidpid2PermissionSetAssignmentIdMap= new Map<String, PermissionSetAssignment>();
    for(PermissionSetAssignment perm : permSetAssignments){
        uidpid2PermissionSetAssignmentIdMap.put(getKey(perm), perm);
    }

    List<PermissionSetAssignment> addPermSetAssignment = new List<PermissionSetAssignment>();
    List<PermissionSetAssignment> deletePermSetAssignment = new List<PermissionSetAssignment>();
    PermissionSetAssignment managerPerm;
    for(User updateUser: portalUsers.values()){
        managerPerm = new PermissionSetAssignment();
        managerPerm.AssigneeId = updateUser.Id;
        managerPerm.PermissionSetId = settings.Portal_User_Manager_Permset_Id__c;   
        if(afterAndDay1Contacts.contains(empNo2ContactMap.get(updateUser.EmployeeNumber).Id) ) { //Project Phonenix Change - Update regional & Manager Perm set if contact is on/past their Start Date.
            handlePermSetAssignmentForAfterStartDate(updateUser,uidpid2PermissionSetAssignmentIdMap,addPermSetAssignment,deletePermSetAssignment,managerPerm);
        } else { //Project Phonenix Change - Update regional & Manager Perm set if contact is before their Start Date.
            handlePermSetAssignmentForBeforeStartDate(updateUser,uidpid2PermissionSetAssignmentIdMap,addPermSetAssignment,deletePermSetAssignment,managerPerm);
        }
        
    }
    System.debug(addPermSetAssignment);
    deletePermSets(deletePermSetAssignment);
    System.debug(Database.insert(addPermSetAssignment,false));
   }

   public void updatePreboardingPermSet(User updateUser, Map<String, PermissionSetAssignment> uidpid2PermissionSetAssignmentIdMap,List<PermissionSetAssignment> addPermSetAssignment, List<PermissionSetAssignment> deletePermSetAssignment, boolean remove) {
     //Project Phonenix Change - Remove Preboarding Perm set if contact is on/past their Start Date.
     PermissionSetAssignment preboardingPermSet = new PermissionSetAssignment();
     preboardingPermSet.AssigneeId = updateUser.Id;
     preboardingPermSet.PermissionSetId = settings.Preboarding_Comm_Permset_Id__c;
     if(remove == true && uidpid2PermissionSetAssignmentIdMap.get(getKey(preboardingPermSet)) != null) {
         deletePermSetAssignment.add(uidpid2PermissionSetAssignmentIdMap.get(getKey(preboardingPermSet)));
                         System.debug('here');

     }
     if(remove == false && uidpid2PermissionSetAssignmentIdMap.get(getKey(preboardingPermSet)) == null) {
         addPermSetAssignment.add(preboardingPermSet);
     }
   }


   public void deletePermSets(List<PermissionSetAssignment> deletePermSetAssignment) {
    if(!Schema.Sobjecttype.PermissionSetAssignment.isDeletable()){
        ESDJC_Util.displayAccessPrivilegeError('Delete PermissionSetAssignment');
        errorMessage += 'Record status delete failed with following error message : User started the batch do not have previlage to update the PermissionSetAssignment\n';
        return;
    }
    System.debug(deletePermSetAssignment);
    System.debug(Database.delete(deletePermSetAssignment,false));
       
                            
   }


   public void processUpdateResults(List<Database.SaveResult> saveResults, Database.SaveResult result,List<User> portalUsers,Contact aContact) {
    User aUser;
    for(Integer i=0;i<saveResults.size();i++){
        try {
            result = saveResults.get(i);
            aUser = usersToBeUpdatedIdToUser.get(result.getId());
            aContact =  empNo2ContactMap.get(aUser.EmployeeNumber);
            if(result.success){
                aContact.ES_DJC_Record_Status__c = SUCCESS_MESSAGE;
                System.debug('acontact in processUpdateResults   --->'+aContact);
            } else {
                batchStatus = 'Failure'; 
                usersToBeUpdatedIdToUser.remove(aUser.Id);
                String errorMessageHere = ERROR_MESSAGE+result.getErrors()[0].getMessage(); 
                aContact.ES_DJC_Record_Status__c = errorMessageHere.length() > 255 ? errorMessageHere.substring(0, 255) : errorMessageHere;
                errorMessage += CONTACT_STRING + aContact.Name + ' -- ' + aContact.EmployeeNumber__c + ERROR_MSG2+ aContact.ES_DJC_Record_Status__c+ '\n';
            }
        } catch (Exception e) {
            System.debug('An Exception Occured: '+ e.getMessage()+ '\n'+ e.getStackTraceString());
        }
    }    
   }




   public Boolean divisionChange(Contact aContact,User djcUser) {

    if(aContact.Division__c != null && djcUser.Division != aContact.Division__c){
        djcUser.Division = aContact.Division__c;
        return true;
    }
     return false;
    }
   
    private string getUsername(String email) {
        string username;
        if(email != null) {
            String djcORG = '@'+settings.SSO_Dreamjobcentral_ID__c;
            List<String> contactEmailTokens = email.split('@');
            username = contactEmailTokens[0]+ djcORG;
        }
        return username;
    }

    public Boolean emailChange(Contact aContact,User djcUser ) {
        if(!String.isBlank(aContact.Email) && djcUser.Email != aContact.Email && afterAndDay1Contacts.contains(aContact.Id)){  //Project Phoenix Change - update email from Contact -> User when Contact is on or past their Start date
            djcUser.Email = aContact.Email;
            djcUser.userName = getUsername(aContact.Email);
            return true;
        } else if (!String.isBlank(aContact.Secondary_Email__c) && djcUser.Email != aContact.Secondary_Email__c && !afterAndDay1Contacts.contains(aContact.Id)) {
            djcUser.Email = aContact.Secondary_Email__c;
            djcUser.userName = getUsername(aContact.Secondary_Email__c);
            return true;
        }
      return false;
    }   


   public Boolean statusChange(Contact aContact,User djcUser) {
        Boolean isAnythingChanged = false;
        if(aContact.Status__c != null && aContact.Status__c != 'Active' && djcUser.IsActive == true){
            isAnythingChanged = true;
        }  
        if(aContact.Status__c != null && aContact.Status__c == 'Active' && djcUser.IsActive != true){
            isAnythingChanged = true;
        }       
        if(aContact.Status__c != null && aContact.Status__c == 'Active'){
            djcUser.IsActive = true;
        } else {
            djcUser.IsActive = false;
        }
        return isAnythingChanged;
   }



   public Boolean firstNameChange(Contact aContact,User djcUser ) {
    if(aContact.FirstName != null && djcUser.FirstName != aContact.FirstName) {
        djcUser.FirstName = aContact.FirstName;
        return true;
    }
    return false;
    }  

    public Boolean lastNameChange(Contact aContact,User djcUser ) {
        if(aContact.LastName != null && djcUser.LastName != aContact.LastName) {
            djcUser.LastName = aContact.LastName;
            return true;
         }
         return false;
    }  
    
    public Boolean empNoChange(Contact aContact,User djcUser) {
        if(aContact.EmployeeNumber__c != null && djcUser.EmployeeNumber != aContact.EmployeeNumber__c){
            djcUser.EmployeeNumber = aContact.EmployeeNumber__c;
            return true;
        }
        return false;
    }  


    public Boolean titleChange(Contact aContact,User djcUser ) {
        if(aContact.Title != null && djcUser.Title != aContact.Title){
            djcUser.Title = aContact.Title;
            return true;
        }
        return false;
    } 

    public boolean profileChange(Contact aContact, User djcUser) {

        //project phonexix change - on day 1 change profile to Employee Portal
        //if before day 1 - & profile is employee change it to preboarding portal profile
        if(afterAndDay1Contacts.contains(aContact.Id) && djcUser.ProfileId ==  settings.Preboarding_ProfileId__c) {
            djcUser.ProfileId = settings.Portal_User_Profile_Id__c;
            return true;    
        }                
        if(!afterAndDay1Contacts.contains(aContact.Id) && djcUser.ProfileId ==  settings.Portal_User_Profile_Id__c) {
            djcUser.ProfileId = settings.Preboarding_ProfileId__c;
            return true;                    
        }
            
        return false;
    }

   public void processContacts(List<User> portalUsers,Contact aContact) {
    boolean isAnythingChanged;
    for(User djcUser : portalUsers){
        try {
            isAnythingChanged = false;
            aContact = empNo2ContactMap.get(djcUser.EmployeeNumber);      
        
            boolean statusChanged = statusChange(aContact,djcUser);
            boolean divisionChanged = divisionChange(aContact, djcUser);
            
            boolean emailChanged = emailChange(aContact, djcUser);

            boolean fNChanged = firstNameChange(aContact, djcUser);

            boolean lNChanged = lastNameChange(aContact, djcUser);

            boolean empNoChanged = empNoChange(aContact, djcUser);

            boolean titleChanged = titleChange(aContact, djcUser);

            boolean profileChanged = profileChange(aContact, djcUser);

            if(emailChanged||statusChanged||fNChanged||lNChanged||empNoChanged||titleChanged||divisionChanged || profileChanged) {
                isAnythingChanged = true;
            }
            

            if(aContact.ES_DJC_Business_Unit__c != null && djcUser.Business_Unit__c != aContact.ES_DJC_Business_Unit__c){
                isAnythingChanged = true;
                djcUser.Business_Unit__c = aContact.ES_DJC_Business_Unit__c;
            }
            if(aContact.ES_DJC_Cost_Center__c != null && djcUser.Cost_Center__c != aContact.ES_DJC_Cost_Center__c){
                isAnythingChanged = true;
                djcUser.Cost_Center__c = aContact.ES_DJC_Cost_Center__c;
            }
            userId2empNoMap.put(djcUser.Id, djcUser.EmployeeNumber);
            if(isAnythingChanged){
                usersToBeUpdatedIdToUser.put(djcUser.Id,djcUser);
            }
        } catch (Exception e) {
            System.debug('An Exception Occurred: '+ e.getMessage()+ '\n'+ e.getStackTraceString());
        } 
    }

   }


   public void filterNoUserContacts(List<User> portalUsers) {
    if(portalUsers.size() != empNo2ContactMap.size()){
        //Create set of employee query returned. So that we can compare with Employee Numbers of the contact. 
        Set<String> userEmployeeNumbers = new Set<String>();
        for(User usr: portalUsers){
            userEmployeeNumbers.add(usr.EmployeeNumber);
        }
        for(String contactEmpNumber: empNo2ContactMap.keySet()){
            if(!userEmployeeNumbers.contains(contactEmpNumber)){
                empNo2ContactMap.get(contactEmpNumber).ES_DJC_Record_Status__c = EMPLOYEE_USER_NOT_MATCHING_ERROR;
                errorMessage += CONTACT_STRING + empNo2ContactMap.get(contactEmpNumber).Id  + ERROR_MSG2+ EMPLOYEE_USER_NOT_MATCHING_ERROR+ '\n';
                //If User with Employee number does not exist then we don't need to process the contact amy more
                empNo2ContactMap.remove(contactEmpNumber);
                batchStatus = 'Failure';
            }
        }
    }
   }


   public void filterContacts(Contact aContact) {
        if ( 
            aContact.EmployeeNumber__c != null && 
            aContact.EmployeeNumber__c.isNumeric() &&
            !aContact.EmployeeNumber__c.startsWith('00000%')
         ){
            empNo2ContactMap.put(aContact.EmployeeNumber__c, aContact);
        }else{
            //Add error message to Contact Record Status is Employee NUmber does not exist
            aContact.ES_DJC_Record_Status__c = EMPLOYEE_NUMBER_ERROR;
            batchStatus = 'Failure';
            errorMessage += CONTACT_STRING + aContact.Name + ' -- ' + aContact.EmployeeNumber__c + ERROR_MSG2+ EMPLOYEE_NUMBER_ERROR+ '\n';
        }
   }


}