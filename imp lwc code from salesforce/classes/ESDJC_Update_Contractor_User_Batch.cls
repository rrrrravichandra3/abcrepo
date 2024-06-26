global class ESDJC_Update_Contractor_User_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	private ESDJC_Integration_Log__c log;
    private ESDJC_Settings__c settings;
    
    private String batchStatus {get;set;}
    global static String SUCCESS_MESSAGE = 'Updated - Completed';
    global static String ERROR_MESSAGE = 'ERROR: ';
    private Id empRecordTypeId;
    public String errorMessage = '';
    Map<id, Contact> id2ContactMap = new Map<id, Contact>();
    
    public ESDJC_Update_Contractor_User_Batch(ESDJC_Integration_Log__c log) {
        System.debug('+++ESDJC_Update_Contractor_User_Batch constructor log='+log);
        List<RecordType> recTypes = [SELECT ID,DEVELOPERNAME,NAME FROM RECORDTYPE WHERE DEVELOPERNAME='Contractor' AND SOBJECTTYPE='Contact'];
        if(recTypes!=null && recTypes.size()>0){
          empRecordTypeId = recTypes[0].Id;
        }
        this.log = log;
        settings = ESDJC_Settings__c.getInstance();
        batchStatus = 'Success';
        log.DJC_Update_Contractor_Batch_Start_Time__c = DateTime.now();
        log.DJC_Update_Contractor_Job_Status__c = 'In Progress';
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, ES_DJC_Is_Manager__c,Division__c, Email,FirstName, LastName, Status__c , EmployeeNumber__c, Title,ES_DJC_Business_Unit__c, 
                                        ES_DJC_Cost_Center__c, Primary_Country_of_Coverage_PCC__c FROM Contact WHERE ES_DJC_Record_Status__c = 'Updated' AND RecordTypeId=:empRecordTypeId]);
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
        System.debug('+++ESDJC_Update_User_Batch execute');
        Map<String, String> empNo2resultMap = new Map<String, String>();
        Map<String, String> userId2empNoMap = new Map<String, String>();
        List<Database.SaveResult> saveResults;
        Database.SaveResult result;
        Contact aContact;   
        for(Sobject s : scope){
            aContact = (Contact) s;
            id2ContactMap.put(aContact.id, aContact);
        }   
        
        List<User> djcUsers = [SELECT Division, Email,FirstName, LastName, IsActive, EmployeeNumber, Title,Business_Unit__c, Cost_Center__c, Contactid,
                                Primary_Coverage_Country_PCC__c, UserName FROM User WHERE contactid IN:id2ContactMap.keySet() AND ProfileId=: settings.Portal_User_Profile_Id__c];
        
        List<User> usersToBeUpdated = new List<User>();
        
        if(Schema.Sobjecttype.User.isUpdateable()){
            boolean isAnythingChanged;
            for(User djcUser : djcUsers){
                isAnythingChanged = false;
                aContact = id2ContactMap.get(djcUser.Contactid);      

                if(aContact.Status__c != null && aContact.Status__c != 'Active' && djcUser.IsActive == true){
                    isAnythingChanged = true;
                }       
                if(aContact.Status__c != null && aContact.Status__c == 'Active' && djcUser.IsActive != true){
                    isAnythingChanged = true;
                }       
                if(aContact.Status__c != null && aContact.Status__c != null && aContact.Status__c == 'Active'){
                        djcUser.IsActive = true;
                } else {
                        djcUser.IsActive = false;
                }
                
                if(aContact.Division__c != null && djcUser.Division != aContact.Division__c){
                    djcUser.Division = aContact.Division__c;
                    isAnythingChanged = true;
                }
                
                if(aContact.Email != null && djcUser.Email != aContact.Email){
                    isAnythingChanged = true;
                    djcUser.Email = aContact.Email;

                    //If Contact Email is updated, User Name needs to updagted. Ref: W-3271414 : Portal Username and email address mismatch in Peopleforce
                    if(aContact.Email != null){
                        String DJC_ORG = '@'+settings.SSO_Dreamjobcentral_ID__c;
                        List<String> contactEmailTokens = aContact.Email.split('@');
                        djcUser.userName = contactEmailTokens[0]+ DJC_ORG;
                    }
                }
                
                if(aContact.FirstName != null && djcUser.FirstName != aContact.FirstName) {
                    isAnythingChanged = true;
                    djcUser.FirstName = aContact.FirstName;
                }
                
                if(aContact.LastName != null && djcUser.LastName != aContact.LastName) {
                    isAnythingChanged = true;
                    djcUser.LastName = aContact.LastName;
                }
                
                if(aContact.EmployeeNumber__c != null && djcUser.EmployeeNumber != aContact.EmployeeNumber__c){
                    isAnythingChanged = true;
                    djcUser.EmployeeNumber = aContact.EmployeeNumber__c;
                }
                
                if(aContact.Title != null && djcUser.Title != aContact.Title){
                    isAnythingChanged = true;
                    djcUser.Title = aContact.Title;
                }
                if(aContact.ES_DJC_Business_Unit__c != null && djcUser.Business_Unit__c != aContact.ES_DJC_Business_Unit__c){
                    isAnythingChanged = true;
                    djcUser.Business_Unit__c = aContact.ES_DJC_Business_Unit__c;
                }
                
                if(aContact.ES_DJC_Cost_Center__c != null && djcUser.Cost_Center__c != aContact.ES_DJC_Cost_Center__c){
                    isAnythingChanged = true;
                    djcUser.Cost_Center__c = aContact.ES_DJC_Cost_Center__c;
                }
                if(aContact.Primary_Country_of_Coverage_PCC__c != null && djcUser.Primary_Coverage_Country_PCC__c != aContact.Primary_Country_of_Coverage_PCC__c){
                    isAnythingChanged = true;
                    djcUser.Primary_Coverage_Country_PCC__c = aContact.Primary_Country_of_Coverage_PCC__c;
                }
                userId2empNoMap.put(djcUser.Id, djcUser.EmployeeNumber);
                if(isAnythingChanged){
                    usersToBeUpdated.add(djcUser);
                }
            }
            
            System.debug('+++ESDJC_Update_User_Batch execute usersToBeUpdated size = '+usersToBeUpdated.size());
            saveResults = Database.update(usersToBeUpdated,false);
    
            //-------------Process user update result -------------------       
            User aUser;
            for(Integer i=0;i<saveResults.size();i++){
                result = saveResults.get(i);
                aUser = djcUsers.get(i);
                aContact =  id2ContactMap.get(aUser.contactid);
                if(result.success){
                    //empNo2resultMap.put(aUser.EmployeeNumber, SUCCESS_MESSAGE);
                    aContact.ES_DJC_Record_Status__c = SUCCESS_MESSAGE;
                } else {
                    batchStatus = 'Failure';
                    //empNo2resultMap.put(aUser.EmployeeNumber, result.getErrors()[0].getMessage()); 
                    String errorMessageHere = ERROR_MESSAGE+result.getErrors()[0].getMessage();	
                    aContact.ES_DJC_Record_Status__c = errorMessageHere.length()> 255 ? errorMessageHere.substring(0,255) : errorMessageHere;
                    errorMessage += 'Contact : ' + aContact.Name + ' -- ' + aContact.EmployeeNumber__c + ' record processing Failed with message : '+ aContact.ES_DJC_Record_Status__c+ '\n';
                }
            }
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update User');
            errorMessage += 'Record processing Failed with message : User does not have user record update privilages.';
        }
   }
 
    
   global void finish(Database.BatchableContext BC){ 
        if(Schema.Sobjecttype.Contact.isUpdateable()){
            try{
                Database.update (id2ContactMap.values(), false);
            }catch(Exception ex){
                batchStatus = 'Failure';
                errorMessage += 'Record processing Failed with message : '+ (ex.getMessage().length()> 255 ? ex.getMessage().substring(0,255) : ex.getMessage()) + '\n';
            }
        }else{
            batchStatus = 'Failure';
            errorMessage += 'Record processing Failed with message :  User does not have access to update Contacts.\n';
        }
        if(Schema.Sobjecttype.ESDJC_Integration_Log__c.isUpdateable()){
            log.DJC_Update_Contractor_Batch_Finish_Time__c = DateTime.now();
            log.DJC_Update_Contractor_Job_Status__c = batchStatus;
            
            String[] bodyLines =  new String[] {
                'ESDJC Integration Log Id: '+ log.Id,
                'ESDJC Integration Log Name: '+ log.Name,
                '\n',
                'Integration Start Time: '+log.Integration_Start_Time__c,
                'Integration Finish Time: '+log.Integration_Finish_Time__c,
                'Integration Status: '+log.Integration_Status__c,
                '\n',
                'DJC Update Contractor Batch Job Start Time: '+ log.DJC_Update_Contractor_Batch_Start_Time__c,
                'DJC Update Contractor Batch Job Finish Time: '+log.DJC_Update_Contractor_Batch_Finish_Time__c,
                'DJC Update Contractor Batch Job Status: '+log.DJC_Update_Contractor_Job_Status__c,
                '\n ************* If batch is failed, Please check following message for Records and corresponding errors:\n',
                errorMessage
            };
    
            ESDJC_Util.sendStatusEmail(BC, 'ESDJC Update Contractor Batch: '+log.Name, new String[] {settings.Batch_Job_Report_Email__c}, bodyLines);     
            update log;
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update ESDJC_Integration_Log__c');
        }

   }
}