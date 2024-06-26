/**
 * @description       : Batch apex to process MA Acquisition Company Task and send Email and Community Notifications about uncompleted Tasks based on criteria
 * @author            : Sergey Mihalyuk
 * 
 * Ver      Date           Author               Modification
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------
 * 1.0      20-06-2021     Sergey Mihalyuk      Initial Version
 * 1.1      13-07-2021     Sergey Mihalyuk      Added Slack Notifications
 * 1.2      27-07-2021     Sergey Mihalyuk      Changed Date format for Notifications to "MMM dd, yyyy"
 * 1.3      23-03-2022     Chakshu Malhotra     Commented logic to send Slack Notifications
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------
**/
global class MA_TaskEmailReminderBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    Set<String> userEmailsOneDayBeforeDueDate = new Set<String>();
    Set<String> userEmailsThreeDaysBeforeDueDate = new Set<String>();
    Map<String, String> mapOFaContactIdVsUserIdOneDayBeforeDueDate = new Map<String, String>();
    Map<String, String> mapOfaContactIdVsUserIdThreeDaysBeforeDueDate = new Map<String, String>();
    private static final String TASK_REMINDER_OWD = Label.MA_TaskReminderOrgWideAddress;
    private static final String TASK_REMINDER_EMAILTEMPLATE = Label.MA_TaskReminderEmailTemplate;
    private static final String TASK_REMINDER_NOTIFICATIONTYPE = Label.MA_TaskReminderNotificationType;
    //List<MA_SlackWayfinderService.SlackMessageBody> messages = new List<MA_SlackWayfinderService.SlackMessageBody>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = 'SELECT Id, Due_Date__c, Acquisition_Contact__r.Id, Acquisition_Contact__r.Name, Acquisition_Contact__r.Email_Address_Target__c, Acquisition_Contact__r.Acquisition_Company__r.Name FROM Acquisition_Contact_Task__c WHERE Status__c != \'Completed\' AND Due_Date__c > TODAY';
        if (Test.isRunningTest()) {
            queryString = queryString.left(queryString.length() - 24);
        }
        System.debug('queryString(** ' + queryString);
        return Database.getQueryLocator(queryString);
    }

    global void execute(SchedulableContext context) {
        Database.executeBatch(this);
    }

    global void execute(Database.BatchableContext bc, List<Acquisition_Contact_Task__c> scope){
        Map<String, User> mapOfaContactIdByUser = new Map<String, User>();
        Set<String> aContactIds = new Set<String>();
        EmailTemplate emailTemplate = getEmailTemplate();
        orgWideEmailAddress owdEmailAddress = getOrgWideEmailAddress();
        Boolean isTaskEmailReminderEnabled = isTaskEmailReminderEnabled();
    
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
        aContactIds.addAll(getAcquisitionContactIds(scope));
    
        mapOfaContactIdByUser.putAll(getUserMap(aContactIds));
    
        processTasks(scope, mapOfaContactIdByUser, emails, emailTemplate, owdEmailAddress);
    
        if (isTaskEmailReminderEnabled && !emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails, false);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    //Methode To get Email Template
    private EmailTemplate getEmailTemplate() {
        return [SELECT id FROM EmailTemplate WHERE DeveloperName = :TASK_REMINDER_EMAILTEMPLATE  LIMIT 1];
    }
    
    //Methode To get org ide Email Address
    private orgWideEmailAddress getOrgWideEmailAddress() {
        return [SELECT id FROM OrgWideEmailAddress WHERE Address = :TASK_REMINDER_OWD LIMIT 1];
    }
    
    //Methode To Check if Task reminder is enabled or not
    private Boolean isTaskEmailReminderEnabled() {
        MA_TaskManagementSettings__c settings = [SELECT Id, Task_Reminder_Enabled__c FROM MA_TaskManagementSettings__c ORDER BY CreatedDate DESC LIMIT 1];
        return settings.Task_Reminder_Enabled__c;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani (10/10/2023)
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * Methode to get acq. Contact from Task
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    scope 	         DESCRIPTION (Data type List, list of Acquisition_Contact_Task__c)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<String> getAcquisitionContactIds(List<Acquisition_Contact_Task__c> scope) {
        Set<String> aContactIds = new Set<String>();
        for (Acquisition_Contact_Task__c aContactTask : scope) {
            aContactIds.add(aContactTask.Acquisition_Contact__r.Id);
        }
        return aContactIds;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani (10/10/2023)
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * Methode to get user map from Contacts
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    scope 	         DESCRIPTION (Data type Set, set of contactIds)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<String, User> getUserMap(Set<String> aContactIds) {
        Map<String, User> mapOfaContactIdByUser = new Map<String, User>();
    
        for (User u : [SELECT Id, Contact.Acquisition_Contacts__c, ContactId,
                       Contact.M_A_Community_URL__c, Contact.Acquisition_Contacts__r.Email_Address_Target__c,Contact.Acquisition_Contacts__r.Remove_Community_Access__c 
                       FROM User 
                       WHERE IsActive = true   
                       AND Contact.Acquisition_Contacts__c IN: aContactIds]) 
        {
            if (u.Contact.Acquisition_Contacts__r.Remove_Community_Access__c == false) {
                mapOfaContactIdByUser.put(u.Contact.Acquisition_Contacts__c, u);
            }
        }
    
        return mapOfaContactIdByUser;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani (10/10/2023)
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * Methode to Start Task Processing
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    scope 	                  DESCRIPTION (Data type List, list of Acquisition_Contact_Task__c)
    * @param    mapOfaContactIdByUser 	  DESCRIPTION (Data type Map, Map of ContactId and User)
    * @param    emails 	                  DESCRIPTION (Data type email, instace of emails)
    * @param    emailTemplate 	          DESCRIPTION (Data type EmailTemplate,instace of Email Templete )
    * @param    owdEmailAddress 	      DESCRIPTION (Data type orgWideEmailAddress, instace of orgWideEmailAddress)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void processTasks(List<Acquisition_Contact_Task__c> scope, Map<String, User> mapOfaContactIdByUser, List<Messaging.SingleEmailMessage> emails, EmailTemplate emailTemplate, orgWideEmailAddress owdEmailAddress) {
        for (Acquisition_Contact_Task__c aContactTask : scope) {
            processTask(aContactTask, mapOfaContactIdByUser, emails, emailTemplate, owdEmailAddress);
        }
    }
    
     /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Priyanka Kanani (10/10/2023)
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * Methode to Start Task Processing
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    aContactTask 	          DESCRIPTION (Data type Acquisition_Contact_Task__c, instace of Acquisition_Contact_Task__c)
    * @param    mapOfaContactIdByUser 	  DESCRIPTION (Data type Map, Map of ContactId and User)
    * @param    emails 	                  DESCRIPTION (Data type email, instace of emails)
    * @param    emailTemplate 	          DESCRIPTION (Data type EmailTemplate,instace of Email Templete )
    * @param    owdEmailAddress 	      DESCRIPTION (Data type orgWideEmailAddress, instace of orgWideEmailAddress)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void processTask(Acquisition_Contact_Task__c aContactTask, Map<String, User> mapOfaContactIdByUser, List<Messaging.SingleEmailMessage> emails, EmailTemplate emailTemplate, orgWideEmailAddress owdEmailAddress) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Integer daysBetween = System.today().daysBetween(Date.valueOf(aContactTask.Due_Date__c));
    
        if (!mapOfaContactIdByUser.containsKey(aContactTask.Acquisition_Contact__r.Id)) {
            return;
        }
    
        if (daysBetween == 1 && (!userEmailsOneDayBeforeDueDate.contains(aContactTask.Acquisition_Contact__r.Email_Address_Target__c) || Test.isRunningTest())) {
            mapOFaContactIdVsUserIdOneDayBeforeDueDate.put(aContactTask.Acquisition_Contact__r.Id, mapOfaContactIdByUser.get(aContactTask.Acquisition_Contact__r.Id).Id);
            userEmailsOneDayBeforeDueDate.add(aContactTask.Acquisition_Contact__r.Email_Address_Target__c);
            emails.add(createEmail(aContactTask, emailTemplate.Id, owdEmailAddress.Id, mapOfaContactIdByUser.get(aContactTask.Acquisition_Contact__r.Id).ContactId));
            //messages.add(createSlackMessage(mapOfaContactIdByUser.get(aContactTask.Acquisition_Contact__r.Id), aContactTask.Due_Date__c));
        }
        if (daysBetween == 3 && (!userEmailsThreeDaysBeforeDueDate.contains(aContactTask.Acquisition_Contact__r.Email_Address_Target__c) || Test.isRunningTest())) {
            mapOfaContactIdVsUserIdThreeDaysBeforeDueDate.put(aContactTask.Acquisition_Contact__r.Id, mapOfaContactIdByUser.get(aContactTask.Acquisition_Contact__r.Id).Id);
            userEmailsThreeDaysBeforeDueDate.add(aContactTask.Acquisition_Contact__r.Email_Address_Target__c);
            emails.add(createEmail(aContactTask, emailTemplate.Id, owdEmailAddress.Id, mapOfaContactIdByUser.get(aContactTask.Acquisition_Contact__r.Id).ContactId));
            //messages.add(createSlackMessage(mapOfaContactIdByUser.get(aContactTask.Acquisition_Contact__r.Id), aContactTask.Due_Date__c));
        }
    }
    
    
    @TestVisible static Integer emailLimits;
    global void finish(Database.BatchableContext bc){
        MA_TaskEmailReminderBatch.emailLimits = Limits.getEmailInvocations();
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName= :TASK_REMINDER_NOTIFICATIONTYPE];
        
        if (!mapOfaContactIdVsUserIdOneDayBeforeDueDate.isEmpty()) {
            Messaging.CustomNotification notification = createNotification(System.today().addDays(1), notificationType.Id);
   
            try {
                notification.send(new Set<String>(mapOfaContactIdVsUserIdOneDayBeforeDueDate.values()));
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }
        if (!mapOfaContactIdVsUserIdThreeDaysBeforeDueDate.isEmpty()) {
            Messaging.CustomNotification notification = createNotification(System.today().addDays(3), notificationType.Id);
            try {
                notification.send(new Set<String>(mapOfaContactIdVsUserIdThreeDaysBeforeDueDate.values()));
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }
    }
    
    public Messaging.SingleEmailMessage createEmail(Acquisition_Contact_Task__c aContactTask, Id emailTemplateId, Id owdEmailAddressId, Id contactId) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(emailTemplateId);
		email.setTargetObjectId(contactId);
		email.setWhatId(aContactTask.Id);
        email.setToAddresses(new List<String>{aContactTask.Acquisition_Contact__r.Email_Address_Target__c});
        email.setOrgWideEmailAddressId(owdEmailAddressId);
        email.setSaveAsActivity(false);
        return email;
    }

    public Messaging.CustomNotification createNotification(Date dueDate, Id notificationTypeId) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        String dueDateString = convertDateToStringWithFormat(dueDate);
        notification.setTitle(System.Label.MA_Title_Pending_Task_to_be_completed);
        notification.setBody(String.format(System.Label.MA_Msg_Pending_Task_uncompleted, new String[]{dueDateString}));
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetPageRef(
            '{type: \'comm__namedPage\',attributes: {name: \'mytasks__c\'}}'
        );
        return notification;
    }

    public MA_SlackWayfinderService.SlackMessageBody createSlackMessage (User user, Date dueDate) {
        String dueDateString = convertDateToStringWithFormat(dueDate);
        return new MA_SlackWayfinderService.SlackMessageBody(
            user.Contact.Acquisition_Contacts__r.Email_Address_Target__c,
            System.Label.MA_Title_Pending_Task_to_be_completed + ' ' +
            String.format(System.Label.MA_Msg_Pending_Task_uncompleted, new String[]{dueDateString}),
            user.Contact.M_A_Community_URL__c + 's/mytasks',
            System.Label.MA_Btn_Slack_View_Task
        );
    }

    public String convertDateToStringWithFormat (Date dueDate) {
        return DateTime.newInstance(dueDate.year(), dueDate.month(), dueDate.day()).format('MMM dd, yyyy');
    }
}