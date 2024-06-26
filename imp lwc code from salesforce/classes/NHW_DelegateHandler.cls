@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class NHW_DelegateHandler{

   private static final Id nhwCaseRecordTypeOnboardingId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId();
   private static final Id nhwCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process').getRecordTypeId();

   public static void updateKeyValue(List<Delegate__c> triggerNew){
     
      for(Delegate__c del : triggerNew){
         if(del.Manager__c!=null && del.Delegate__c!=null ){
           del.key__c= String.valueOf(del.Delegate__c)+String.valueOf(del.Manager__c)+String.valueOf(del.NHW_Is_NWH_Admin__c);
         }
      }
   }
   
   public static void updateDelegateEmail(List<Delegate__c> triggerNew){
        Set<Id> setManagerId = new Set<Id>();
        List<Case> caseList = new List<Case>();
        Map<Id, string> delegateMap = new Map<Id, String>();
 
       for(Delegate__c delegate: triggerNew){
           if(string.isNotBlank(delegate.Manager__c)){          
               setManagerId.add(delegate.Manager__c);
           }
       }  
       
       for(Delegate__c del: [SELECT Id, Manager__c, Delegate__c, Delegate__r.Email 
                             FROM delegate__c 
                             WHERE Manager__c IN: setManagerId])
       {
           if(string.isNotBlank(del.Delegate__c)){
              if(delegateMap.containsKey(del.Manager__c)){
                    string emailids = delegateMap.get(del.Manager__c);
                    if(!emailids.contains(del.delegate__r.Email)){
                        emailids = emailids+';'+del.delegate__r.Email;
                        delegateMap.put(del.Manager__c, emailids);
                    }
               }else{
                    delegateMap.put(del.Manager__c, del.delegate__r.Email);
               } 
           }
       }
                    
       for(Case c: [SELECT Id, Subject,NHW_Start_Date__c,NH_Manager_Delegate_Email_Addresses__c, Manager_Name__c, recordTypeId
                    FROM Case 
                    WHERE Manager_Name__c IN: setManagerId AND 
                    (recordTypeId =: nhwCaseRecordTypeOnboardingId OR recordTypeId =: nhwCaseRecordTypeId) AND NHW_Start_Date__c>:Date.Today()])
       {           
               c.NH_Manager_Delegate_Email_Addresses__c = ((!delegateMap.isEmpty()) && delegateMap.containsKey(c.Manager_Name__c))? delegateMap.get(c.Manager_Name__c):'';
               caseList.add(c);         
       }

       if(!caseList.isEmpty() && Case.sObjectType.getDescribe().isUpdateable()){
        try {
            Database.update(caseList, false);
            }  catch (DmlException ex) { 
                system.debug('The following exception has occurred: ' + 
                            ex.getDmlStatusCode(0) + ex.getMessage());
            }
       }
   }

}