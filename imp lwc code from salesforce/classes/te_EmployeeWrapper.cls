public with sharing class te_EmployeeWrapper {

    public static EmployeeWrapper getEmployeeData(String workerId){
        EmployeeWrapper emp = new EmployeeWrapper();

        User usr = [SELECT id, FullPhotoUrl FROM User WHERE EmployeeNumber =: workerId LIMIT 1];
        emp.usr = usr;
            
        Contact con = [SELECT Id, FirstName,LastName,EmployeeNumber__c,
            Email,Title,Department,ES_DJC_Work_Location__c,
            ES_DJC_Grade__c,Job_code__c,Job_Family__c,Segment__c
            FROM Contact
            WHERE EmployeeNumber__c =: workerId];

            if(con.Job_code__c != null && con.Job_code__c != ''){
                Job_Profile__c jobProfile = [SELECT Name,Job_Family__r.Name,Job_Family__r.Job_Group__r.Name FROM Job_Profile__c where Job_code__c = :con.Job_code__c];
                if(jobProfile != null){
                    con.Job_Family__c = jobProfile.Job_Family__r.Name;
                    con.Segment__c = jobProfile.Job_Family__r.Job_Group__r.Name;
                }
            }

        emp.contact = con;

        List<Skill_Assignment__c> skills = [SELECT Skill__c, Skill__r.Name 
            FROM Skill_Assignment__c 
            WHERE Contact__r.EmployeeNumber__c =: workerId];

        emp.skillList = skills;

        List<Certification_Assignment__c> certifications = [SELECT Certifications__c, Certifications__r.Name 
        FROM Certification_Assignment__c 
        WHERE Contact__r.EmployeeNumber__c =: workerId];

        emp.certificationList = certifications;

    return emp;
    }
    
    public class EmployeeWrapper{
        @AuraEnabled
        public Contact contact { get; set; }
        @AuraEnabled
        public User usr { get; set; }
        @AuraEnabled
        public List<Skill_Assignment__c> skillList { get; set; }
        @AuraEnabled
        public List<Certification_Assignment__c> certificationList { get; set; }

    }
}