public without sharing class DJC_OmniChatTranscriptsTriggerHandler {
    
    private static ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
    public static final String LIVE_AGENT = 'Live Agent';
    
    public static void createDJCCaseOnUpdate(List<AgentWork> agentWorkRecords) {
        if (agentWorkRecords == null) {
            return;
        }
        List<Id> liveChatTranscriptIds = new List<Id>();
        for(AgentWork awork : agentWorkRecords){
            if(awork.WorkItemId.getSObjectType().getDescribe().getName() == 'LiveChatTranscript') {
                if(awork.Status == 'Closed') {
                    liveChatTranscriptIds.add(awork.WorkItemId);
                }
            }
        }
        map<Id,LiveChatTranscript> mLiveChatTranscriptRecords = new map<Id,LiveChatTranscript>([Select Id, ContactId, Body,CaseId 
                                                                from LiveChatTranscript where Id in : liveChatTranscriptIds]);
        Map<Id, Case> mValidTranscriptIdToCase = new Map<Id, Case>();
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.assignmentRuleHeader.useDefaultRule = true;
        
        for (LiveChatTranscript record : mLiveChatTranscriptRecords.values()) {
            if ((record.contactId == null) || (record.CaseId != null)) {
                continue;
            }
            Case newCase = createNewCase(record);
            mValidTranscriptIdToCase.put(record.id, newCase);            
        }
        if (mValidTranscriptIdToCase.size() < 1) {
            return;                        
        }
        try{
            insert mValidTranscriptIdToCase.values();
        }
        catch(DmlException e){
            System.debug('DML Exception occured: '+e.getMessage());
        }
        catch(Exception e){
            System.debug('Exception occured: '+e.getMessage());
        }
         
        for (Id TranscriptId : mValidTranscriptIdToCase.keyset()) {
             mLiveChatTranscriptRecords.get(TranscriptId).CaseId = mValidTranscriptIdToCase.get(TranscriptId).id;
        }
      
        try{ 
            update mLiveChatTranscriptRecords.values();
        }
        catch(DmlException e){
            System.debug('Exception occured: '+e.getMessage());
        }
        catch(Exception e){
            System.debug('Exception occured: '+e.getMessage());
        }
        sendConfirmationEmail(mValidTranscriptIdToCase.values());
    }
    
    private static Case createNewCase(LiveChatTranscript record) {
        Case c = new Case();
        c.RecordTypeId = settings.All_Cases_Except_ER_EMEA_RT__c;
        c.Origin = LIVE_AGENT;
        c.ContactId = record.ContactId;
        c.Subject = 'Live Chat Case';
        return c;
    }
    
    private static void sendConfirmationEmail(List<Case> cases) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Case c: cases){            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(c.contactId);
            mail.setTemplateId(ESDJC_Util.getEmailTemplate('ES_Concierge_Case_Auto_Response_HTML').Id);
            mail.setWhatId(c.Id);
            mail.OrgWideEmailAddressId=REWS_Setting__c.getInstance().Mail_services_Orgwide_email__c;
            emails.add(mail);            
        }
        if(emails.size() > 0) {
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emails);        
        }        
    }

     //Update OwnerSupportGroup field on case When Case Assigned to the user Via Omni Channel - @W-6923213
    public static void updateOwnerSupportGroup(List<AgentWork> awRecords){
        set<id> setCaseids = new set<id>();
        List<ESDJC_Owner_Support_Group__c> supportOwnerSettings = ESDJC_Owner_Support_Group__c.getAll().Values(); 
        Map<Id,String> ownerSupportGroupMap = new Map<Id,String>();
        for (AgentWork aw : awRecords) {
          setCaseids.add(aw.WorkItemId);      
        }
        for(ESDJC_Owner_Support_Group__c oGroup : supportOwnerSettings){
            if(oGroup.QueueId__c!=null){
                ownerSupportGroupMap.put(oGroup.QueueId__c,oGroup.Support_Group__c);
            } 
            if(oGroup.RoleId__c!=null){
                ownerSupportGroupMap.put(oGroup.RoleId__c,oGroup.Support_Group__c);
            }
           
        }
        map<id, Case> mapOfCaseDetails = new map<id, Case>([SELECT id,OwnerId,Owner.UserRoleid FROM CASE WHERE Id IN: setCaseids]);
        Map<Id, GroupMember> ownerQueuesDetails = new Map<Id, GroupMember>();
        Set<Id> ownerIdSet = new Set<Id>();
        for(Id caseId : mapOfCaseDetails.keyset()){ 
            ownerIdSet.add(mapOfCaseDetails.get(caseId).OwnerId); 
        } 
        for(GroupMember gm :[select GroupId, Group.Name,UserorGroupId from GroupMember where group.type = 'Queue' and UserorGroupId IN:ownerIdSet]){    
            ownerQueuesDetails.put(gm.UserorGroupId, gm); 
        }      
        if(mapOfCaseDetails <> null && !mapOfCaseDetails.isEmpty()){
            List<case> caseList = new List<case>();   
            for(Id caseId: mapOfCaseDetails.keyset()){
                if(mapOfCaseDetails.get(caseId) <> null){
                    Case cs = new Case(id=caseId);                     
                    Id ownerQueueId; 
                    if(ownerQueuesDetails.containsKey(mapOfCaseDetails.get(caseId).OwnerId)){ 
                        ownerQueueId = ownerQueuesDetails.get(mapOfCaseDetails.get(caseId).OwnerId).GroupId; 
                    } 
                    if(ownerSupportGroupMap.containsKey(mapOfCaseDetails.get(caseId).Owner.UserRoleId)){ 
                        cs.Owner_Support_Group__c=ownerSupportGroupMap.get(mapOfCaseDetails.get(caseId).Owner.UserRoleId); 
                    }
                    else if(ownerSupportGroupMap.containsKey(ownerQueueId)){ 
                        cs.Owner_Support_Group__c=ownerSupportGroupMap.get(ownerQueueId); 
                    } 
                    else{ 
                        cs.Owner_Support_Group__c=''; 
                    }
                    caseList.add(cs);
                }
    
            } 
               
            if(caseList <> null && !caseList.isEmpty()){
                update caseList;
              
            }   
        }
    }
               
}