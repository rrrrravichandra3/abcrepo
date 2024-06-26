public with sharing class PF_NHW_JobAppStore {
    
    
    /**
     * 
     * @param Set<Id> userIds   Set of ids of Hire Manager users
     * @param Set<String> candidateStages set of candidate stages
     * @param Boolean includeDelegates true if you want to get the job Applicationns of the user's manafers if the user is it's delegate
     * @return Map<Id, List<WDR_Application__c>> mapUsersJobApps key is the id of the user, value the list of it's job apps
	**/
    public static Map<Id, List<WDR_Application__c>> getJobApplicationsInGivenStagesOwnedByHMUsers(Set<Id> userIds, Set<String> candidateStages, Boolean includeDelegates){
        if(includeDelegates==TRUE){
            return getJobApplicationsInGivenStagesOwnedByHMUsersWithDelegate(userIds,candidateStages);
        }
        //if someone passes null, we assume they want only direct HM functionality. So null and false will call below method
        else{
            return getJobApplicationsInGivenStagesOwnedByHMUsersNoDelegate(userIds,candidateStages);
        }
    }

    public static Map<Id, List<WDR_Application__c>> getJobApplicationsInGivenStagesOwnedByHMUsersWithDelegate(Set<Id> userIds, Set<String> candidateStages){
        Map<Id, List<WDR_Application__c>> mapUsersJobApps = new Map<Id, List<WDR_Application__c>>();
         
        Set<Id> contactIdSet = new set<Id>();
        
        List<User> users = [SELECT Name, Email FROM User WHERE Id IN : userIds];
        
        List<String> usrEmails = new List<String>();
        
        Set<Id> lUserIds = new Set<Id>();
        lUserIds.addAll(userIds);
        
        for(User u : users){
            usrEmails.add(u.Email);
        }
        
        List<User> userList = [SELECT Id, ContactId FROM User WHERE Email IN :usrEmails];
        
        for (User u1 : userList) {
            
            lUserIds.add(u1.Id);
            if (u1.ContactId != null) {
                contactIdSet.add(u1.ContactId);
            }
        }
        
        
        //if the user is a delegate, find it's managers
            List<Delegate__c> delegates = [SELECT Id, Name, Delegate__r.Name, Manager__c, Manager__r.Name
                                           FROM Delegate__c 
                                           WHERE Delegate__c IN :contactIdSet];
            
            List<String> managers = new List<String>();
            
            if(!delegates.isEmpty()){
                for(Delegate__c d : delegates){
                    managers.add(d.Manager__c);
                }
                                
                List<User> managersUsersIds = [SELECT Id FROM User WHERE ContactId IN :managers];
                
                for(User mangerUsr : managersUsersIds){
                    lUserIds.add(mangerUsr.Id);
                }
                            
            }
        
        mapUsersJobApps = getJobApplicationsInGivenStagesOwnedByHMUsersNoDelegate(lUserIds, candidateStages);
        
        return mapUsersJobApps;
        //this includes current set of users (passed as parameters) as well as job apps of other managers
        //who listed these users as their delegates
    }

    public static Map<Id, List<WDR_Application__c>> getJobApplicationsInGivenStagesOwnedByHMUsersNoDelegate(Set<Id> userIds, Set<String> candidateStages){
        Map<Id, List<WDR_Application__c>> mapUsersJobApps = new Map<Id, List<WDR_Application__c>>();
        
        
        List<WDR_Application__c> listJobApps = [SELECT Id, Name, Application__c, Candidate__r.Name, Job_Code__c, Job_Title__c, Job__r.Hiring_Manager__c
                                                FROM WDR_Application__c 
                                                WHERE Candidate_Stage__c IN :candidateStages
                                               	AND Job__r.Hiring_Manager__c IN :userIds];
        
        for(WDR_Application__c app : listJobApps){
            if(app.Job__r.Hiring_Manager__c == null){
            	continue;
            }
            
            Id usrId = app.Job__r.Hiring_Manager__c;
            if(!mapUsersJobApps.containsKey(usrId)){
            	mapUsersJobApps.put(usrId, new List<WDR_Application__c>());
            }
            mapUsersJobApps.get(usrId).add(app);
        }
        
        
        return mapUsersJobApps;
    }

}