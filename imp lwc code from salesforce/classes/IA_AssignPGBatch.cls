public with sharing class IA_AssignPGBatch implements Database.Batchable<sObject> {
    public Set<Id> permIdSet =  new Set<Id>();
    public List<PermissionSetAssignment> permAssignmentsToDelete = new List<PermissionSetAssignment>();
    public Map<String, String> failedDeleteRecords = new Map<String, String>();
    public Insiders_App_Config__mdt appConfig = [SELECT Perm_Set__c,Public_Group__c,Eligible_Candidate_Stage__c, Email_Addresses_for_Exceptions__c  from Insiders_App_Config__mdt LIMIT 1];
	public List<String> permSetNames = new List<String> {appConfig.Perm_Set__c};
    public List<String> publicGroupNames = new List<String> {appConfig.Public_Group__c};
    public List<String> insidersGroupIds = new List<String>();
    public Database.QueryLocator start(Database.BatchableContext BC) {
        for(PermissionSet p: [Select Id, Name, Label from PermissionSet where Name in :permSetNames]){
            permIdSet.add(p.Id);
        } 
        String query = 'select Id, AssigneeId, PermissionSetId from PermissionSetAssignment where PermissionSetId IN :PermIdSet';
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext BC, List<PermissionSetAssignment> scope) {
        Map <Id, PermissionSetAssignment> userIdstoPermsetAssignments = new Map <Id, PermissionSetAssignment>();
        List<Group> insidersGroup=[SELECT Id, DeveloperName from Group Where DeveloperName IN: publicGroupNames]; 
        for(Group grp: insidersGroup){
            insidersGroupIds.add(grp.Id);
        }
        
		List<String> eligibleCandidateStages = IA_Util.eligibleCandidateStages;
        List<String> eligibleCandidateStagesInternal = IA_Util.eligibleCandidateStagesForInternal;
        List<Id> userIdsToRemoveGroup = new List<Id>();
        for (PermissionSetAssignment ps: scope) {
                userIdstoPermsetAssignments.put(ps.AssigneeId,ps);
        }
        
        List<User> permsetUsers = [SELECT Id,Email, Contact.MPA_App__r.Candidate_Stage__c,Contact.MPA_App__c 
                                   FROM User 
                                   WHERE Id in: userIdstoPermsetAssignments.keyset() WITH SECURITY_ENFORCED];

        Map<String,User> candidateEmailMap = new Map<String,User>();
        for(User insiderUsersToDelete: permsetUsers){
            candidateEmailMap.put(insiderUsersToDelete.email,insiderUsersToDelete);
        }
        
        //Checking for internal/external candidate from all application using email id of the user
        //Logic to remove portal user permission from internal/external candidate if none of the app in eligible stage
        Map<String,List<WDR_Application__c>> emailApplicationMapInternal = new Map<String,List<WDR_Application__c>>();
        Map<String,List<WDR_Application__c>> emailApplicationMapExternal = new Map<String,List<WDR_Application__c>>();
        List<User> listofInternalUsers = new List<User>();
        List<User> listofExternalUsers = new List<User>();
        List<WDR_Application__c> currentAllAplication = [Select Candidate_Stage__c,Candidate_Email__c,Internal_Candidate__c from WDR_Application__c where Candidate_Email__c IN :candidateEmailMap.KeySet()];
        for(WDR_Application__c wd:currentAllAplication){
            if(wd.Internal_Candidate__c == True){
                if(!emailApplicationMapInternal.containsKey(wd.Candidate_Email__c)){
                    emailApplicationMapInternal.put(wd.Candidate_Email__c,new List<WDR_Application__c>{wd});
                }
                else{
                    List<WDR_Application__c> wdList = emailApplicationMapInternal.get(wd.Candidate_Email__c);
                    wdList.add(wd);
                    emailApplicationMapInternal.put(wd.Candidate_Email__c,wdList);
                }
            }
            else{
                if(!emailApplicationMapExternal.containsKey(wd.Candidate_Email__c)){
                    emailApplicationMapExternal.put(wd.Candidate_Email__c,new List<WDR_Application__c>{wd});
                }
                else{
                    List<WDR_Application__c> wdList1 = emailApplicationMapExternal.get(wd.Candidate_Email__c);
                    wdList1.add(wd);
                    emailApplicationMapExternal.put(wd.Candidate_Email__c,wdList1);
                }
            }
        }
        
        //check for internal candidate against eligible stage application
        for(String s:emailApplicationMapInternal.keySet()){
            Boolean isRejected= True;
            for(WDR_Application__c wdApplication: emailApplicationMapInternal.get(s)){
                if(eligibleCandidateStagesInternal.contains(wdApplication.Candidate_Stage__c)){
                    isRejected= false;
                    break;
                }
            }
            if(isRejected==True){
                listofInternalUsers.add(candidateEmailMap.get(s));
            }
        }
        
        //check for external candidate against eligible stage application
        for(String s:emailApplicationMapExternal.keySet()){
            Boolean isRejected1= True;
            for(WDR_Application__c wdApplication: emailApplicationMapExternal.get(s)){
                if(eligibleCandidateStages.contains(wdApplication.Candidate_Stage__c)){
                    isRejected1= false;
                    break;
                }
            }
            if(isRejected1==True){
                listofExternalUsers.add(candidateEmailMap.get(s));
            }
        }
        
        //Remove permission & public group from external candidate for portal access
        for(User insiderUsersToDelete: listofExternalUsers){
			permAssignmentsToDelete.add(userIdstoPermsetAssignments.get(insiderUsersToDelete.Id));
            userIdsToRemoveGroup.add(insiderUsersToDelete.Id);
        }
        
        //Remove permission & public group from internal candidate for portal access
        for(User insiderInternalUsersToDelete: listofInternalUsers){
                permAssignmentsToDelete.add(userIdstoPermsetAssignments.get(insiderInternalUsersToDelete.Id));
                userIdsToRemoveGroup.add(insiderInternalUsersToDelete.Id);
        }
        
        if(permAssignmentsToDelete.size()>0 && permAssignmentsToDelete.getSObjectType().getDescribe().isDeletable()){
            Database.DeleteResult[] deleteResult = Database.delete(permAssignmentsToDelete,false);
            for(Database.DeleteResult dr : deleteResult) {
                if (!dr.isSuccess()) {
                    for(Database.Error err : dr.getErrors()) {
						failedDeleteRecords.put(dr.getId(), err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }

        List<GroupMember> ListGMtoDelete  = [ Select Id from GroupMember where GroupId  in :insidersGroupIds and UserOrGroupID in : userIdsToRemoveGroup WITH SECURITY_ENFORCED];
        if(ListGMtoDelete.size()>0 && ListGMtoDelete.getSObjectType().getDescribe().isDeletable()){
            Database.DeleteResult[] deleteResult = Database.delete(ListGMtoDelete,false);
            for(Database.DeleteResult dr : deleteResult) {
                if (!dr.isSuccess()) {
                    for(Database.Error err : dr.getErrors()) {
						failedDeleteRecords.put(dr.getId(), err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }      
    }
    
    public void finish(Database.BatchableContext BC) { 
        
       	List<String> emailIds = new List<String>();
        if(!String.isEmpty(appConfig.Email_Addresses_for_Exceptions__c)){
            emailIds.addAll(appConfig.Email_Addresses_for_Exceptions__c.split(','));
        }
		
        if(!failedDeleteRecords.isEmpty()){
        Messaging.SingleEmailMessage mailDeleteUpdates = new Messaging.SingleEmailMessage();
        
        mailDeleteUpdates.setToAddresses(emailIds);
        mailDeleteUpdates.setSenderDisplayName('Insiders App Block Auth');
        mailDeleteUpdates.setSubject('Insiders App Block Auth failed results');
        String message = '';
        
            message = message + '\nFollowing ' + failedDeleteRecords.size() +'  PermsetAssignment Records Failed to Delete :\n';
            for(String fdr : failedDeleteRecords.keySet()){
                message = message +'\n'+ fdr + ' : '+ failedDeleteRecords.get(fdr);
            }
        mailDeleteUpdates.setPlainTextBody(message);
            if(!test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailDeleteUpdates});
            }
        
        }
    }
}