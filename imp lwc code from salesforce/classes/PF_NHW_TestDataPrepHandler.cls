@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public without sharing class PF_NHW_TestDataPrepHandler {

    public static Id createTestData(WDR_Candidate__c candidate, WDR_Job__c job, WDR_Application__c application, Boolean closePreboardingCase){

        if(application.Internal_Candidate__c == null){
            application.Internal_Candidate__c = false;
        }
        
        if(application.Do_Not_Send_NHW__c == null){
            application.Do_Not_Send_NHW__c = false;
        }

        if(String.isBlank(candidate.Mailing_Street__c)){
            candidate.Mailing_Street__c = '350 mission st';
        }
        
        if(String.isBlank(candidate.Mailing_City__c)){
            candidate.Mailing_City__c = 'San Francisco';
        }
        
        if(String.isBlank(candidate.Mailing_State__c)){
            candidate.Mailing_State__c = 'San Francisco';
        }
        
        if(String.isBlank(candidate.Mailing_Postal_Code__c)){
            candidate.Mailing_Postal_Code__c = '94002';
        }

        if(String.isBlank(candidate.Mailing_Country__c)){
            candidate.Mailing_Country__c = 'United States';
        }
        
        if(String.isBlank(job.Employment_Type__c)){
            job.Employment_Type__c = 'Intern';
        }
        
        if(String.isBlank(job.Job_Code__c)){
            job.Job_Code__c = '218C03';
        }
        
        if(String.isBlank(application.Offer_Type__c)){
            application.Offer_Type__c = 'FTE';
        }
        
        if(String.isBlank(application.Offer_Status__c)){
            application.Offer_Status__c = 'Approved';
        }
        
        if(String.isBlank(application.Candidate_Stage__c)){
            application.Candidate_Stage__c = 'Placement';
        }

        if(closePreboardingCase){
            job.Name = 'NHW Aut-Test';
        }else{
            job.Name = 'NHW Test';
        }

        String wdrCandidateAccount = System.Label.NHW_Data_Prep_Account_Detail;
        
        Id accId = [Select id from Account Where Name =: wdrCandidateAccount ORDER BY CreatedDate ASC limit 1].id;

        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WDR_Candidate').getRecordTypeId();

        Contact con = new Contact();
        if(!String.isBlank(candidate.First_Name__c) && !String.isBlank(candidate.Last_Name__c)){
            con.FirstName = candidate.First_Name__c ;
            con.LastName = candidate.Last_Name__c;
        }
        if(!String.isBlank(accId)){
         con.AccountId = accId;
        }
        if(!String.isBlank(recordTypeId)){
        	con.RecordTypeId = recordTypeId;
        } 
        con.Email = candidate.Email__c;
        Insert con;
        
        String wdrCandidateType = System.Label.NHW_Data_Prep_Candidate_Type;
        
        candidate.Candidate_Type__c = wdrCandidateType;
        
        if(!String.isBlank(con.Id)){
          candidate.Candidate_Contact__c = con.Id;
        }
        insert candidate;

        insert job;
        application.Candidate__c = candidate.Id;
        application.Job__c = job.Id;
        insert application;
        
        return application.Id;
    }
    
}