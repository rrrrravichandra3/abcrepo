/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 11-21-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class talentMP_SkillsService {

    @AuraEnabled
    public static List<Skill_Assignment__c> getSkillAssignments(String contactId){
        try {
            return [SELECT Id, Skill__c, Skill__r.Name,Contact__c
                    FROM Skill_Assignment__c
                    WHERE Contact__c =: contactId];   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeSkillAssignments(List<String> skillAssignmentIds){            
        try {
            if(!skillAssignmentIds.isEmpty()){
                delete [SELECT Id FROM Skill_Assignment__c WHERE Id IN :skillAssignmentIds];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static List<Skill__c> getSkillsSearchResult(String skillName, List<String> existingSkillIds){
        List<Skill__c> listSkills = new List<Skill__c>();
        skillName = String.escapeSingleQuotes(skillName);

        String query = 'Select Id, Name FROM Skill__c WHERE Name LIKE \'%' +
                        skillName.trim() +
                        '%\' and Id NOT IN: existingSkillIds ORDER BY Name ASC';
        
        try{
            listSkills = Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return listSkills;
    }

    @AuraEnabled
    public static void processNewSkillAssignments(List<String> skillNames, List<Id> contactIds){ 
        Map<String,String> mapOfNormalizedNewSkills = new Map<String,String>();  
        List<String> listExistingSkillIds = new List<String>();     
        List<String> listNewSkillsToAdd= new List<String>();     
        List<String> listNewSkillIds  = new List<String>();
        mapOfNormalizedNewSkills = getMapOfNormalizedNewSkills(skillNames);

        Map<String, String> mapExistingSkills = getSkillsDataMatchingSkillNames(mapOfNormalizedNewSkills.keySet());

        System.debug(mapExistingSkills);
        for(String normalizedSKillName : mapOfNormalizedNewSkills.keySet()){
            if(mapExistingSkills.containsKey(normalizedSKillName)){
                listExistingSkillIds.add(mapExistingSkills.get(normalizedSKillName));
            }
            else{
                listNewSkillsToAdd.add(mapOfNormalizedNewSkills.get(normalizedSKillName));
            }
        }
        System.debug(listNewSkillsToAdd);
        if(!listNewSkillsToAdd.isEmpty()){
            listNewSkillIds = addSkills(listNewSkillsToAdd);
        }

        if(!listNewSkillIds.isEmpty() || !listExistingSkillIds.isEmpty()){
            List<String> skillIds = new List<String>();
            skillIds.addAll(listExistingSkillIds);
            skillIds.addAll(listNewSkillIds);
            addSkillAssignment(skillIds,contactIds);
        }
    }

    private static void addSkillAssignment(List<String> skillIds, List<Id> contactIds){
        List<Skill_Assignment__c> listNewSkillAssignments = new List<Skill_Assignment__c>();
        for(String skillId : skillIds){
            for(Id contactId : contactIds){
                listNewSkillAssignments.add(new Skill_Assignment__c(Skill__c = skillId, Contact__c = contactId));
            }
        }

        try {
                insert listNewSkillAssignments;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<Id> addSkills(List<String> skillNames){
        List<Skill__c> listNewSkills = new List<Skill__c>();
        List<String> listNewSkillIds = new List<String>();

        for(String skillName : skillNames){
            listNewSkills.add(new Skill__c(Name = skillName));
        }
        
        try{
            Database.SaveResult[] skillsResults = Database.insert(listNewSkills,false);
            for(Database.SaveResult result : skillsResults){
                if (result.isSuccess()) {
                    listNewSkillIds.add(result.getId());
                }
                else{
                    System.debug(result.getErrors());
                }   
            }
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
        return listNewSkillIds;
    }

    private static Map<String,String> getMapOfNormalizedNewSkills(List<String> skillNames){
        Map<String,String> mapOfNormalizedNewSkills = new Map<String,String>();
        for(String skillName : skillNames){
            String normalizedSkillName = normalizeSkillName(skillName);
            mapOfNormalizedNewSkills.put(normalizedSkillName, skillName);
        }
        System.debug(mapOfNormalizedNewSkills);
        return mapOfNormalizedNewSkills;
    }

    private static Map<String, String> getSkillsDataMatchingSkillNames(Set<String> normalizedSkillNames){
        Map<String, String> mapExistingSkills = new Map<String,String>();
        for(Skill__c skill : [SELECT Id, Unique_Skill_Name__c
                                FROM Skill__c
                                WHERE Unique_Skill_Name__c IN: normalizedSkillNames]){
            mapExistingSkills.put(skill.Unique_Skill_Name__c, skill.Id);
        }
        return mapExistingSkills;
    }

    public static String normalizeSkillName(String skillName){
        String normalized = skillName.toLowerCase();
        normalized = normalized.replaceAll('^\\s+', '');
        return normalized.replaceAll('\\s', '_');
    }

    public class EmployeeWrapper{
        @AuraEnabled
        public Contact contact { get; set; }
        @AuraEnabled
        public List<Skill_Assignment__c> skillList { get; set; }
    }

}