public with sharing class ESDJC_CaseCommentHandler {
    
    private static final ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();

    public static void updateCaseResponseFlag(List<CaseComment> comments){

        if(!UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c) && !UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c)){
            
            Set<Id> caseIds = ESDJC_CollectionHelper.getIdFieldSet(comments, 'parentId');
            ESDJC_CaseHandler.updateCaseResponseFlag(caseIds);
        }
    }
    
    /*when new case comment  comes from employee, change status to 'Re-open'*/
    public static void updateClosedCaseStatus(List<CaseComment> newRecords) {        
        if(Schema.Sobjecttype.Case.isUpdateable()){        	
            
            Set<Id> caseIds = ESDJC_CollectionHelper.getIdFieldSet(newRecords, 'parentId');
            List<Case> cases = [SELECT Id,First_Response_Flag__c,Status FROM Case WHERE id IN :caseIds and id not in :ESDJC_Util.IgnoreCaseIds and 
                                status in('Closed','Closed - Duplicate')];
            
            if(cases!=null && cases.size()>0 && portalUserInfo!=null && portalUserInfo.profile.userlicense.name.equals('Customer Portal Manager Custom')){                
                for(Case c : cases) {
                    c.status='Re-Opened';
                }                
                update cases;                  
            }
        } else {        	
            ESDJC_Util.displayAccessPrivilegeError('Update Case');
        }
    }
    
    
    public static void updateCaseStatusOnInsert(List<CaseComment> newRecords){
        
        if((Schema.Sobjecttype.Case.isUpdateable()) && (UserInfo.getProfileId()!=null) && (UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c) || UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c))){
            
            //get all question Id's
            Set<Id> caseIds = ESDJC_CollectionHelper.getIdFieldSet(newRecords, 'ParentId');
            //moving to future method because of a bug in concierge that sets the 'useAssignmentRule' header for all inserts and updates :-/
            //https://gus.my.salesforce.com/apex/adm_bugdetail?id=a07B0000001UsepIAC&sfdc.override=1
            updateCaseStatus(caseIds);            
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update Case');
        }
    }
    
    @future
    private static void updateCaseStatus(Set<id> caseIds) {
           //get all cases given question Ids
            List<Case> cases = [SELECT Id, Status, ES_DJC_Employee_Number__c, Contact.Id FROM Case WHERE Id IN :caseIds and id not in : ESDJC_Util.IgnoreCaseIds 
            					AND (Status = 'Waiting for Response' OR Status = 'In Progress')];
            
            //get the user profile so that we can get its associated contact ID
            User user = portalUserInfo;
            List<Case> casesToBeUpdated = new List<Case>();            
            
            //go through cases and update status
            for (Case cse: cases) {                                
                //ensure case is owned by the same employee sending the reply           
                if (!ESDJC_CaseHandler.stopCasecommentUpdates && ((portalUserInfo!=null && cse.Contact.Id == portalUserInfo.ContactId)
                                                                  || UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c))){
					cse.Status = 'Updated';
                	casesToBeUpdated.add(cse);
               }
            }
            
            if(casesToBeUpdated!=null && casesToBeUpdated.size()>0){
                update casesToBeUpdated;
            }
    }
    
    private static User portalUserInfo {
        get {
            if (portalUserInfo == null) {
                portalUserInfo = [SELECT Id, profile.userlicense.name, profile.name,ContactId FROM User WHERE Id = :UserInfo.getUserId()];                
            }
            return portalUserInfo;
        }
        private set;                
    }
    
    public static void updatePrivateCaseComments(Map<Id, CaseComment> newMap, Map<Id, CaseComment> oldMap) {
        
        if (!ESDJC_CaseHandler.hasPrivateCommentTriggerAlreadyRun) {
            //set the static variable to true, this ensures, update on case
            //does not insert case comment
            ESDJC_CaseHandler.hasPrivateCommentTriggerAlreadyRun = true;
            
            //create a variable to hold the list of cases to be updated
            List<Case> casesToBeUpdated = new List<Case>();
            
            Map<Id, String> caseToCaseCommentsMap = new Map<Id, String>();
            
            //Map case comments to case id, case comments are seperated by a <eom> delimiter
            for (CaseComment cc : newMap.values()) {
                if (cc.IsPublished == false) {                    
                    if (!caseToCaseCommentsMap.containsKey(cc.ParentId))
                        caseToCaseCommentsMap.put(cc.ParentId, cc.CommentBody);
                    else
                        caseToCaseCommentsMap.put(cc.ParentId, caseToCaseCommentsMap.get(cc.ParentId)+'<eom>'+cc.CommentBody);                    
                }
            }
            
            //Select only supportforce cases and update private comment field for supportforce cases
            if (!caseToCaseCommentsMap.isEmpty()) {
                for (Case c : [select Id, ESDJC_Private_Case_Comment__c from Case where Id IN :caseToCaseCommentsMap.keySet() and id not in : ESDJC_Util.IgnoreCaseIds AND ESDJC_Supportforce_Case_Number__c != null]) {
                    c.ESDJC_Private_Case_Comment__c = caseToCaseCommentsMap.get(c.Id);
                    casesToBeUpdated.add(c);
                }
                //update cases
                if (!casesToBeUpdated.isEmpty()) {
                    update casesToBeUpdated;
                }
            }
        }
    }
    
    
    public static void checkValidationsConsole(List<CaseComment> triggerNew){              
        if((!UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c)) && (!UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c))){ //only console users 
            
            List<CaseComment> publicCaseComments = new List<CaseComment>();
            Set<Id> caseIds = ESDJC_CollectionHelper.getIdFieldSet(triggerNew, 'parentId');
            String validRTSOQL = 'select id from RecordType where developername in '+ System.Label.ES_DJC_ValidationsCheck_SOQL;
            Set<Id> validRecordTypeIds = (new Map<Id,sObject>(Database.query(validRTSOQL))).keySet();   //exclude NHW and Package mgmnt cases*/             
            
            Map<Id, Case> cases = new Map<Id, Case>([select id,recordtypeId,origin,Status,contactId,Type,ES_DJC_Topic__c,ES_DJC_Sub_Topic__c from case where id in : caseIds and recordTypeid in :validRecordTypeIds ]);
            Map<Id,boolean> getMapValidations = ESDJC_Util.isValidationsPassed(cases.values());
            for(CaseComment cc : triggerNew){
                if(getMapValidations.get(cc.parentId)!=null && !getMapValidations.get(cc.parentId)){
                    String errMessage = String.format(System.Label.ES_DJC_Validations_Error_Message, new List<String>{cases.get(cc.ParentId).Status});
                    cc.addError(errMessage);
                    ESDJC_Util.IgnoreCaseIds.add(cc.parentId);
                }                    
            }                
        }
    } 
    
    public static void publicCommentValidation(List<CaseComment> comments){
        
        final Id warmlineCaseRTId = [Select Id From RecordType where sobjecttype = 'Case' and developername='Warmline'].Id;
        List<PermissionSetAssignment>  userPermissionSetList = [SELECT Id,PermissionSet.Name,AssigneeId 
                                                                FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name ='Warmline' ];
        
        Map<Id,List<CaseComment>> parentToCommentMap = new Map<Id,List<CaseComment>>();
        if(!userPermissionSetList.isEmpty()){
            for(CaseComment comment: comments){
                if(comment.IsPublished){
                    if(parentToCommentMap.containsKey(comment.parentId))
                        parentToCommentMap.get(comment.parentId).add(comment);
                    else
                        parentToCommentMap.put(comment.parentId,new List<CaseComment>{comment});
                }
            }
            for(Case c : [Select Id,RecordtypeId,Source_Apex__c from Case where Id IN:parentToCommentMap.keySet()]){
                for(CaseComment comment: parentToCommentMap.get(c.Id)){
                    if(c.recordtypeid == warmlineCaseRTId )
                        comment.addError('Cannot add public comment on a Warmline or ER Investigation Case');
                }
            }
        } 
    }
    
}