/**
* @description       : ContentDocumentLink Object Trigger Handler
* @author            : Ashutosh Belwal
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   16-11-2021   Ashutosh Belwal  Initial Version
* */
public without sharing class ContentDocumentLinkTriggerHandler {
    
     /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used for Handleing the Trigger operations of ContentDocumentLink recrods
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   			   	DESCRIPTION (Data type List of ContentDocumentLink)
    * @param    oldRecords 	   			   	DESCRIPTION (Data type List of ContentDocumentLink)
    * @param    newMap 	   			   		DESCRIPTION (Data type Map of ContentDocumentLink)
    * @param    oldMap 	   			   		DESCRIPTION (Data type List of ContentDocumentLink)
    * @param	operation					DESCRIPTION (Data type TriggerOperation)
    * @return   
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handler(List<ContentDocumentLink> newRecords, List<ContentDocumentLink> oldRecords, Map<Id, ContentDocumentLink> newMap, Map<Id, ContentDocumentLink> oldMap, TriggerOperation operation){
        
        switch on operation 
        {
            when BEFORE_INSERT 
            {
                beforeInsert(newRecords, oldRecords, newMap, oldMap);
            }
           
        }
        
    }
    
    public void beforeInsert(List<ContentDocumentLink> newRecords, List<ContentDocumentLink> oldRecords, Map<Id, ContentDocumentLink> newMap, Map<Id, ContentDocumentLink> oldMap){
        
        if(!MA_Util.checkTriggerEnabled('MA_ContentDocumentLinkTriggerHelper', 'ContentDocumentLink', 'before insert')){
            MA_ContentDocumentLinkTriggerHelper.enableDocumentForCommunityUser(newRecords);
        }
    }
    
    
}