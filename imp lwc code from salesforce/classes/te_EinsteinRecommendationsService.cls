/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class te_EinsteinRecommendationsService {
    Static boolean gptRunning = true;

    public static String callRecService(Boolean isRelocation,reqBody body){
        body.country = isRelocation ?  body.country : '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint('https://wcshdm131h.execute-api.us-west-2.amazonaws.com/test/recommendation');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody(JSON.serialize(body,true));
        HttpResponse res = h.send(req);
        system.debug(res.getBody());
        return res.getBody();
    }

    public static String callRecServiceFullEmed(Boolean isRelocation,reqBody body){
        body.country = isRelocation ?  body.country : '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint('https://wcshdm131h.execute-api.us-west-2.amazonaws.com/test/recommendationJD');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody(JSON.serialize(body,true));
        HttpResponse res = h.send(req);
        system.debug(res.getBody());
        return res.getBody();
    }

    @AuraEnabled
    public static List<JobWrapper> getJobRecommendations(string contactId,reqBody contactJobVector, Boolean fullEmbedding) {
        List<JobWrapper> recommendedJobs = new List<JobWrapper>();
        List<String> skillList = getSkills(contactId);
        String json;
        if(fullEmbedding){
            json = callRecServiceFullEmed(false,contactJobVector);
        }else{
            json =  callRecService(false,contactJobVector);
        }
        List<Id> savedJobIds = talentMP_SearchJobService.getSavedJobsForUser(contactId);

        Map<String,String> mapJRIDtoMatchScore = parseResponseToMap(json);
        
        List<te_job__c> jobsInOrg = getJobRecords(mapJRIDtoMatchScore.keySet());
        for(te_job__c j: jobsInOrg){
            JobWrapper jobData = new JobWrapper();
            jobData.isSaved = false; 
            j.match_score__c = Decimal.valueof(mapJRIDtoMatchScore.get(j.Reference_Id__c));
            jobData.job = j;
            if(!savedJobIds.isEmpty() && savedJobIds.contains(j.Id)){
                jobData.isSaved = true; 
            }
            //jobData.matchingSkills = getExplainability(j,skillList);
            //System.debug(jobData.matchingSkills);

            recommendedJobs.add(jobData);
        }

        return recommendedJobs;
    }

    @AuraEnabled
    public static List<JobWrapper> getRelocationJobRecommendations(string contactId,reqBody contactJobVector, Boolean fullEmbedding) {
        List<JobWrapper> recommendedJobs = new List<JobWrapper>();
        string json;
        if(fullEmbedding){
            json = callRecServiceFullEmed(true,contactJobVector);
        }else{
            json =  callRecService(true,contactJobVector);
        }
        List<Id> savedJobIds = talentMP_SearchJobService.getSavedJobsForUser(contactId);
        
        Map<String,String> mapJRIDtoMatchScore = parseResponseToMap(json);
        
        List<te_job__c> jobsInOrg = getJobRecords(mapJRIDtoMatchScore.keySet());
        for(te_job__c j: jobsInOrg){
            JobWrapper jobData = new JobWrapper();
            jobData.isSaved = false; 
            j.match_score__c = Decimal.valueof(mapJRIDtoMatchScore.get(j.Reference_Id__c));
            jobData.job = j;
            if(!savedJobIds.isEmpty() && savedJobIds.contains(j.Id)){
                jobData.isSaved = true; 
            }
            recommendedJobs.add(jobData);
        }

        return recommendedJobs;
    }

    public static String insertJobtoMySQLDB(Id jobId){

        te_job__c job = [SELECT Id, Reference_Id__c, skills__c, All_Locations__c, Compensation_Grade__c,Country__c,Job_Description__c,vector__c,jd_vector__c FROM te_job__c WHERE Id =: jobId];
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://wcshdm131h.execute-api.us-west-2.amazonaws.com/test/job');
        req.setMethod('PUT');
        req.setHeader('Content-Type','application/json');
        job.Job_Description__c = job.Job_Description__c.stripHtmlTags();
        req.setBody(System.JSON.serialize(job));
        HttpResponse res = h.send(req);
        return res.getBody();
    }

    public static List<te_job__c> getJobRecords(Set<String> jrIds){
        List<te_job__c> jobs = new List<te_job__c>();
        jobs = [SELECT id,Reference_Id__c,skills__c,Job_Family_Group__c,Job_Family__c,
        Internal_Posting_URL__c,Job_Title__c ,Job_Description__c,
        Compensation_Grade__c,All_Locations__c,Primary_Location__c
        FROM te_job__c WHERE Reference_Id__c IN:jrIds];
        return jobs; 
    }

    

    @AuraEnabled
    public static reqBody getContactJdVector(string contactId, Boolean fullEmbedding){
        
        List<String> skillList = new List<String>();
        List<reqBody> reqBodyList = new List<reqBody>();
        Contact con;
        //Get current logged in user and worker Id
        String userId = UserInfo.getUserId();
        User usr = [SELECT Id, EmployeeNumber FROM User WHERE Id =: userId];
        String workerId = usr.EmployeeNumber;
        
        //Get Contact Record including preferences
        if(workerId != null){
            con = [SELECT Id, ES_DJC_Grade__c, Talent_Experience_Preference__r.Preferred_Work_Location__c, Talent_Experience_Preference__r.Relocation_Country__c, ES_DJC_Contact_Country__c
                    FROM Contact
                    WHERE EmployeeNumber__c =: workerId];
        }

        //Get Skills
        List<Skill_Assignment__c> skills = [SELECT Skill__c, Skill__r.Name 
            FROM Skill_Assignment__c 
            WHERE Contact__r.EmployeeNumber__c =: workerId];

        for(Skill_Assignment__c s : skills){
            skillList.add(s.Skill__r.Name);
        }
        String skillListString = String.join(skillList,',');
        skillListString = skillListString.replace('&', 'and');
        
        //Get Experience
        String experienceBody = '';
        List<te_Experience__c> listExp = [Select Job_Title__c, Description__c, 
                               		Start_Date__c, End_Date__c 
                                  	FROM te_Experience__c
                                 	WHERE Contact__c =: con.Id];
        for(te_Experience__c e: listExp){
            if(e.Description__c != null){
                experienceBody += e.Description__c.stripHtmlTags();
            }
        }

        List<String> certString = new List<String>();
        List<Certification_Assignment__c> certs = [SELECT Id, Certifications__r.Name FROM Certification_Assignment__c WHERE Contact__c =: con.Id];

        for(Certification_Assignment__c c: certs){
            certString.add(c.Certifications__r.Name);
        }


        //Prep Callout Body
        reqBody body = new reqBody();
        String prompt =  skillListString;
        if(experienceBody != ''){
            prompt += ' ' + experienceBody;
        }
        if(certString.size() > 0){
            prompt +=  ' '+ certString +' ';
        }
        if(fullEmbedding){
            body.inputText = einstein_GPT_Service.returnEmbedding(prompt);
        }else{
            body.inputText = einstein_GPT_Service.returnEmbedding(skillListString);
        }
        body.location = con.Talent_Experience_Preference__r.Preferred_Work_Location__c;
        body.jobGrade = Integer.valueof(con.ES_DJC_Grade__c);
        body.country = con.Talent_Experience_Preference__r.Relocation_Country__c;
        System.debug(body.inputText);

        reqBodyList.add(body);

        System.debug(reqBodyList.size());
        return body;
        
    }

    public static Map<String,String> parseResponseToMap(String json){
        Map<String, Object> m =  (Map<String, Object>)System.JSON.deserializeUntyped(json);
        List<Object> listJobs = (List<Object>)m.get('jobs');
        Map<String,String> mapJRIDtoMatchScore = new Map<String,String>();
        for(Object o : listJobs){
            Map<String, Object> job = (Map<String, Object>)(o);
            mapJRIDtoMatchScore.put(String.valueof(job.get('reference_id')),String.valueof(job.get('match_score')));
        }
        return mapJRIDtoMatchScore;
    }

    public static Integer getExplainability(te_Job__c job, List<String> empSkills){
        Integer explainability;
        
        String textPrompt = 'Given the following list of skills from the job : '+ job.skills__c + '; compare those to this skills the employee has. Employee Skills = ' + String.join(empSkills, ',') + ' Return a numberical value ONLY of how many skills the Employee has that Match the Job Required Skills. You can match the skills on a fuzxy match. Example even if the person does not have the explicit skill but has a similar skill count that. Return only an integer value';
        String response = einstein_GPT_Service.returnGPTResponse(textPrompt);
        explainability = Integer.valueof(response);

        return explainability;
    }

    public static list<string> getSkills(Id ContactId){
        List<String> skillList = new List<String>();
        List<Skill_Assignment__c> skills = [SELECT Id, Skill__r.Name FROM Skill_Assignment__c WHERE Contact__c =: ContactId];
        for(Skill_Assignment__c s: skills){
            skillList.add(s.Skill__r.Name);
        }
        return skillList;
    }

    public class JobWrapper{
        @AuraEnabled
        public te_job__c job { get; set; }
        @AuraEnabled
        public Boolean isSaved { get; set; } 
        @AuraEnabled
        public Integer matchingSkills {get;set;}
    }

    public class reqBody{
        
        @AuraEnabled
        public String inputText {get;set;}

        @AuraEnabled
        public String location {get;set;}

        @AuraEnabled
        public Integer jobGrade {get;set;}

        @AuraEnabled
        public string country {get;set;}
    }
}