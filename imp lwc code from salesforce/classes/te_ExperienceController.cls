/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 02-01-2024
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class te_ExperienceController {
    @AuraEnabled
    public static List<ExperienceWrapper> getExperiences(Id contactId){
        List<te_Experience__c> experiences = new List<te_Experience__c>();
        List<ExperienceWrapper> experiencesWrapper = new List<ExperienceWrapper>();
        try {
            for(te_Experience__c experience : [SELECT Id, Job_Title__c, Start_Date__c, End_Date__c, Organization_Name__c, Description__c,Current__c
                        FROM te_Experience__c
                        WHERE Contact__c = :contactId
                        ORDER BY Current__c DESC, End_Date__c DESC NULLS LAST]){
                            experiencesWrapper.add(new te_ExperienceController.ExperienceWrapper(
                                experience.Id, experience.Job_Title__c, experience.Start_Date__c, experience.End_Date__c, experience.Current__c, experience.Organization_Name__c, experience.Description__c
                            ));
            }
        System.debug(experiencesWrapper);
        return experiencesWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createExperience(Map<String, Object> expWrapper) {
        try{
            te_Experience__c newExperience = populateExperienceData(expWrapper);
            insert newExperience;
            return newExperience.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating experience: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateExperience(Map<String, Object> expWrapper) {
        try{
            te_Experience__c experience = populateExperienceData(expWrapper);
            experience.Id = (String)expWrapper.get('Id');
            update experience;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating experience: ' + e.getMessage());
        }

    }

    @AuraEnabled
    public static void deleteExperience(String experienceId) {
        try{
            delete [SELECT Id FROM te_Experience__c WHERE Id = :experienceId];
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting experience: ' + e.getMessage());
        }
    }

    private static te_Experience__c populateExperienceData(Map<String, Object> expWrapper){
        System.debug('Description-->>'+(String)expWrapper.get('description'));
        te_Experience__c newExperience = new te_Experience__c();
        newExperience.Job_Title__c = (String)expWrapper.get('jobTitle');
        newExperience.Start_Date__c = Date.valueOf((String)expWrapper.get('startDate'));
        if((Boolean)expWrapper.get('isCurrent') == false){
            newExperience.End_Date__c = Date.valueOf((String)expWrapper.get('endDate'));
        }
        newExperience.Description__c = (String)expWrapper.get('description');
        newExperience.Organization_Name__c = (String)expWrapper.get('organizationName');
        newExperience.Current__c = (Boolean)expWrapper.get('isCurrent');
        newExperience.Contact__c = (String)expWrapper.get('contactId'); 

        return newExperience;
    }

    public class ExperienceWrapper{
        @AuraEnabled
        public string Id{get;set;}
        @AuraEnabled
        public string jobTitle{get;set;}
        @AuraEnabled
        public date startDate{get;set;}
        @AuraEnabled
        public date endDate{get;set;}
        @AuraEnabled
        public boolean isCurrent{get;set;}
        @AuraEnabled
        public string organizationName{get;set;}
        @AuraEnabled
        public string description{get;set;}

        public ExperienceWrapper(string Id, string jobTitle, date startDate, date endDate, boolean isCurrent, string organizationName, string description){
            this.Id = Id;
            this.jobTitle = jobTitle;
            this.startDate = startDate;
            this.endDate = endDate;
            this.isCurrent = isCurrent;
            this.organizationName = organizationName;
            this.description = description;
        }
    }
}