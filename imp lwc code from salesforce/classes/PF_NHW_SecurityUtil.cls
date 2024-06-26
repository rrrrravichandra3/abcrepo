public with sharing class PF_NHW_SecurityUtil {
    
    public static Set<Id> userIds{
        get{
            if(userIds == null){
                userIds = new set<Id>();
                userIds.add(UserInfo.getUserId());
                
                Set<Id> contactIdSet = new set<Id>();
                Set<String> managerEmailSet = new set<String>();
                User u = [Select Id, Email From User Where Id =: UserInfo.getUserId()];
                
                for (User u1 : [Select Id, ContactId From User Where Email =: u.Email]) {
                    userIds.add(u1.Id);
                    if (u1.ContactId != null) {
                        contactIdSet.add(u1.ContactId);
                    }
                }
                
                for (Delegate__c d : [Select Id, Manager__r.Email From Delegate__c Where Delegate__c IN :contactIdSet And Type__c = 'New Hire Wizard']) {
                    if (d.Manager__r.Email != null) {
                        managerEmailSet.add(d.Manager__r.Email);
                    }                   
                }
                
                for (User u1 : [Select Id, ContactId From User Where Email IN :managerEmailSet]) {
                    userIds.add(u1.Id);
                }
            }
            return userIds;
        }
        private set;
    }

    public static Set<String> userEmails{
        get{
            if(userEmails == null){
                Set<Id> hmAndDelegateIds = userIds;
                           userEmails = new Set<String>();
                            for(User u1 : [Select Id, Email from User Where Id IN:hmAndDelegateIds]){
                                userEmails.add(u1.Email);
                }
            }

            return userEmails;
        }
        private set;
    }
    
    public static void checkUserHasAccessToCase(Case nhwCase){

        Boolean userHasAccess = false;
        
        if(nhwCase != null && !String.isBlank(nhwCase.Id)){
            
            if(nhwCase.NHW_Employee_Type__c == PF_NHW_Process.CONTRACTOR.name
               || nhwCase.NHW_Employee_Type__c == PF_NHW_Process.RELOCATION.name){
                   userHasAccess = userIds.contains(nhwCase.CreatedById) || userIds.contains(nhwCase.LastModifiedById) || userEmails.contains(nhwCase.Manager_s_Email__c);
               }else{                   
                   userHasAccess = userIds.contains(nhwCase.NHW_Job_Application__r.Job__r.Hiring_Manager__c) ||
                        userEmails.contains(nhwCase.Manager_s_Email__c);
               }
            //If it is a case associated with SVP Job req, and current logged in user is member of executive oboarding team, provide access
            if(
                (nhwCase.NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c == true)
                &&
                (NHW_Util.isCurrentUserExecutive())
                ){
                userHasAccess = true;               
            }
        }else{
            return;
        }
        
        if(!userHasAccess){
            throw new AuraHandledException('Access to case denied');
        }
    }    
}