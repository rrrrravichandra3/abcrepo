/**
 * @description This class is a trigger handler for the IA_WDJobApplicationTrigger.
 * It handles the afterInsert, afterUpdate, and afterDelete events for the IA_WDJobApplicationTrigger.
 *
 * @author  
 */
public with sharing class IA_WDJobApplicationTriggerHandler implements WDR_CommonTriggerHandler{
    /**
     * @edscription This method is called before a new record is inserted.
     *
     * @param  none
     * @return  none
     */
    public void beforeInsert(){
        
    }
    /**
     * @edscription This method is called before a new record is updated.
     *
     * @param  none
     * @return  none
     */
    public void beforeUpdate(){
        
    }
    /**
     * @edscription This method is called before a record is deleted.
     *
     * @param  none
     * @return  none
     */
    public void beforeDelete(){
        
    }
    /**
     * @edscription This method is called after a new record is inserted.
     * It retrieves the matching IA_Invitation_JobApplication__c records and updates them accordingly.
     *
     * @param  none
     * @return  none
     */
    public void afterInsert(){
        List<IA_Invitation_JobApplication__c> result = new List<IA_Invitation_JobApplication__c>();
        // --------------------------------------------------------------------------------
        List<IA_Invitation_Config__mdt> settings = [SELECT Id, DeveloperName, MasterLabel, Application_Step__c, 
                                                    Candidate_Stage__c FROM IA_Invitation_Config__mdt
                                                    WHERE Type__c = 'TRIGGER' WITH SECURITY_ENFORCED];
        // --------------------------------------------------------------------------------
        List<IA_Invitation_JobApplication__c> toUpdateRecords = [SELECT Id, Name FROM IA_Invitation_JobApplication__c
                                                                 WHERE Name IN: Trigger.newMap.keyset() WITH SECURITY_ENFORCED];
        
        for (WDR_Application__c newRec: (list<WDR_Application__c>)Trigger.new) {
            // ----------------------------------------
            List<IA_Invitation_Config__mdt> newRecMatch = new List<IA_Invitation_Config__mdt>();
            for (IA_Invitation_Config__mdt setting : settings) {
                Boolean isStage = newRec.Candidate_Stage__c == setting.Candidate_Stage__c;
                Boolean isStep = newRec.Application_Step__c == setting.Application_Step__c;
                if (isStage && isStep) {
                    newRecMatch.add(setting);
                }
            }
            // ----------------------------------------
            if (!newRecMatch.isEmpty()) {
                String name = (String)newRec.Id;
                Id foundId = null;
                for (IA_Invitation_JobApplication__c custSetRec : toUpdateRecords) {
                    foundId = (custSetRec.Name == name) ? custSetRec.Id : foundId;
                }
                IA_Invitation_JobApplication__c rec = new IA_Invitation_JobApplication__c(Id = foundId, Name = name);
                result.add(rec);
            }
        }
        upsert result;
    }
    /**
     * @description This method is called after a record is updated.
     * It retrieves the matching IA_Invitation_JobApplication__c records and updates them accordingly.
     *
     * @param  none
     * @return  none
     */
    public void afterUpdate(){
        List<IA_Invitation_Config__mdt> settings = [SELECT Id, DeveloperName, MasterLabel, Application_Step__c, 
                                                    Candidate_Stage__c FROM IA_Invitation_Config__mdt
                                                    WHERE Type__c = 'TRIGGER' WITH SECURITY_ENFORCED];
        // --------------------------------------------------------------------------------
        List<IA_Invitation_JobApplication__c> result = new List<IA_Invitation_JobApplication__c>();
        List<IA_Invitation_JobApplication__c> toUpdateRecords = [SELECT Id, Name FROM IA_Invitation_JobApplication__c
                                                              WHERE Name IN: Trigger.newMap.keyset() WITH SECURITY_ENFORCED];
        for (WDR_Application__c newRec: (list<WDR_Application__c>) Trigger.new) {
            WDR_Application__c oldRec = (WDR_Application__c)Trigger.oldMap.get(newRec.id);
            // --------------------------------------------------------------------------------
            String newApplicationStep = newRec.Application_Step__c != null ? newRec.Application_Step__c.toLowerCase() : '';
            String oldApplicationStep = oldRec.Application_Step__c != null ? oldRec.Application_Step__c.toLowerCase() : '';
            String newCandidateStage = newRec.Candidate_Stage__c != null ? newRec.Candidate_Stage__c.toLowerCase() : '';
            String oldCandidateStage = oldRec.Candidate_Stage__c != null ? oldRec.Candidate_Stage__c.toLowerCase() : '';
            // --------------------------------------------------------------------------------
            List<IA_Invitation_Config__mdt> newRecMatch = new List<IA_Invitation_Config__mdt>();
            for (IA_Invitation_Config__mdt setting : settings) {
                Boolean isStage = newRec.Candidate_Stage__c == setting.Candidate_Stage__c;
                Boolean isStep = newRec.Application_Step__c == setting.Application_Step__c;
                if (isStage && isStep) {
                    newRecMatch.add(setting);
                }
            }
            Boolean hasMatchForNewRec = !newRecMatch.isEmpty();
            // --------------------------------------------------------------------------------
            Boolean hasChangeForNewAndOldRec = (newApplicationStep != oldApplicationStep) || (newCandidateStage != oldCandidateStage);
            if (hasChangeForNewAndOldRec && hasMatchForNewRec) {
                String name = (String)newRec.Id;
                Id foundId = null;
                for (IA_Invitation_JobApplication__c custSetRec : toUpdateRecords) {
                    foundId = (custSetRec.Name == name) ? custSetRec.Id : foundId;
                }
                IA_Invitation_JobApplication__c rec = new IA_Invitation_JobApplication__c(Id = foundId, Name = name);
                result.add(rec);
            }
        }
        upsert result;
    }
    /**
     * @edscription This method is called after a record is deleted.
     *
     * @param  none
     * @return  none
     */
    public void afterDelete(){
        
    }
    /**
     * @edscription This method is called after a record is undeleted.
     *
     * @param  none
     * @return  none
     */
    Public void afterUnDelete(){
        
    }
    
}