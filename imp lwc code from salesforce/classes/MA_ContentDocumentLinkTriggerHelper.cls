/**
* @description       : Helper class for ContentDocumentLink Trigger Operations for M&A Requirements
* @author            : Ashutosh Belwal
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   16-11-2021   Ashutosh Belwal  Initial Version
* */
public without sharing class MA_ContentDocumentLinkTriggerHelper {
   
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used for enabling the documents for community user when attached to case record by ES User
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   			   	DESCRIPTION (Data type List of ContentDocumentLink)
    * @return   
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void enableDocumentForCommunityUser(List<ContentDocumentLink> newRecords){
        
        Set<Id> caseIds = new Set<Id>();
        for(ContentDocumentLink obj : newRecords){
            String sObjName = obj.LinkedEntityId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Case'){
                caseIds.add(obj.LinkedEntityId);
            }
        }
        
        Set<Id> communityCases = new Map<Id, Case>([SELECT Id, CreatedById, CreatedBy.IsPortalEnabled 
                                                    FROM Case 
                                                    WHERE 
                                                    Id IN: caseIds 
                                                    AND CreatedBy.IsPortalEnabled = true
                                                    AND CreatedBy.Contact.Acquisition_Contacts__c != null
                                                   ]).keySet();
        
        for(ContentDocumentLink objCDL : newRecords){
            if(communityCases.contains(objCDL.LinkedEntityId)){
                objCDL.Visibility = 'AllUsers';
            }
        }
        
    }
}