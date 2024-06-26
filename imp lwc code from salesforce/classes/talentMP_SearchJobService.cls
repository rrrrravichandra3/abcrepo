/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 02-08-2024
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class talentMP_SearchJobService {

    @AuraEnabled
    public static JobSearchResultWrapper getJobs(Integer pageNumber, String filterValues, String contactId){
        String filterWhereClause;
        if(filterValues != null){
            filterValues = String.escapeSingleQuotes(filterValues);
            filterWhereClause = processFilterValues(filterValues);
        }
    
        JobSearchResultWrapper jobSearchResult = new JobSearchResultWrapper();
        List<JobWrapper_SearchList> seachJobsList = new List<JobWrapper_SearchList>();
        Integer pageSize = 10;
        Integer totalCount = 0;
        String searchQuery = 'SELECT count() FROM te_Job__c';
        if(filterWhereClause != null){
            searchQuery += filterWhereClause;
        }
        try {
            totalCount = Database.countQuery(searchQuery);

            // Calculate the starting index
            Integer startIndex = (pageNumber - 1) * pageSize;
            
            String paginatedJobSearchQuery = 'SELECT Id, Reference_ID__c, Name, Primary_Location__c, All_Locations__c, Job_Family_Group__c,Job_Title__c FROM te_Job__c';
            if(filterWhereClause != null){
                paginatedJobSearchQuery += filterWhereClause;
            }

            paginatedJobSearchQuery += ' ORDER BY lastmodifieddate DESC LIMIT :pageSize OFFSET :startIndex';

            
            List<Id> saveJobIds = getSavedJobsForUser(contactId);

            for(te_Job__c job : Database.query(paginatedJobSearchQuery)) {
                JobWrapper_SearchList jobData = transformJobData(job);
                jobData.isSaved = false; 
                if(!saveJobIds.isEmpty() && saveJobIds.contains(job.Id)){
                    jobData.isSaved = true; 
                }

                seachJobsList.add(jobData);
            }

            jobSearchResult.totalCount = totalCount;
            jobSearchResult.jobList = seachJobsList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return jobSearchResult;
    }

    
    @AuraEnabled
    public static List<JobWrapper_SearchList> getSavedJobs(String contactId){
        List<Id> savedJobJobIds = getSavedJobsForUser(contactId);
        List<JobWrapper_SearchList> seachJobsList = new List<JobWrapper_SearchList>();
        List<te_Job__c> savedJobJobs = new List<te_Job__c>();
        savedJobJobs = [SELECT Id, Reference_ID__c, Name, Primary_Location__c, All_Locations__c, Job_Family_Group__c
                        FROM te_Job__c
                        WHERE Id IN: savedJobJobIds];

        for(te_Job__c job : savedJobJobs){
            JobWrapper_SearchList jobData = transformJobData(job);
            jobData.isSaved = true; 
            //jobData.savedJobRecId = savedjob.Id;

            seachJobsList.add(jobData); 
        }
        return seachJobsList;
    }

    public static List<Id> getSavedJobsForUser(String contactId){
        List<Id> savedJobJobIds = new List<Id>();
        for(te_SavedJob__c savedJob : [SELECT job__c
                FROM te_SavedJob__c
                WHERE Contact__c = :contactId]){
            savedJobJobIds.add(savedJob.job__c);
        }
        return savedJobJobIds;
    }

    public static String processFilterValues( String filterValues){
        Map<String, Object> filterMap = (Map<String, Object>) JSON.deserializeUntyped(filterValues);
        String filterWhereClause;

        if(!filterMap.isEmpty()){
            filterWhereClause = ' WHERE ';
        }

        if(filterMap.containsKey('searchKeyword')){
            String nameFilter = '%' + filterMap.get('searchKeyword') + '%';
            filterWhereClause += 'Name LIKE \'' + nameFilter + '\'';
        }
        if(filterMap.containsKey('jobFamilyGroup')){
            String jobFamilyGroupFilter = (String)filterMap.get('jobFamilyGroup');
            if (filterWhereClause.length() == 7) {
                filterWhereClause += 'Job_Family_Group__c = \'' + jobFamilyGroupFilter + '\'';
            } else {
                filterWhereClause += ' AND Job_Family_Group__c = \'' + jobFamilyGroupFilter + '\'';
            }
        }
        if(filterMap.containsKey('country')){
            String countryFilter = (String)filterMap.get('country');
            if (filterWhereClause.length() == 7) {
                filterWhereClause += 'Country__c = \'' + countryFilter + '\'';
            } else {
                filterWhereClause += ' AND Country__c = \'' + countryFilter + '\'';
            }
        }

        return filterWhereClause;
    }

    @AuraEnabled
    public static te_Job__c getJobDetails(String jobId){
        te_Job__c jobDetail = new te_Job__c();

        try {
            if(jobId != null)
            jobDetail =  [SELECT Job_Family_Group__c, Internal_Posting_URL__c, All_Locations__c, Reference_ID__c, skills__c, Job_Description__c, Name, Job_Title__c
                    FROM te_Job__c
                    WHERE Reference_ID__c = :jobId][0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return jobDetail;
    }

    @AuraEnabled(cacheable=true)
    public static FiltersWrapper getFilterValues() {
        List<String> jobFamilyGroups = new List<String>();
        List<String> countryValues = new List<String>();
        
        try {
            List<AggregateResult> jfResults = [SELECT Job_Family_Group__c
                                             FROM te_Job__c 
                                             WHERE Job_Family_Group__c != null
                                             GROUP BY Job_Family_Group__c];
            for (AggregateResult result : jfResults) {
                String jobFamilyGroup = (String)result.get('Job_Family_Group__c');
                jobFamilyGroups.add(jobFamilyGroup);
            }

            List<AggregateResult> countryResults = [SELECT Country__c
                                             FROM te_Job__c 
                                             WHERE Country__c != null
                                             GROUP BY Country__c];
            for (AggregateResult result : countryResults) {
                String country = (String)result.get('Country__c');
                countryValues.add(country);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        FiltersWrapper ob = new FiltersWrapper();
        ob.countryValues = countryValues;
        ob.jobFamilyGroups = jobFamilyGroups;
        
        return ob;
    }

    @AuraEnabled
    public static void createSavedJobRecord(Id contactId, Id jobId) {
        try{
            te_SavedJob__c savedJob = new te_SavedJob__c();
            savedJob.Contact__c = contactId;
            savedJob.Job__c = jobId;
            insert savedJob;
        }
        catch (Exception e) {
            throw new AuraHandledException('Error saving job: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteSavedJobRecord(Id contactId, Id jobId) {
        try{
        delete [SELECT ID
                FROM te_SavedJob__c
                WHERE Contact__c = :contactId AND Job__c = :jobId];
        }
        catch (Exception e) {
            throw new AuraHandledException('Error removing job from list of saved jobs: ' + e.getMessage());
        }
    }

    private static JobWrapper_SearchList transformJobData(te_Job__c job){
        Integer totalLocations = 1;
        if(String.isNotBlank(job.All_Locations__c)){
            totalLocations = job.All_Locations__c.split('\n\n').size();
        }

        JobWrapper_SearchList jobData = new JobWrapper_SearchList();
        jobData.sfId = job.Id;
        jobData.referenceId = job.Reference_ID__c;
        jobData.jobFamilyGroup = job.Job_Family_Group__c;
        jobData.title = job.Job_Title__c;
        jobData.primaryLoacation = job.Primary_Location__c;
        jobData.totalLocations = totalLocations;
        return jobData;
    }

    @AuraEnabled
    public static String getEinsteinJobInsights(String contactId, List<String> employeeSkills, String jobId){
        String insightResponse;
        try {
            Set<String> certNames = getContactCertifications(contactId);
            List<ExperienceWrapper> experiences = getContactExperiences(contactId);

            te_Job__c jobDetails = getJobDetails(jobId);
            String jobDescription = jobDetails.Job_Description__c;
            String insightPrompt = 'Ensure the language you response is in the style of Salesforce and you are referencing the employee using gender neutral pronouns. Instead of saying "The Employee", use "You" and reference the person directly like you are having a conversation. ';
            if(!employeeSkills.isEmpty()){
                insightPrompt += 'Given Employee Skills: [' + employeeSkills + ']';
            }
            if(!certNames.isEmpty()){
                insightPrompt += 'Given Employee Certification Credentials Named: [' + certNames + ']';
            }
            if(!experiences.isEmpty()){
                insightPrompt += 'Given Employee Current and Past Experiences with title and description: [' + experiences + ']';
            }

            insightPrompt += 'Job Description: [' + jobDescription + ']';
            insightPrompt += 'Insights: 1. Match Strength: [Match Quality between Employee and Job.] - Evaluate the overall match strength between the employee skills, employee certifications, employee experiences and the job description. If position is a Management role take into consideration past history of People Management. Limit to 1 bullet point. 2. Improvement Areas: [Suggestions for improvement] - Recommend specific areas where the employee can enhance their skills for a better match. Limit to 2 bullet points. 3. Additional Notes: [Any additional comments or observations] - Limit to 2 bullet points.';
            System.debug('Prompt-->>'+insightPrompt);
            insightResponse = einstein_GPT_Service.returnGPTResponse(insightPrompt);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return insightResponse;
    }

    public static Set<String> getContactCertifications(String contactId){
        Set<String> certNames = new Set<String>();
        for(Certification_Assignment__c cert : [SELECT Certifications__r.Name
                    FROM Certification_Assignment__c
                    WHERE Contact__c =: contactId]){
                        certNames.add(cert.Certifications__r.Name);
                    }
        return certNames;
    }

    public static List<ExperienceWrapper> getContactExperiences(String contactId){
        List<ExperienceWrapper> experiences = new List<ExperienceWrapper>();
        for(te_Experience__c exp : [SELECT Job_Title__c, Description__c
                    FROM te_Experience__c
                    WHERE Contact__c =: contactId]){
                        experiences.add(new ExperienceWrapper(exp.Job_Title__c, exp.Description__c));
                    }
        return experiences;
    }

    public class EinsteinJobInsightWrapper{
        @AuraEnabled
        public String matchStrength { get; set; }
        @AuraEnabled
        public String improvementAreas { get; set; }
        @AuraEnabled
        public String AdditonalNotes { get; set; }
    }

    public class FiltersWrapper{
        @AuraEnabled
        public List<String> jobFamilyGroups { get; set; }
        @AuraEnabled
        public List<String> countryValues { get; set; }
    }

    public class JobWrapper_SearchList{
        @AuraEnabled
        public Id sfId { get; set; }
        @AuraEnabled
        public String referenceId { get; set; }
        @AuraEnabled
        public String jobFamilyGroup { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String primaryLoacation { get; set; }
        @AuraEnabled
        public Integer totalLocations { get; set; }
        @AuraEnabled
        public Boolean isSaved { get; set; } 
        @AuraEnabled
        public Id savedJobRecId { get; set; } 
    }

    public class JobSearchResultWrapper{
        @AuraEnabled
        public Integer totalCount {get; set;}
        @AuraEnabled
        public List<JobWrapper_SearchList> jobList {get; set;}
    }

    public class ExperienceWrapper {
        string experienceTitle;
        string experienceDescription;

        public ExperienceWrapper(string experienceTitle, string experienceDescription){
            this.experienceTitle = experienceTitle;
            this.experienceDescription = experienceDescription;
        }
    }
}