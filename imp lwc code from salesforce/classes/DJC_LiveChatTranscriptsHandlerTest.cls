@isTest(seeAllData=false)
public class DJC_LiveChatTranscriptsHandlerTest {
    
    private static Contact emeaContact = ESDJC_AssignmentHelper.getContacts(1, 'EMEA - All Countries', 'London')[0];
    private static ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
    
    @isTest static void testCreateLiveChatCase() {
        ESDJC_TestUtil.init();
        Test.startTest();
            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;
            LiveChatTranscript transcript = new LiveChatTranscript();
            transcript.ContactId = emeaContact.id;
            transcript.StartTime = System.now();
            transcript.EndTime = System.now();
            transcript.LiveChatVisitorId = visitor.id;
            insert transcript; 
            //With omni channel case creation has moved to AgentWork 
            //But None of the fields on AgentWork  are editable so we cannot test it. 
            //So manually creating case.
            Case c = new Case();
            c.Origin = 'Live Agent';
            c.ContactId = transcript.ContactId;
            c.Subject = 'Live Chat Case';
            insert c;

            //Simulate stuff happening when work tab is closed.
            transcript.caseid=c.id;//Case gets created and associated.
            transcript.Body = 'test chat';//Transcript body gets generated later.

            update transcript;

        Test.stopTest();
        LiveChatTranscript refTranscript = [select caseId,body, Case.recordType.developername,Case.OwnerID, Case.Origin, OwnerID from LiveChatTranscript where id = :transcript.id];        
        List<FeedItem> Feeditems= [select body from FeedItem where parentId=:c.id];

        System.assert(refTranscript.caseId != null);
        System.assert(Feeditems.size()>0);
        Boolean transcriptPosted = false;
        for(Feeditem item:Feeditems){
            if(item.body== refTranscript.body ){
                transcriptPosted = true;
            }
        }
        System.assertEquals(transcriptPosted, true);
        System.assertEquals(DJC_LiveChatTranscriptsTriggerHandler.LIVE_AGENT, refTranscript.case.origin);  
        System.assertEquals(refTranscript.OwnerID,refTranscript.case.OwnerID);      
    }
    
    
    @isTest static void testCreateLiveChatwoVisitor() {
        ESDJC_TestUtil.init();
        Test.startTest();
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.Body = 'test chat';
        transcript.StartTime = System.now();
        transcript.EndTime = System.now();
        transcript.LiveChatVisitorId = visitor.id;
        insert transcript;        
        LiveChatTranscript refTranscript = [select caseId from LiveChatTranscript where id = :transcript.id];        
        Test.stopTest();
        System.assert(refTranscript.caseId == null);
         
    }
    
}