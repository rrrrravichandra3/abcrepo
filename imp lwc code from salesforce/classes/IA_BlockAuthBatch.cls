/**
 * @description       : Batch job to remove access to Insider users in defined stages
 * @author            : skolagani@salesforce.com
 * @last modified on  : 02-11-2021
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-07-2020   Sri Kolagani                         Batch job creation
 * 1.1   01-19-2021   Sri Kolagani                         Removing users from Insiders App Public Group
 * 1.2   11-16-2022   Manish Pal                           Added logic to remove Internal/External user permission and public group based on the candidate eligible stage in application(Removing MPA dependency) 
**/
public with sharing class IA_BlockAuthBatch implements Database.Batchable<sObject> {
    public Set<Id> permIdSet =  new Set<Id>();
    public List<PermissionSetAssignment> permAssignmentsToDelete = new List<PermissionSetAssignment>();
    public Map<String, String> failedDeleteRecords = new Map<String, String>();
    public List<String> insidersGroupIds = new List<String>();
    Insiders_App_Config__mdt appConfig = [SELECT Perm_Set__c,Public_Group__c,Eligible_Candidate_Stage__c, Email_Addresses_for_Exceptions__c  from Insiders_App_Config__mdt LIMIT 1];
	public List<String> permSetNames = new List<String> {appConfig.Perm_Set__c};
    List<String> publicGroupNames = new List<String> {appConfig.Public_Group__c};
    public Map<String,List<WDR_Application__c>> emailApplicationMapInternal = new Map<String,List<WDR_Application__c>>();
    public Map<String,List<WDR_Application__c>> emailApplicationMapExternal = new Map<String,List<WDR_Application__c>>();
    public List<User> listofInternalUsers = new List<User>();
    public List<User> listofExternalUsers = new List<User>();
    public List<String> eligibleCandidateStages = IA_Util.eligibleCandidateStages;
    public List<String> eligibleCandidateStagesInternal = IA_Util.eligibleCandidateStagesForInternal;
    public Map <Id, PermissionSetAssignment> userIdstoPermsetAssignments = new Map <Id, PermissionSetAssignment>();
    public Map<String,User> candidateEmailMap = new Map<String,User>();
    
    /**
     * @description       : Starts the batch job by querying the necessary data
     * @param {Database.BatchableContext} BC - The context object that provides information about the batch job
     * @return {Database.QueryLocator} - A query locator that defines the data to be processed by the batch job
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        for(PermissionSet p: [Select Id, Name, Label from PermissionSet where Name in :permSetNames]){
            permIdSet.add(p.Id);
        }
        if(!test.isRunningTest()){
            query = 'select Id, AssigneeId, PermissionSetId from PermissionSetAssignment where PermissionSetId IN :PermIdSet';
        }
        else{
            query = 'select Id, AssigneeId, PermissionSetId from PermissionSetAssignment where PermissionSetId IN :PermIdSet LIMIT 200';
        }
        return Database.getQueryLocator(query);        
    }
    /**
     * @description       : Executes the batch job by processing the data retrieved in the start method
     * @param {Database.BatchableContext} BC - The context object that provides information about the batch job
     * @param {List<PermissionSetAssignment>} scope - The list of PermissionSetAssignments to be processed
     */
    public void execute(Database.BatchableContext BC, List<PermissionSetAssignment> scope) {
        List<Id> userIdsToRemoveGroup = new List<Id>();
        Insiders_App_Config__mdt appConfig = [SELECT Perm_Set__c,Public_Group__c,Eligible_Candidate_Stage__c, Email_Addresses_for_Exceptions__c  from Insiders_App_Config__mdt LIMIT 1];
        List<String> publicGroupNames = new List<String> {appConfig.Public_Group__c};
        
        List<Group> insidersGroup=[SELECT Id, DeveloperName from Group Where DeveloperName IN: publicGroupNames]; 
        for(Group grp: insidersGroup){
            insidersGroupIds.add(grp.Id);
        }
        for (PermissionSetAssignment ps: scope) {
                userIdstoPermsetAssignments.put(ps.AssigneeId,ps);
        }
        
        List<User> permsetUsers = [SELECT Id,Email, Contact.MPA_App__r.Candidate_Stage__c,Contact.MPA_App__c 
                                   FROM User 
                                   WHERE Id in: userIdstoPermsetAssignments.keyset() WITH SECURITY_ENFORCED];
        
        for(User insiderUsersToDelete: permsetUsers){
            candidateEmailMap.put(insiderUsersToDelete.email,insiderUsersToDelete);
        }
        
        List<WDR_Application__c> currentAllAplication = [Select Candidate_Stage__c,Candidate_Email__c,Internal_Candidate__c from WDR_Application__c where Candidate_Email__c IN :candidateEmailMap.KeySet()];
        returnInternalExternalApp(currentAllAplication);
		returnListOfInternalUsers(emailApplicationMapInternal,candidateEmailMap);
        returnListOfExternalUsers(emailApplicationMapExternal,candidateEmailMap);
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
        deletePS(permAssignmentsToDelete);
        deletePublicGroup(userIdsToRemoveGroup,insidersGroupIds);
    }
    /**
     * @description       : Finishes the batch job by sending any failed delete records to an email address
     * @param {Database.BatchableContext} BC - The context object that provides information about the batch job
     */
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
    /**
     * @description       : This method processes the list of all applications and categorizes them into internal and external applications based on the 'Internal_Candidate__c' field of the application.
     * @param {List<WDR_Application__c>} currentAllAplication - The list of all applications to be processed.
     * @return {Void} - This method does not return any value. It updates the 'emailApplicationMapInternal' and 'emailApplicationMapExternal' maps with the categorized applications.
     */
    public void returnInternalExternalApp(List<WDR_Application__c> currentAllAplication){
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
    }
    /**
     * @description : This method processes the list of all internal applications and categorizes them into internal applications based on the 'Internal_Candidate__c' field of the application.
     * @param {Map<String,List<WDR_Application__c>>} emailApplicationMapInternal - The map containing the list of all internal applications.
     * @param {Map<String,User>} candidateEmailMap - The map containing the list of all users with their email addresses as keys.
     * @return {Void} - This method does not return any value. It updates the 'listofInternalUsers' list with the categorized internal applications.
     */
    public void returnListOfInternalUsers(Map<String,List<WDR_Application__c>> emailApplicationMapInternal,Map<String,User> candidateEmailMap){
        system.debug('candidateEmailMap'+candidateEmailMap);
        system.debug('emailApplicationMapInternal'+emailApplicationMapInternal);
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
    }
    /**
     * @description : This method processes the list of all external applications and categorizes them into external applications based on the 'Internal_Candidate__c' field of the application.
     * @param {Map<String,List<WDR_Application__c>>} emailApplicationMapExternal - The map containing the list of all external applications.
     * @param {Map<String,User>} candidateEmailMap - The map containing the list of all users with their email addresses as keys.
     * @return {Void} - This method does not return any value. It updates the 'listofExternalUsers' list with the categorized external applications.
     */
    public void returnListOfExternalUsers(Map<String,List<WDR_Application__c>> emailApplicationMapExternal,Map<String,User> candidateEmailMap){
        system.debug('emailApplicationMapExternal'+emailApplicationMapExternal);
        system.debug('candidateEmailMap1'+candidateEmailMap);
        system.debug('listofInternalUsers'+listofInternalUsers);
        //check for external candidate against eligible stage application
        for(String s:emailApplicationMapExternal.keySet()){
            Boolean isRejected1= True;
            for(WDR_Application__c wdApplication: emailApplicationMapExternal.get(s)){
                if(eligibleCandidateStages.contains(wdApplication.Candidate_Stage__c)){
                    isRejected1= false;
                    break;
                }
            }
            if(isRejected1==True && !listofInternalUsers.contains(candidateEmailMap.get(s))){
                listofExternalUsers.add(candidateEmailMap.get(s));
            }
        }
    }
    /**
     * @description : This method is responsible for deleting the specified PermissionSetAssignments.
     * It first checks if the list of PermissionSetAssignments is not empty and if the SObject type of the list is deletable.
     * If both conditions are met, it attempts to delete the PermissionSetAssignments using the Database.delete method.
     * If the deletion is successful, it returns without any further action.
     * If the deletion fails, it logs the failure details to the 'failedDeleteRecords' map.
     * @param {List<PermissionSetAssignment>} permAssignmentsToDelete - The list of PermissionSetAssignments to be deleted.
     * @return {Void} - This method does not return any value.
     */
    public void deletePS(List<PermissionSetAssignment> permAssignmentsToDelete){
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
    }
    /**
     * @description : This method is responsible for deleting the specified GroupMembers from the specified Group.
     * It first checks if the list of GroupMembers is not empty and if the SObject type of the list is deletable.
     * If both conditions are met, it attempts to delete the GroupMembers using the Database.delete method.
     * If the deletion is successful, it returns without any further action.
     * If the deletion fails, it logs the failure details to the 'failedDeleteRecords' map.
     * @param {List<Id>} userIdsToRemoveGroup - The list of UserIds to be removed from the specified Group.
     * @param {List<String>} insidersGroupIds - The list of GroupIds where the specified UserIds are members.
     * @return {Void} - This method does not return any value.
     */
    public void deletePublicGroup(List<Id> userIdsToRemoveGroup,List<String> insidersGroupIds){
        List<GroupMember> listGMtoDelete  = [ Select Id from GroupMember where GroupId  in :insidersGroupIds and UserOrGroupID in : userIdsToRemoveGroup WITH SECURITY_ENFORCED];
        if(listGMtoDelete.size()>0 && listGMtoDelete.getSObjectType().getDescribe().isDeletable()){
            Database.DeleteResult[] deleteResult = Database.delete(listGMtoDelete,false);
            for(Database.DeleteResult dr : deleteResult) {
                if (!dr.isSuccess()) {
                    for(Database.Error err : dr.getErrors()) {
						failedDeleteRecords.put(dr.getId(), err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }
}