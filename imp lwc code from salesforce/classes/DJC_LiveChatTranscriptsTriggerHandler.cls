public without sharing class DJC_LiveChatTranscriptsTriggerHandler {
    
    private static ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
    public static final String LIVE_AGENT = 'Live Agent';
    public static void postBodyOnCase(List<LiveChatTranscript> newRecords,map<id,LiveChatTranscript> oldMap) {
        List<FeedItem> chatterPosts = new List<FeedItem>();
        for(LiveChatTranscript tranRec:newRecords){
            if(oldMap.containsKey(tranRec.id) && tranRec.body != oldMap.get(tranRec.id).body){
                FeedItem chatterPost = new FeedItem();
                chatterPost.ParentId =tranRec.caseid;
                //Align,<br> not supported in feed rich text.
                //Also editing the body for the initial three headers to have two line breaks
                //And add one line break for chat log.
                string editedBody = tranRec.body.replace('align="center"','');
                editedBody = editedBody.replace('</p>','</p><p>&nbsp;</p>');
                editedBody = editedBody.replace('<br>','<p></p>');
                chatterPost.Body = editedBody;
                chatterPost.isRichText = true;
                chatterPosts.add(chatterPost);
                
                
            }
            
        }
        if(chatterPosts.size()>0){
            insert chatterPosts;            
        }
    }
    
    public static void createDJCCaseOnInsert(List<LiveChatTranscript> newRecords) {
        if (newRecords == null) {
            return;
        }
        Map<LiveChatTranscript, Case> djcCases = new Map<LiveChatTranscript, Case>();
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.assignmentRuleHeader.useDefaultRule = true;
        
        for (LiveChatTranscript record : newRecords) {
            if ((record.contactId == null) || (record.CaseId != null)) {
                continue;
            }
            Case newCase = createNewCase(record);
            djcCases.put(record, newCase);            
        }
        if (djcCases.size() < 1) {
            return;                        
        }
        
        insert djcCases.values();  
        for (LiveChatTranscript record : djcCases.keySet()) {
            record.CaseId = djcCases.get(record).id;
        }
        sendConfirmationEmail(djcCases.values());
    }
    
    private static Case createNewCase(LiveChatTranscript record) {
        Case c = new Case();
        c.RecordTypeId = settings.All_Cases_Except_ER_EMEA_RT__c;
        c.Origin = LIVE_AGENT;
        c.ContactId = record.ContactId;
        c.Subject = (String.isNotBlank(record.Article_Name__c))?record.Article_Name__c:'Live Chat Case';
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
}