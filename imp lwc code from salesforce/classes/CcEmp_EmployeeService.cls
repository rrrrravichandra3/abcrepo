public with sharing class CcEmp_EmployeeService {
    public String getSessionId() {
        return UserInfo.getSessionId();
    }

    public String getUserId() {
        return UserInfo.getUserId();
    }

    public User getEmployeeDataFromSession() {
        List<User> users = [SELECT Id, FirstName, Title, LastName, EmployeeNumber, FullPhotoUrl  FROM User WHERE Id = :getUserId() WITH SECURITY_ENFORCED];
        return users[0];
    }
    
    public User getEmployeeDataWithWorkerId(String workerId){
        List<User> users = [SELECT Id,FirstName,Title,LastName,EmployeeNumber, FullPhotoUrl FROM User WHERE EmployeeNumber =: workerId WITH SECURITY_ENFORCED];
        return users[0];
    }

    public List<CcEmp_Skill_Assignment__c> getEmployeeSkills(String userId){
        List<CcEmp_Skill_Assignment__c> skills = [SELECT Id, Name FROM CcEmp_Skill_Assignment__c WHERE Worker__c = :userId WITH SECURITY_ENFORCED];
        return skills;
    }

     public List<CcEmp_Certification_Assignment__c> getEmployeeCertifications(String userId){
        List<CcEmp_Certification_Assignment__c> certifications = [SELECT Certifications__c, Certifications__r.Name FROM CcEmp_Certification_Assignment__c WHERE User__c = :userId WITH SECURITY_ENFORCED];
        return certifications;
    }

}