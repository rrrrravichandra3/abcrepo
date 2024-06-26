public with sharing class talentMP_CareerPathing {

        @AuraEnabled
        public static List<Job_Group__c> getJobGroup(){
            try{

                List<Job_Group__c> jobGroup = [SELECT Name,Id FROM Job_Group__c ];

                return jobGroup;

            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
           
        }

        @AuraEnabled
        public static List<Job_Family__c> getJobFamily(String jobGroupId){
            try{

                List<Job_Family__c> jobFamilies = [SELECT Name,Id FROM Job_Family__c where Job_Group__c = :jobGroupId ];

                return jobFamilies;

            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
           
        }

        @AuraEnabled
        public static List<Job_Profile__c> getJobProfile(String jobFamilyId){
            try{

                List<Job_Profile__c> jobProfile = [SELECT Name,Id FROM Job_Profile__c where Job_Family__c = :jobFamilyId ];

                return jobProfile;

            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
           
        }

        @AuraEnabled
        public static Map<String,List<Job_Profile__c>> getContactJobProfile(){
            try {
                Map<String,List<Job_Profile__c>> jobsMap = new Map<String,List<Job_Profile__c>>();

                String userId = UserInfo.getUserId();

                User usr = [SELECT Id, EmployeeNumber FROM User WHERE Id =: userId];

                String workerId = usr.EmployeeNumber;
            
                List<Contact> contactResultList = [SELECT Job_Code__c,Job_Family__c,Job_Profile__c,Email,FirstName,LastName,Id,ES_DJC_Grade__c FROM Contact WHERE EmployeeNumber__c = : workerId];

                Contact contactResult = contactResultList.get(0);

                List<Job_Profile__c> getCurrentJobList = [SELECT Job_Category__c,Name,Job_Code__c,Job_Family__r.Name,Job_Grade__c,Job_Template_Number__c,Management_Level__c  FROM Job_Profile__c where Job_Code__c  =  :contactResult.Job_Code__c];

                Job_Profile__c currentJob = getCurrentJobList.get(0);

                jobsMap.put('CurrentJob',getCurrentJobList);

                List<Job_Profile__c> futureJobProfileList =  [SELECT Job_Category__c,Name,Job_Code__c,Job_Family__r.Name,Job_Grade__c,Job_Template_Number__c,Management_Level__c FROM Job_Profile__c where Job_Family__c  = :currentJob.Job_Family__c];
                
                jobsMap.put('FutureJob',futureJobProfileList);
                
                return jobsMap;

            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        @AuraEnabled
        public static List<JobProfileDummy>  getTradiationalCareerPath(){
            try {
                String userId = UserInfo.getUserId();
                Map<String, List<Job_Career_Path__c>> parentJobMap = new Map<String, List<Job_Career_Path__c>>();

                Map<String, List<Job_Career_Path__c>> allJobsCareerMap = new Map<String, List<Job_Career_Path__c>>();

                User usr = [SELECT Id, EmployeeNumber FROM User WHERE Id =: userId];

                String workerId = usr.EmployeeNumber;
            
                List<Contact> contactResultList = [SELECT Job_Code__c,Job_Family__c,Job_Profile__c,Email,FirstName,LastName,Id,ES_DJC_Grade__c FROM Contact WHERE EmployeeNumber__c = : workerId];

                Contact contactResult = contactResultList.get(0);


                allJobsCareerMap.put('CurrentJob',new List<Job_Career_Path__c>());
                Job_Career_Path__c currentJob = new Job_Career_Path__c();
                currentJob.Releasing_Job_Code__c = contactResult.Job_Code__c;

                currentJob.Receiving_Job_Code__c = contactResult.Job_Code__c;
                currentJob.freq__c = 0;

                allJobsCareerMap.get('CurrentJob').add(currentJob);

                

                List<Job_Career_Path__c> mainFutureJobList = getCareerPathFutureJobs(currentJob.Receiving_Job_Code__c,3,allJobsCareerMap);
                
                allJobsCareerMap.put(contactResult.Job_Code__c,new List<Job_Career_Path__c>());

                allJobsCareerMap.get(contactResult.Job_Code__c).addall(mainFutureJobList);

                for(Job_Career_Path__c mainFutureJob : mainFutureJobList){

                    String key = mainFutureJob.Receiving_Job_Code__c;
                    if (!allJobsCareerMap.containsKey(key)) {
                    
                        allJobsCareerMap.put(mainFutureJob.Receiving_Job_Code__c,new List<Job_Career_Path__c>());
                    }

                    List<Job_Career_Path__c> futureJobMainList =  getCareerPathFutureJobs(mainFutureJob.Receiving_Job_Code__c,2,allJobsCareerMap);
                    for(Job_Career_Path__c futureJobListToCheck : futureJobMainList){
                        if(!allJobsCareerMap.containsKey(futureJobListToCheck.Receiving_Job_Code__c)){
                            allJobsCareerMap.get(mainFutureJob.Receiving_Job_Code__c).add(futureJobListToCheck);
                        }
                    }
                    
                }



                Map<String, List<Job_Career_Path__c>> allJobsCareer2Map = new Map<String, List<Job_Career_Path__c>>();

                for(String key : allJobsCareerMap.keySet()){
                    List<Job_Career_Path__c> values = allJobsCareerMap.get(key);
                    for(Job_Career_Path__c value : values){
                        String key2 = value.Receiving_Job_Code__c;
                        if (!allJobsCareer2Map.containsKey(key2)) {
                            allJobsCareer2Map.put(value.Receiving_Job_Code__c,new List<Job_Career_Path__c>());
                        }
                        if(key != 'CurrentJob' && key != contactResult.Job_Code__c){
                            List<Job_Career_Path__c> futureJob2List =  getCareerPathFutureJobs(value.Receiving_Job_Code__c,2,allJobsCareerMap);
                            System.debug('Key: ' + key + ' Value: ' + value);
                          
                            for(Job_Career_Path__c futureJobListToCheck : futureJob2List){
                                if(!allJobsCareer2Map.containsKey(futureJobListToCheck.Receiving_Job_Code__c) && !allJobsCareerMap.containsKey(futureJobListToCheck.Receiving_Job_Code__c)){
                                    allJobsCareer2Map.get(value.Receiving_Job_Code__c).add(futureJobListToCheck);
                                }
                            }
                            
                        }
                }

                for(String mainkey: allJobsCareer2Map.keySet()) {

                    if (!allJobsCareerMap.containsKey(mainkey)) {
                    
                        allJobsCareerMap.put(mainkey,allJobsCareer2Map.get(mainkey));

                    }else{
                        
                        List<Job_Career_Path__c> mainList = allJobsCareerMap.get(mainkey);
                        allJobsCareerMap.get(mainkey).addAll(allJobsCareer2Map.get(mainkey));
                    }

                    }
                }

                for (String mainKey : allJobsCareerMap.keySet()) {
                    List<Job_Career_Path__c> mainList = allJobsCareerMap.get(mainKey);
                    List<Job_Career_Path__c> uniqueList = new List<Job_Career_Path__c>();
                
                    for (Job_Career_Path__c job : mainList) {
                        Boolean isDuplicate = false;
                
                        for (Job_Career_Path__c existingJob : uniqueList) {
                            if (existingJob.Receiving_Job_Code__c == job.Receiving_Job_Code__c) {
                                isDuplicate = true;
                                break;
                            }
                        }
                
                        if (!isDuplicate) {
                            uniqueList.add(job);
                        }
                    }
                
                    allJobsCareerMap.put(mainKey, uniqueList);
                }

                System.debug('Career Map');

                System.debug(allJobsCareerMap.get('CurrentJob'));

                System.debug(allJobsCareerMap.get(contactResult.Job_Code__c));

                

                List<Job_Career_Path__c> allJobsCareerList = new List<Job_Career_Path__c>();

                for (List<Job_Career_Path__c> jobList : allJobsCareerMap.values()) {
                    allJobsCareerList.addAll(jobList);
                }
                
                Set<Id> uniqueJobIds = new Set<Id>();
                List<Job_Career_Path__c> uniqueJobsList = new List<Job_Career_Path__c>();
                
                for (Job_Career_Path__c job : allJobsCareerList) {
                    if (!uniqueJobIds.contains(job.Id)) {
                        uniqueJobIds.add(job.Id);
                        uniqueJobsList.add(job);
                    }
                }
                List<JobProfileDummy> jobs = new List<JobProfileDummy>();

                for (Job_Career_Path__c jobCareerPath : uniqueJobsList) {
                    JobProfileDummy jobProfile = new JobProfileDummy(jobCareerPath.Receiving_Job_Code__c,null, null,null);
                    jobProfile.id = jobCareerPath.Receiving_Job_Code__c;
                    jobProfile.parentId = jobCareerPath.Releasing_Job_Code__c;
                    jobProfile.frequency = Integer.valueOf(jobCareerPath.freq__c);
                    
                    jobs.add(jobProfile);
                }

                for(JobProfileDummy job: jobs){
                    if(job.id == job.parentId){
                        job.parentId = null;
                    }
                }

                jobs = removeDuplicateValuesInList(jobs);

                

                /* for (Integer i = 0; i < jobs.size(); i++) {
                    JobProfileDummy job = jobs.get(i);
                
                    for (Integer j = i + 1; j < jobs.size(); j++) {
                        JobProfileDummy compareJob = jobs.get(j);
                
                        if (job.Id == compareJob.Id) {
                            jobs.remove(j);
                            j--;  // Decrement j to compensate for the removal
                        }
                    }
                } */
                /* Set<String> jobCodes = new Set<String>();
                
                for (Job_Career_Path__c jobCareerPath : getCareerPathList) {
                    jobCodes.add(jobCareerPath.Receiving_Job_Code__c);
                }

                jobCodes.add(contactResult.Job_Code__c);

                System.debug(jobCodes);

                
                List<Job_Profile__c> jobProfileList =  [SELECT Job_Category__c,Name,Job_Code__c,Job_Family__r.Name,Job_Grade__c,Job_Template_Number__c,Management_Level__c FROM Job_Profile__c where Job_Code__c IN :jobCodes];
                
                List<JobProfileDummy> jobs = new List<JobProfileDummy>();
                
                for (Job_Profile__c jobProfile : jobProfileList) {
                    
                    System.debug('Job Code: ' +jobProfile.Job_Code__c +' :: name :: '+ jobProfile.Name + ', Grade :: ' + jobProfile.Job_Grade__c );
                    jobs.add(new JobProfileDummy(jobProfile.Job_Code__c,jobProfile.Name, Integer.valueOf(jobProfile.Job_Grade__c),'A'));
                
                }

                for (Job_Career_Path__c receivingJob : getCareerPathList) {
                    String key = receivingJob.Receiving_Job_Code__c;
                    if (!parentJobMap.containsKey(key)) {
                            parentJobMap.put(key, new List<Job_Career_Path__c>());
                    }
                    parentJobMap.get(key).add(receivingJob);
                    
                }
                System.debug(parentJobMap);

                for(JobProfileDummy job : jobs){
                    System.debug('Enter-->'+job.jobCode);
                    if(job.jobCode == contactResult.Job_Code__c){
                        job.id = job.jobCode;
                        job.parentId = null;
                        job.freq = 0;
                    }else{
                        List<Job_Career_Path__c> jobCareerPaths = parentJobMap.get(job.jobCode);
                        Job_Career_Path__c jobCareerPath = jobCareerPaths[0];
                        System.debug('Job Code1: ' +jobCareerPath.Receiving_Job_Code__c +' :: Job Code2 :: '+ jobCareerPath.Releasing_Job_Code__c );
                        job.id = job.jobCode;
                        job.parentId = jobCareerPath.Releasing_Job_Code__c;
                        job.freq = Integer.valueOf(jobCareerPath.freq__c) ;
                    }
                    
                    System.debug('Job Code: ' +job.jobCode +', id ::'+ job.id +' , parentid :: '+ job.parentId + ', Freq:: ' + job.freq);

                }
                
                jobs.sort(new JobFreqComparator());
                List<JobProfileDummy> newFutureJobs = new List<JobProfileDummy>();
                
                for(JobProfileDummy job : jobs){
                    System.debug('Enter-->'+job.jobCode);
                    if(job.jobCode != contactResult.Job_Code__c){
                        newFutureJobs.addall(getCareerPathFutureJobs(job.jobCode,2));
                    }
                }
                jobs.addAll(newFutureJobs); */

                return jobs;


                

            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        public static List<JobProfileDummy> removeDuplicateValuesInList(List<JobProfileDummy> jobList) {
            try {
                Set<String> uniqueValuesSet = new Set<String>();
        
                List<JobProfileDummy> uniqueJobList = new List<JobProfileDummy>();
        
                for (JobProfileDummy job : jobList) {
                    String uniqueValue = job.jobCode;
                    if (!uniqueValuesSet.contains(uniqueValue)) {
                        uniqueValuesSet.add(uniqueValue);
                        uniqueJobList.add(job);
                    }
                }

                List<Job_Profile__c> jobProfileList =  [SELECT Job_Category__c,Name,Job_Code__c,Job_Family__r.Name,Job_Grade__c,Job_Template_Number__c,Management_Level__c FROM Job_Profile__c where Job_Code__c IN :uniqueValuesSet];

                for(JobProfileDummy job : uniqueJobList){
                    for(Job_Profile__c jobProfile1 : jobProfileList){
                        if(job.jobCode == jobProfile1.Job_Code__c){
                            job.jobName = jobProfile1.Name;
                            job.grade = Integer.valueOf(jobProfile1.Job_Grade__c);
                            
                        }
                            
                }
            }
        
                return uniqueJobList;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        public static List<Job_Career_Path__c> getCareerPathFutureJobs(String receivingJob,Integer freq_max,Map<String,List<Job_Career_Path__c>> excludeJobsMap){
            try{
                List<String> excludeJobs = new List<String>();
                for (String key : excludeJobsMap.keySet()) {
                    excludeJobs.add(key);
                }
                System.debug('freq'+freq_max + ' ::: jobs :::'+ excludeJobs);

                List<Job_Career_Path__c> getCareerPathList = [SELECT Releasing_Job_Code__c , Receiving_Job_Code__c , freq__c FROM Job_Career_Path__c where Releasing_Job_Code__c  =  :receivingJob and Receiving_Job_Code__c not in :excludeJobs order by freq__c desc];
                
                
                List<Job_Career_Path__c> filteredList = new List<Job_Career_Path__c>();


                for (Integer i = 0; i < Math.min(getCareerPathList.size(), freq_max); i++) {
                    filteredList.add(getCareerPathList[i]);
                }

                return filteredList;

            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }

        }

        @AuraEnabled
        public static List<JobProfileDummy> getCareerPaths(String currentJobCode,String futureLateralJobCode){
            try {

                String userId = UserInfo.getUserId();

                User usr = [SELECT Id, EmployeeNumber FROM User WHERE Id =: userId];

                String workerId = usr.EmployeeNumber;
            
                List<Contact> contactResultList = [SELECT Job_Code__c,Job_Family__c,Job_Profile__c,Email,FirstName,LastName,Id,ES_DJC_Grade__c FROM Contact WHERE EmployeeNumber__c = : workerId];

                Contact contactResult = contactResultList.get(0);

                System.debug('Job Code' + contactResult.Job_Code__c + ' <---> Job Family ' + contactResult.Job_Family__c + ' <---> Job Profile' + contactResult.Job_Profile__c );

                List<Job_Profile__c> getJobCodeFamilylist = [SELECT Job_Family__c  FROM Job_Profile__c where Job_Code__c  =  :contactResult.Job_Code__c];

                Job_Profile__c jobCodeFamilyResult = getJobCodeFamilylist.get(0);

                List<Job_Profile__c> jobProfileList =  [SELECT Job_Category__c,Name,Job_Code__c,Job_Family__r.Name,Job_Grade__c,Job_Template_Number__c,Management_Level__c FROM Job_Profile__c where Job_Family__c  = :jobCodeFamilyResult.Job_Family__c];

                List<JobProfileDummy> jobs = new List<JobProfileDummy>();

                for(Job_Profile__c jobProfile : jobProfileList){

                    if(jobProfile.Job_Category__c == 'C'){
                        jobs.add(new JobProfileDummy(jobProfile.Job_Code__c,jobProfile.Name, Integer.valueOf(jobProfile.Job_Grade__c),'C'));
                    }else{
                        jobs.add(new JobProfileDummy(jobProfile.Job_Code__c,jobProfile.Name, Integer.valueOf(jobProfile.Job_Grade__c),'P'));
                    }
                    
                }

                jobs.sort(new JobProfileComparator());
                
                jobs = getJobPath(jobs,currentJobCode,futureLateralJobCode);

                return jobs;
                
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } 




    @AuraEnabled
    public static List<JobProfileDummy> getJobPath(List<JobProfileDummy> jobs,String currentJobCode,String futureLateralJobCode){
        try {

            Map<Integer, List<JobProfileDummy>> parentJobMap = new Map<Integer, List<JobProfileDummy>>();

            

            JobProfileDummy currentJob = new JobProfileDummy('','',0,'');
            JobProfileDummy futureLateralJob = new JobProfileDummy('','',0,'');

            for(JobProfileDummy job: jobs){
                if(currentJobCode == job.jobCode){
                    currentJob = job;
                }else if(futureLateralJobCode == job.jobCode){
                    futureLateralJob = job;
                }
            }


            Integer i = 0;
            while (i < jobs.size()){
                if( jobs.get(i).grade <= currentJob.grade && jobs.get(i).jobCode != currentJob.jobCode && jobs.get(i).jobCode != futureLateralJob.jobCode){
                    jobs.remove(i);
                }else if(futureLateralJob.jobCode == '' && jobs.get(i).category != currentJob.category){
                    jobs.remove(i);
                }else{
                    i ++;
                }
                    
            }
            
            
            for (JobProfileDummy job : jobs) {
                    Integer key = job.grade;
                    if (!parentJobMap.containsKey(key)) {
                            parentJobMap.put(key, new List<JobProfileDummy>());
                    }
                    parentJobMap.get(key).add(job);
                    
            }

            if(futureLateralJob.jobCode != null && futureLateralJob.jobCode != ''){
                jobs = getAllJobsLateral(jobs,parentJobMap,currentJob,futureLateralJob);
            }else{

                jobs = getAllJobs(jobs,parentJobMap,currentJob);
            }
            
            

            for (JobProfileDummy job : jobs) {
                    System.debug('Job Code: ' +job.jobCode +' :: id :: '+ job.jobName + ', Grade: ' + job.grade + ', Parent Job Code: ' + job.parentId);
                } 
            return jobs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
}

public static List<JobProfileDummy> getAllJobsLateral(List<JobProfileDummy> jobs,Map<Integer, List<JobProfileDummy>> parentJobMap,
JobProfileDummy currentJob,JobProfileDummy futureLaterJob){
    
    
    for (JobProfileDummy job : jobs) {

        job.id = job.jobCode;
        Integer key = job.grade-1;

        if(currentJob.jobCode == job.jobCode) {
            job.parentId = null;
        }else if(job.jobCode ==  futureLaterJob.jobCode){
            job.parentId = currentJob.jobCode;
        }else{
            if(parentJobMap.containsKey(key)) {
                List<JobProfileDummy> parentJobs = parentJobMap.get(key);

                if (parentJobs.size() == 2) {
                    if(job.category == 'C'){
                        job.parentId = parentJobs[0].jobCode;
                    }else if(job.category == 'P'){
                        job.parentId = parentJobs[1].jobCode;
                    }
                } else {
                    job.parentId = parentJobs[0].jobCode;
                }

            }
        }
            

    }

    return jobs;
}

public static List<JobProfileDummy> getAllJobs(List<JobProfileDummy> jobs,Map<Integer, List<JobProfileDummy>> parentJobMap,JobProfileDummy currentJob){
    
    
    for (JobProfileDummy job : jobs) {
        job.id = job.jobCode;

        Integer key = job.grade-1;

            if (parentJobMap.containsKey(key)) {
                List<JobProfileDummy> parentJobs = parentJobMap.get(key);

                job.parentId = parentJobs[0].jobCode;

            }else {
                if(currentJob.jobCode == job.jobCode){
                    job.parentId = null;
                }else{
                    job.parentId = currentJob.jobCode;
                }
                
            }
        }

    return jobs;
}




public class JobProfileDummy{
  

    public JobProfileDummy (String jobCode,String jobName, Integer grade, String category) {

        this.jobCode = jobCode;
        this.jobName = jobName;
        this.grade = grade;
        this.category = category;
        this.parentId = null;
        this.frequency = 0;
    }

    @AuraEnabled
    public String id {get; set;}

    @AuraEnabled
    public String jobCode {get; set;}

    @AuraEnabled
    public String jobName {get; set;}

    @AuraEnabled
    public Integer grade {get; set;}

    @AuraEnabled
    public String category {get; set;}

    @AuraEnabled
    public Integer frequency {get; set;}

    @AuraEnabled
    public String parentId {get; set;}

}


public class JobProfileComparator implements Comparator<JobProfileDummy> {
    public Integer compare(JobProfileDummy o1, JobProfileDummy o2) {
        
        Integer returnValue = 0;
        
        if(o1 == null && o2 == null) {
            returnValue = 0;
        } else if(o1 == null) {
           
            returnValue = -1; 
        } else if(o2 == null) {
           
            returnValue = 1;
        } else if ((o1.Grade == null) && (o2.Grade == null)) {
            
            returnValue = 0;
        } else if (o1.Grade == null){
            
            returnValue = -1;
        } else if (o2.Grade == null){
            
            returnValue = 1;
        } else if (o1.Grade < o2.Grade) {
            
            returnValue = -1;
        } else if (o1.Grade > o2.Grade) {
            
            returnValue = 1;
        }
        return returnValue;
    }
}

}