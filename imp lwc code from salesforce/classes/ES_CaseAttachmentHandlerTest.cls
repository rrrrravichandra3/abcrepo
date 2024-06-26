@isTest
public class ES_CaseAttachmentHandlerTest {
	private static Contact amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];
    
    private static testMethod void testAttachmentsForNons2s(){
        ESDJC_TestUtil.init();   
        Case ca = new Case(); 
		ca.contactId = amerContact.Id;        
        ca.Origin = 'Chatter Answers'; 
        ca.Type = 'V2MOM Support'; 
        ca.ES_DJC_Topic__c = 'V2MOM Support';
        ca.Subject = 'Test attachments non s2s'; 
        insert ca; 
        //now create attachment.. 
        Attachment att = new Attachment(); 
        Test.startTest(); 
        att.Name = 'Test attachment s2s'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        att.Body = bodyBlob; 
        att.ParentId = ca.id; 
        insert att; 
        Test.stopTest(); 
        
        //check partnerconnections is not established for this attachment.. 
        System.assertEquals(false,[select Id,IsPartnerShared from Attachment where id = : att.Id].IsPartnerShared);
        
    }

    
    
    private static testMethod void testAttachmentsForNonCaseRecords(){
        ESDJC_TestUtil.init();   
        Account acc = new Account(); 
        acc.Name='Test account';
        insert acc;
		//insert attachment
        Attachment att = new Attachment(); 
        Test.startTest(); 
        att.Name = 'Test attachment s2s'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        att.Body = bodyBlob; 
        att.ParentId = acc.id; 
        insert att; 
        Test.stopTest(); 
        
        //Make sure attachment insertion is not impacted by our trigger for non case records and also partnershared is false.. 
        System.assertEquals(false,[select Id,IsPartnerShared from Attachment where id = : att.Id].IsPartnerShared);
        
    }

    //Test for emailTocase - emailMessage on case
    private static testMethod void testAttachmentForCaseEmailMessages(){
        ESDJC_TestUtil.init();   
        Case ca = new Case(); 
		ca.contactId = amerContact.Id;        
        ca.Origin = 'Chatter Answers'; 
        ca.Type = 'V2MOM Support'; 
        ca.ES_DJC_Topic__c = 'V2MOM Support';
        ca.Subject = 'Test attachments s2s'; 
        insert ca; 
        //Create emailMessage
        list<EmailMessage> messages = new list<EmailMessage>();
        EmailMessage InboundEmail = new EmailMessage();
        InboundEmail.parentId= ca.id;
        InboundEmail.Incoming= true;
        insert InboundEmail;
        EmailMessage OutboundEmail = new EmailMessage();
        OutboundEmail.parentId= ca.id;
        OutboundEmail.Incoming= false;
        OutboundEmail.ReplyToEmailMessageId=InboundEmail.Id;
        insert OutboundEmail;

        //now create attachment.. 
        Attachment att1 = new Attachment();  
        Attachment att2 = new Attachment();
        list<Attachment> attachments = new list<Attachment>();
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
  
        Test.startTest(); 
            att1.Name = 'Test attachment InboundemailMessage'; 
            att1.Body = bodyBlob; 
            att1.ParentId = InboundEmail.id;         
            att2.Name = 'Test attachment emailMessage'; 
            att2.Body = bodyBlob; 
            att2.ParentId = OutboundEmail.id; 
            attachments.add(att1);
            attachments.add(att2);
            insert attachments;
        Test.stopTest(); 
        attachments = [select id,parentId,Name from Attachment where id in :attachments ];

        for(attachment att:attachments){
            if(att.Name == 'Test attachment InboundemailMessage'){
                system.assertEquals(att.parentId,ca.id,'Expecting attachment to be reassigned for inbound messages');         
            }
           /* else{
                //As of Spring'17 , Attachment trigger doesn't fire for outbound email messages.  
                system.assertNotEquals(att.parentId,ca.id,'Expecting attachment NOT to be reassigned for outbound messages');         
            }*/
        }
    }

    private static testMethod void testPackageAdditionalDescriptionForREWS() {
        String firstPackageComment = 'Comment01';
        String firstPackageLocation = 'USA';
        String packageStatus = 'In Progress';
        String packageTracking = '12345';
        String caseOrigin = 'Chatter Answers';
        String newDescription = 'Description updated';
        String carrier = 'Carrier';
        String sender = 'Sender';

        ESDJC_TestUtil.init();
        Case new_case = new Case();
        new_case.contactId = amerContact.Id;
        new_case.Origin = caseOrigin;
        new_case.Type = 'V2MOM Support';
        new_case.ES_DJC_Topic__c = 'V2MOM Support';
        new_case.Subject = 'Test attachments s2s';
        new_case.REWS_Carrier__c = carrier;
        new_case.REWS_Sender__c = sender;
        new_case.RecordTypeId = [SELECT Name, Id, DeveloperName FROM RecordType where sObjectType='Case' AND isActive=true AND DeveloperName LIKE '%REWS%' LIMIT 1].Id;
        insert new_case;

        REWS_Package_Delivery__c pkg1 = new REWS_Package_Delivery__c(REWS_Tracking_Number__c = packageTracking, REWS_Comments__c = firstPackageComment, REWS_Current_Location__c = firstPackageLocation, REWS_Status__c = packageStatus, Case__c = new_case.Id);

        Test.startTest();
        insert pkg1;

        new_case.Description = newDescription;
        update new_case;

        String caseDescription = [SELECT Description FROM Case WHERE Origin = :caseOrigin ].Description;

        System.assertEquals(true, caseDescription.containsAny(carrier));
        System.assertEquals(true, caseDescription.containsAny(sender));
        System.assertEquals(true, caseDescription.containsAny(firstPackageLocation));
        System.assertEquals(true, caseDescription.containsAny('Pending Package Count: 1'));
    }
    

}