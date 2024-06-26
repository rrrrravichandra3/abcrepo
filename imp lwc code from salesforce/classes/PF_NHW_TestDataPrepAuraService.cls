public with sharing class PF_NHW_TestDataPrepAuraService {
    
    @AuraEnabled
    public static String createTestData(Map<String, Object> candidate, Map<String, Object> job, Map<String, Object> application, Boolean closePreboardingCase){
        
        try{
            WDR_Candidate__c newCandidate = (WDR_Candidate__c)JSON.deserialize(JSON.serialize(candidate), WDR_Candidate__c.class);
            WDR_Job__c newJob = (WDR_Job__c)JSON.deserialize(JSON.serialize(job), WDR_Job__c.class);
            WDR_Application__c newApplication = (WDR_Application__c)JSON.deserialize(JSON.serialize(application), WDR_Application__c.class);
            return PF_NHW_TestDataPrepHandler.createTestData(newCandidate, newJob, newApplication, closePreboardingCase);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Object> getDataToClone(String jobApplicationName){
        String dateFormat = 'yyyy-MM-dd';

        List<WDR_Application__c> application = [SELECT Id, Application_Step__c, Auto_Provisioning_Email_Sent__c, Business_Site__c, Candidate__c, Candidate_Stage__c, Do_Not_Send_NHW__c,
                                          Internal_Candidate__c, Job__c, NHW_Create_Preboarding_Case__c, Offer_Status__c, Offer_Type__c, Start_Date__c, End_Date__c,
                                          Candidate__r.Name, Candidate__r.Email__c, Candidate__r.Employee_Number__c, Candidate__r.First_Name__c, Candidate__r.Last_Name__c,
                                          Candidate__r.Mailing_City__c, Candidate__r.Mailing_Country__c, Candidate__r.Mailing_Postal_Code__c, Candidate__r.Mailing_State__c,
                                          Candidate__r.Mailing_Street__c, Candidate__r.Phone__c,
                                          Job__r.Name, Job__r.Business_Unit__c, Job__r.Company__c, Job__r.Department__c,
                                          Job__r.Division__c, Job__r.Employment_Type__c, Job__r.Hiring_Manager__c, Job__r.Job_Code__c, Job__r.Job_Level__c,
                                          Job__r.Job_Title__c, Job__r.PCC__c, Job__r.Region__c, Job__r.Target_Hire_Date__c
                                         FROM WDR_Application__c WHERE Name = :jobApplicationName];
        
        if(application.isEmpty()){
            throw new AuraHandledException('Job Application was not found');
        }
        
        Map<String,Object> applicationData = new Map<String,Object>();
        applicationData.put('Business_Site__c',application.get(0).Business_Site__c);
        applicationData.put('Candidate_Stage__c',application.get(0).Candidate_Stage__c);
        applicationData.put('Do_Not_Send_NHW__c',application.get(0).Do_Not_Send_NHW__c);
        applicationData.put('Internal_Candidate__c',application.get(0).Internal_Candidate__c);
        applicationData.put('NHW_Create_Preboarding_Case__c',application.get(0).NHW_Create_Preboarding_Case__c);
        applicationData.put('Offer_Status__c',application.get(0).Offer_Status__c);
        applicationData.put('Offer_Type__c',application.get(0).Offer_Type__c);
        
        Date startDate = application.get(0).Start_Date__c;
        applicationData.put('Start_Date__c', DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format(dateFormat));
        
        Date endDate = application.get(0).End_Date__c;
        if(endDate != null){
            applicationData.put('End_Date__c', DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format(dateFormat));
        }
        
        Map<String,Object> candidateData = new Map<String,Object>();
        candidateData.put('Email__c', application.get(0).Candidate__r.Email__c);
        candidateData.put('Employee_Number__c', application.get(0).Candidate__r.Employee_Number__c);
        candidateData.put('First_Name__c', application.get(0).Candidate__r.First_Name__c);
        candidateData.put('Last_Name__c', application.get(0).Candidate__r.Last_Name__c);
        candidateData.put('Mailing_City__c', application.get(0).Candidate__r.Mailing_City__c);
        candidateData.put('Mailing_Country__c', application.get(0).Candidate__r.Mailing_Country__c);
        candidateData.put('Mailing_Postal_Code__c', application.get(0).Candidate__r.Mailing_Postal_Code__c);
        candidateData.put('Mailing_State__c', application.get(0).Candidate__r.Mailing_State__c);
        candidateData.put('Mailing_Street__c', application.get(0).Candidate__r.Mailing_Street__c);
        candidateData.put('Phone__c', application.get(0).Candidate__r.Phone__c);
        
        Map<String,Object> jobData = new Map<String,Object>();
        jobData.put('Name', application.get(0).Job__r.Name);
        jobData.put('Business_Unit__c', application.get(0).Job__r.Business_Unit__c);
        jobData.put('Company__c', application.get(0).Job__r.Company__c);
        jobData.put('Department__c', application.get(0).Job__r.Department__c);
        jobData.put('Division__c', application.get(0).Job__r.Division__c);
        jobData.put('Employment_Type__c', application.get(0).Job__r.Employment_Type__c);
        jobData.put('Hiring_Manager__c', application.get(0).Job__r.Hiring_Manager__c);
        jobData.put('Job_Code__c', application.get(0).Job__r.Job_Code__c);
        jobData.put('Job_Level__c', application.get(0).Job__r.Job_Level__c);
        jobData.put('Job_Title__c', application.get(0).Job__r.Job_Title__c);
        jobData.put('PCC__c', application.get(0).Job__r.PCC__c);
        jobData.put('Region__c', application.get(0).Job__r.Region__c);

        Date targetHireDate = application.get(0).Job__r.Target_Hire_Date__c;
        jobData.put('Target_Hire_Date__c', DateTime.newInstance(targetHireDate.year(),targetHireDate.month(),targetHireDate.day()).format(dateFormat));
        
        Map<String,Object> result = new Map<String,Object>();
        result.put('candidate', candidateData);
        result.put('application', applicationData);
        result.put('job', jobData);

        return result;
    }
}