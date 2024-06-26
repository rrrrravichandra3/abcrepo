global class MA_ANSBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    public MA_ANSBatch() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query the related objects with a date field less than three weeks from now
        Date threeWeeksFromNow = Date.today().addDays(21);
        String query = 'SELECT Id,Name, Email, Acquisition_Contacts__r.Name, Acquisition_Contacts__c,Acquisition_Contacts__r.Hire_Date__c ' +
                       'FROM Contact ' +
                       'WHERE Acquisition_Contacts__r.Hire_Date__c <= LAST_N_WEEKS:3';
        return Database.getQueryLocator(query);
    }
    global void execute(SchedulableContext context) {
        Database.executeBatch(this);
    }
      global void execute(Database.BatchableContext BC, List<Contact> scope) {
       
        //Survey Invitation 
        SurveyInvitation surveyInvitation = new SurveyInvitation();
        surveyInvitation.CommunityId = '0DB0g000000PBckGAG';
        surveyInvitation.ParticipantId =  '003AE000003AJHOYA4';
        surveyInvitation.SurveyId = '0KdAE00000000Pp0AI';
        surveyInvitation.Name = 'SurveyInvitationANS5';
        surveyInvitation.OptionsAllowGuestUserResponse = true;
        insert surveyInvitation;


        // Survey Suejct 
        SurveySubject surveySubjectRec = new SurveySubject();
        surveySubjectRec.SubjectId = 'a4tAE0000000BmfYAE';
        surveySubjectRec.Name = surveyInvitation.Name;
        surveySubjectRec.ParentId = surveyInvitation.Id;
        insert surveySubjectRec;

        //get Invitation
        SurveyInvitation invitation = [SELECT Id, Name, UUID, ParticipantId 
                FROM SurveyInvitation 
                WHERE Name = 'SurveyInvitationANS5'];

        String invitationlink = 'https://dreamjobcentral--pfdev5.sandbox.my.site.com/MA/survey/runtimeApp.app?invitationId='+
        invitation.Id+'&surveyName=equipment_provisioning_survey&UUID='+invitation.UUID;

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Contact contact : scope) {
            // Create the email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{contact.Email});
            email.setSubject('Reminder: Related object has date less than three weeks');
            email.setPlainTextBody('Hello ' + contact.Name + ',\n\n' +
                                   'Please fill Equipment Provisioning Survey.\n\n' +
                                   invitationlink);

            emailList.add(email);   
        }

        // Send the emails
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Perform any post-processing tasks if needed
    }
}