public with sharing class NHW_WDRJobRequistionTriggerHandler implements WDR_CommonTriggerHandler{
	public void beforeInsert(){ 
	}
	public void afterInsert(){ 
	}
	public void beforeUpdate(){ 
	}
	public void afterUpdate(){
		NHW_WDRJobRequistionTriggerHandler.updateCasesOnJobRequistionFieldsUpdate();
	}
	public void beforeDelete(){ 
	}
	public void afterDelete(){ 
	}
	public void afterUnDelete(){
	}

	public static void updateCasesOnJobRequistionFieldsUpdate(){
        Map<Id, WDR_Job__c> oldJobApplicationMap = (Map<Id, WDR_Job__c>) Trigger.oldMap; 
        Map<Id, WDR_Job__c> newJobApplicationMap = (Map<Id, WDR_Job__c>) Trigger.newMap;
        
        Set<Id> jobRequisitionNeedPropagationSet = new Set<Id>();
        for(Id jbAppId: newJobApplicationMap.keySet()){
            if(
            		newJobApplicationMap.get(jbAppId).Business_Unit__c != oldJobApplicationMap.get(jbAppId).Business_Unit__c  
            		|| newJobApplicationMap.get(jbAppId).Department__c != oldJobApplicationMap.get(jbAppId).Department__c
            		|| newJobApplicationMap.get(jbAppId).Hiring_Manager__c != oldJobApplicationMap.get(jbAppId).Hiring_Manager__c
            ){
                jobRequisitionNeedPropagationSet.add(jbAppId);
            }
		}
		//Adding Candidate Stage filter as case is available ONLY on Job apps at placement and onwards to cascade.
        Map<Id, WDR_Application__c> relatedJobApplications = new Map<Id, WDR_Application__c> ([SELECT Id FROM WDR_Application__c WHERE Candidate_Stage__c = 'Placement' AND Job__c in : jobRequisitionNeedPropagationSet]);
        if(!relatedJobApplications.isEmpty()) NHW_Util.updateJobApplicationsRelatedCases(relatedJobApplications.keySet(), null, null);
    }
}