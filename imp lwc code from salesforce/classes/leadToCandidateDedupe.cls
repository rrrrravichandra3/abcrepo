global class leadToCandidateDedupe implements Database.Batchable<sObject>, Database.Stateful {

    Set<Id> contactsAlreadyDedupedThisBatchInstance;

    global leadToCandidateDedupe(){
      contactsAlreadyDedupedThisBatchInstance = new Set<Id>();
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id, Name, Email, Linked_In_URL__c, LastName, Employer_Organization_Name_1__c,
                                                Company, LeadSource, Phone, Home_Phone__c, MobilePhone,
                                                Mailing_City__c, Employer_1_Title__c, Mailing_State_Province__c,
                                                Mailing_Zip_Postal_Code__c, Facebook_Profile__c, Rating__c,
                                                Number_of_Reach_Outs__c, Outbound_Sourcer__c 
                                           from Lead 
                                           where isConverted = false 
                                                 AND IsDeleted = false
                                                 AND IsLocked = false
                                           ORDER BY CreatedDate]);
    }

    global void execute(Database.BatchableContext BC, List<Lead> allLeads) {

        Map<Id, Lead> leadIdToLeadRecordMap = new Map<Id, Lead>();
        Map<Id, Contact> contactIdToContactRecordMap = new Map<Id, Contact>();
        Map<Id, Id> leadIdToMatchingContactId = new Map<Id, Id>();

        
        List<Lead_Contact_Match__c> allMatches = new List<Lead_Contact_Match__c>();
        

        /** Block for finding Contacts with matching Email **/
        List<Lead_Contact_Match__c> emailMatches = leadToCandidateDedupeBatchHelper.matchEmail(allLeads, contactsAlreadyDedupedThisBatchInstance, leadIdToMatchingContactId, leadIdToLeadRecordMap, contactIdToContactRecordMap);
        allMatches.addAll(emailMatches);
        /**  End of Block for Email match **/

        leadToCandidateDedupeBatchHelper.removeMatchedLeads(allLeads, leadIdToMatchingContactId);

        /** Block for finding Contacts with Matching LinkedIn URl **/
        List<Lead_Contact_Match__c> linkedInMatches = leadToCandidateDedupeBatchHelper.matchLinkedInURL(allLeads, contactsAlreadyDedupedThisBatchInstance, leadIdToMatchingContactId, leadIdToLeadRecordMap, contactIdToContactRecordMap);
        allMatches.addAll(linkedInMatches);
        /** End of Block for Linked In URL Match **/ 

        leadToCandidateDedupeBatchHelper.removeMatchedLeads(allLeads, leadIdToMatchingContactId);

        /** Block for finding Contacts with Last Name + Employer Organization 1 **/
        //commented out for Jan B release. Will be enhanced for future release, to include first name as well
        //List<Lead_Contact_Match__c> lastNameEmpOrgMatches = leadToCandidateDedupeBatchHelper.matchLastNameEmployeeOrg(allLeads, contactsAlreadyDedupedThisBatchInstance, leadIdToMatchingContactId, leadIdToLeadRecordMap, contactIdToContactRecordMap);
        //allMatches.addAll(lastNameEmpOrgMatches);
        /** End of Block for Last Name + Employer Organization 1 **/ 

        /** Block for updating Contacts from their matched leads **/
        List<Contact> contactsToBeUpdated = leadToCandidateDedupeBatchHelper.updateMatchedContacts(leadIdToMatchingContactId, leadIdToLeadRecordMap, contactIdToContactRecordMap);
        /** End of Block for contact updates **/ 

        //Add matched contacts for this batch chunk to sateful set of contacts that have been picked up by batch process
        contactsAlreadyDedupedThisBatchInstance.addAll(contactIdToContactRecordMap.keySet());

        /** Move all Tasks from Leads to Contacts **/
        List<Task> tasksToBeUpdated = leadToCandidateDedupeBatchHelper.transferTasksToContacts(leadIdToMatchingContactId);
        /** End of Block to Move Tasks **/

        /** Move all Events from Leads to Contacts **/
        List<Event> eventsToBeUpdated = leadToCandidateDedupeBatchHelper.transferEventsToContacts(leadIdToMatchingContactId);
        /** End of Block to Move Events **/

        /** Move all Secure Info related List from Leads to Contacts **/
        List<Candidate_Secure_Info__c> secureInfoToBeUpdated = leadToCandidateDedupeBatchHelper.transferSecureInfoToContacts(leadIdToMatchingContactId);
        /** End of Block to Move Secure Info **/

        /** Move all Notes related List from Leads to Contacts **/
        /** Currently reParenting of Notes is not possible via code. So we create new Notes and delete the old ones **/
        List<Note> notesToBeDeleted = new List<Note>();
        List<Note> newNotesToBeCreated = leadToCandidateDedupeBatchHelper.transferNotesToContacts(leadIdToMatchingContactId, notesToBeDeleted);
        /** End of Block for Notes **/

        /** Move all Attachment related List from Leads to Contacts **/
        /** Currently reParenting of Attachments is not possible via code. So we create new Attachments and delete the old ones **/
        List<Attachment> attachmentsToBeDeleted = new List<Attachment>();
        List<Attachment> newAttachmentsToBeCreated = leadToCandidateDedupeBatchHelper.transferAttachmentsToContacts(leadIdToMatchingContactId, attachmentsToBeDeleted);
        /** End of Block for Attachment **/

        /** Move all the Campaign History from Lead to Contact **/
        List<CampaignMember> newCampaignMembersToBeInserted = leadToCandidateDedupeBatchHelper.transferCampaignHistory(leadIdToMatchingContactId);
        /** End of Block for Campaign **/


        /* List of Leads to be deleted */
        List<Lead> leadsToBeDeleted = new List<Lead>();
        leadsToBeDeleted.addAll(leadIdToLeadRecordMap.values());

        //Perform all DML operations
        leadToCandidateDedupeBatchHelper.performDatabaseOperations(contactsToBeUpdated,tasksToBeUpdated,eventsToBeUpdated,secureInfoToBeUpdated,newNotesToBeCreated,notesToBeDeleted, attachmentsToBeDeleted, newAttachmentsToBeCreated, newCampaignMembersToBeInserted, allMatches, leadsToBeDeleted);

    }
    
    global void finish(Database.BatchableContext BC) {

        String[] toAddresses = new String[]{};
        //Send email that batch process is finished to recipients stored in field "Lead_To_Candidate_Dedupe_Email_Recipient" of Tf2_Settings custom setting
        if((TF2Settings__c.getOrgDefaults()).Lead_To_Candidate_Dedupe_Email_Recipient__c != ''){
            toAddresses = ((TF2Settings__c.getOrgDefaults()).Lead_To_Candidate_Dedupe_Email_Recipient__c).split(',');
        }else{
            toAddresses.add('annamaria.paredes@salesforce.com');
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Leads To Contact Dedupe Batch');
        mail.setSubject('Batch Process Complete');
        mail.setPlainTextBody('Batch process is finsihed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}