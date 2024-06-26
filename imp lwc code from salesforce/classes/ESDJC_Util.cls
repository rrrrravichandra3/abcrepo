public without sharing class ESDJC_Util {

    private static Integer MIN_USER_ID_LENGTH = 2;
    public static set<Id> IgnoreCaseIds = new set<Id>();
    public static boolean ignoreEmailTriggers = false;


    public static String REGION_AMER = 'Americas';

    public static String REGION_EMEA = 'EMEA';

    public static String REGION_APAC = 'APAC';

    public static String REGION_JAPAN = 'Japan';

    public static String REGION_LACA= 'LACA';

    public static String REGION_DEFAULT = 'Default';

    public static boolean triggerContext = false;

    private static ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();

    public static  final set<string> FOUNDATION_DEPTS = new set<string>(String.isBlank(settings.Foundation_Dept_Names__c) ? new list<string>() : settings.Foundation_Dept_Names__c.split(','));

    public static final String CLOSED = 'Closed';
    public static final String WAITING_FOR_RESPONSE = 'Waiting for Response';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String CLOSED_BY_USER = 'Closed - By User';
    
    @InvocableVariable(required=true description='Sobject Record Ids')
    public String recordId;
    
    @InvocableVariable(required=false description='Sobject Currect Record Values')
    public String currentInputVal;
    
    @InvocableVariable(required=false description='Sobject Previous Record Values')
    public String prevInputVal;
    
    public static Boolean isFoundationDepartment(String department){

        for(String foundationDepartment:FOUNDATION_DEPTS){
            if(department.equalsIgnoreCase(foundationDepartment)){
                return true;
            }
        }
        return false;
    }

    public static String getDJCUserName(String loginId) {
        String DJC_ORG = '@'+settings.SSO_Dreamjobcentral_ID__c;
        return getUserName(loginId)+DJC_ORG;
    }

    public static String getPFUserName(String loginId) {
        String PF_ORG = '@'+settings.SSO_Service_Provider_Org__c;
        return getUserName(loginId)+PF_ORG;
    }

    public static List<EmailMessage> filterIncomingEmailMessagesWithParentCase(List<EmailMessage> emailMsgs) {
        List<EmailMessage> filterdEmailMsg = new List<EmailMessage>();
        for(EmailMessage msg: emailMsgs){
            if(msg.Incoming && msg.ParentId != null && ((String)msg.ParentId).startsWith('500')){
                filterdEmailMsg.add(msg);
            }
        }
        return filterdEmailMsg;
    }

    private static String getUserName(String loginId) {
        String PF_ORG = '@'+settings.SSO_Service_Provider_Org__c;
        if(loginId != null) {
            loginId = loginId.trim();
            if(loginId.length() >= MIN_USER_ID_LENGTH){

                Integer index = -1;
                index = loginId.indexOfIgnoreCase(PF_ORG);

                if(index >= MIN_USER_ID_LENGTH){
                    return loginId.substring(0, index);
                }
            }
        }
        return null;
    }  
    

    

    public static String massageSearchString(String searchString) {
        if(searchString != null) {
            searchString = searchString.replaceAll('-', ' ');
        }
        return searchString;
    }

    public static String getRegionFromDivision(String divisionString) {

        System.debug('+++getRegionFromDivision divisionString=='+divisionString);

        /*

            Divion String could be as below

            Americas - Canada

            Americas - USA

            Americas - Latin America

            APAC - All Countries

            EMEA - All Countries

            Japan

        */
        //TODO: move division string to map check - regionstringtocheck => regionstringtoreturn
        if(divisionString != null && divisionString.trim().length() > 0){

            if(divisionString.containsIgnoreCase('Latin America')){
                  return REGION_LACA;
                
            }else if(divisionString.containsIgnoreCase('Americas')){

                return REGION_AMER;

            } else if(divisionString.containsIgnoreCase('EMEA')){

                return REGION_EMEA;

            } else if(divisionString.containsIgnoreCase('APAC')){

                return REGION_APAC;

            } else if(divisionString.containsIgnoreCase('Japan')){

                return REGION_JAPAN;

            }

        }

        return REGION_DEFAULT;

    }

    

    public static String sendStatusEmail(Database.BatchableContext BC, String subject, String[] toAddresses, String[] bodyLines) {

        if(toAddresses == null || toAddresses.size() == 0 || toAddresses[0] == null || toAddresses[0] == ''){

            return '';

        }

        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, TotalJobItems, CreatedBy.Email  FROM AsyncApexJob WHERE Id =:BC.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(toAddresses);

        mail.setSubject(subject+ ' - '+a.Status);

        

        String body = '';

        for(String line : bodyLines){

            body += line + '\n';

        }

        mail.setPlainTextBody (body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       

        return mail.getPlainTextBody();

    }

    

    // notify case owners when employee adds a comment from portal. 

    public static void notifyCaseOwner(List<Id> caseCommentIds,String caseBody){

        String body;

        if(caseCommentIds!=null && caseCommentIds.size()>0){

            

            List<CaseComment> caseComments = [select id,commentBody,parentId,parent.subject,parent.caseNumber,parent.owner.Email from caseComment where id in : caseCommentIds];

            for(CaseComment ccomment : caseComments){

                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                 mail.setToAddresses(new String[] {ccomment.parent.owner.Email});

                 mail.orgWideEmailAddressId = ESDJC_Settings__c.getInstance().OrgWideEmailAddress_ID_For_Notification__c;

                 mail.setSubject('New case comment notification. Case Number '+ ccomment.parent.caseNumber);

                 body = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html><head><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"></head><body><p>';

                 body = body + userInfo.getName()+' has added a comment to case '+ ccomment.parent.caseNumber  +': "'+ccomment.parent.subject+'"' +'. Please read the comment below and then click on the link to respond appropriately.</p>';

                 body+='<p>Comment:</p>';

                 body+='<p>'+caseBody.escapeHtml4()+'</p>';

                 body+=URL.getSalesforceBaseUrl().toExternalForm()+'/'+ccomment.parentId;

                 System.debug('final body statement' + body);

                mail.setHtmlBody(body);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                

            }

            

        }

        

    }



    public static void notifyReplyEmail(List<Question> questions, List<Reply> replies, List<List<User>> allSubscribers) {
        
        List<Messaging.Singleemailmessage> mails = new List<Messaging.Singleemailmessage>();
        
        for (Integer i = 0; i < questions.size(); i++) {
            Question question = questions[i];
            Reply reply = replies[i];
            List<User> subscribers = allSubscribers[i];
        

        if(subscribers == null || subscribers.size() == 0 || reply == null || question == null){

            return;

        }

        User replier;

        for(User c: subscribers){

            if(c != null && c.id == reply.CreatedById){

                replier = c;

                break;

            }

        }       

        for(User subscriber: subscribers){

            if(subscriber ==  null || subscriber.id == reply.LastModifiedById){

                continue;

            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setCharset('UTF-8');

            mail.setToAddresses(new String[] {subscriber.Email});

            mail.orgWideEmailAddressId = ESDJC_Settings__c.getInstance().OrgWideEmailAddress_ID_For_Notification__c;//fromAddresses.get(0).Id;



             String strConvertedDate = '';

             if(subscriber.timeZoneSidKey != null && reply.LastModifiedDate != null){

                strConvertedDate =  reply.LastModifiedDate.format('hh:mm a', subscriber.timeZoneSidKey)+' on '+reply.LastModifiedDate.format('MM/dd/yyyy', subscriber.timeZoneSidKey)+'.';

             } 

            if(subscriber.id == question.CreatedById){

                mail.setSubject(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_Email_Template_New_reply_on_your_question_Japanese:System.Label.ES_DJC_Email_Template_New_reply_on_your_question);

            } else {

                mail.setSubject(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_Email_Template_New_reply_on_a_question_you_are_following_Japanese:System.Label.ES_DJC_Email_Template_New_reply_on_a_question_you_are_following);

            }         



            String body = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html><head><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"></head><body><p>';


            if(subscriber.id == question.CreatedById){

                if(replier != null){

                    body += replier.Name+' '+(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_Email_Template_added_a_reply_to_your_question_at_Japanese:System.Label.ES_DJC_Email_Template_added_a_reply_to_your_question_at)+' '+ strConvertedDate;// 'Dear '+c.FirstName+',\n';

                }else{

                    body += ' '+(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_Email_Template_user_added_a_reply_to_your_question_at_Japanese:System.Label.ES_DJC_Email_Template_user_added_a_reply_to_your_question_at)+' '+ strConvertedDate;// 'Dear '+c.FirstName+',\n';                 
                }

                //Chuckie Dickens added a reply to Your question at 2:58 PM on 5/20/2013.

            } else {

                if(replier != null){                    

                    body += replier.Name+' '+(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_EMail_Template_added_a_reply_to_a_question_you_are_following_at_Japanese:System.Label.ES_DJC_EMail_Template_added_a_reply_to_a_question_you_are_following_at)+' '+ strConvertedDate;// 'Dear '+c.FirstName+',\n';

                    //Chuckie Dickens added a reply to a question you're following at 3:05 PM on 5/20/2013.

                }else{

                    body += ' '+(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_EMail_Template_user_added_a_reply_to_a_question_you_are_follow_Japanese:System.Label.ES_DJC_EMail_Template_user_added_a_reply_to_a_question_you_are_following_at)+' '+ strConvertedDate; 
                }

            }         

            body += '</p>';

            body += '<p><b>'+(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_Email_Template_Text_Your_question_Japanese:System.Label.ES_DJC_Email_Template_Text_Your_question)+'</b></p>';

            body += '<p>"'+question.Title+'"</p>';

            body += '<p><b>'+(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_Email_Template_Text_Reply_Japanese:System.Label.ES_DJC_Email_Template_Text_Reply)+'</b></p>';

            body += '<p>"'+reply.Body+'"</p>';

            body += '<p><a href="'+getSSOURL()+'/apex/ESDJC_Communities?id='+question.id+'">'+(subscriber.LanguageLocaleKey.equalsIgnoreCase('ja')? System.Label.ES_DJC_Email_Template_Click_here_to_see_the_entire_conversation_Japanese:System.Label.ES_DJC_Email_Template_Click_here_to_see_the_entire_conversation)+'</a> </p>';

            body += '</body></html>';

           // mail.setPlainTextBody (body);

            mail.setHtmlBody(body);

                mails.add(mail);

        }       
        }
        
        if(mails.size() > 0)
            Messaging.sendEmail(mails);

    }

    

    public static List<QuestionSubscription> getQuestionSubscribers(Set<Id> questionIds ) {

        return [SELECT QuestionId, SubscriberId, Subscriber.Email FROM QuestionSubscription WHERE QuestionId IN:questionIds];

    }

    

    public static string getSSOURL(){

        return ESDJC_Settings__c.getInstance().SSO_URL__c;

    }

    

    public static String getSiteURL(){

        return ESDJC_Settings__c.getInstance().Site_URL__c;

    }

    public static void displayAccessPrivilegeErrorOnPage(String actionName) {

        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You don\'t have sufficient privilages to perform '+actionName+' action. Please Contact your System Administrator'));

    }

    

    public static void displayAccessPrivilegeError(String actionName) {

        System.debug('ERROR: You don\'t have sufficient privilages to perform '+actionName+' action. Please Contact your System Administrator');

    }

    

    public static String getNickname(Integer len) {

        Blob blobKey = crypto.generateAesKey(128);

        String key = EncodingUtil.convertToHex(blobKey);

        return key.substring(1,len+1);

    }

      

   public static ID getEmployeeRecordTypeId(){
      return  [select Id from RecordType where sObjectType='Contact' and developerName='Employee' LIMIT 1].Id;

   }
   
      public static Set<ID> getDJCContactRecordTypeIds(){
          RecordType[] rt = [select Id from RecordType where sObjectType='Contact' and developerName in('Employee','Contractor')];
          Set<id> recordTypeIds = new Set<id>();
          if (rt.size()>0){         
            for (RecordType r: rt){
                recordTypeIds.add(r.id);
            }
          }
          return recordTypeIds;
   }
   

    

    /*get user profile name */

     public static String getuserProfile(ID id){

        if (id!=null){

            String profileName;

            User u = [select profile.name from user where id=:id];

            if(u!=null){

                profileName=u.profile.name;

            }

            return profileName;

        }

        return null;

    }

    

    public boolean isBlank(String s){

        return ((s==null)||(s==''));
    }

    

    public static String getUserLanguage(){

        return UserInfo.getLanguage();
    }

    public static List<User> fetchUserDetails(Set<Id> userIds) {
        if (userIds == null) {
            return new List<User>();
        }
        return [SELECT Name, Email, TimeZoneSidKey,LanguageLocaleKey FROM User where Id IN :userIds];
    }
    
    
    public static Database.DMLOptions getAssignmentRulesDMLOption(String Division){
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];                      
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        //if ((Division!=null) && Division.equalsIgnoreCase('Japan')){
            dmlOpts.EmailHeader.TriggerUserEmail = true;
        //}     
        return dmlOpts;     
    }
    
    public static EmailTemplate getEmailTemplate(String template_Name){
        return [select id,name,developername from EmailTemplate where DeveloperName=: template_Name];
    }
    
    public static Map<String, EmailTemplate> getEmailTemplates(List<String> templateNames) {
        Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
        
        for (EmailTemplate e : [select Id, Name, DeveloperName from EmailTemplate where DeveloperName IN :templateNames]) {
            emailTemplateMap.put(e.DeveloperName, e);
        }
        
        return emailTemplateMap;
    }
     
    public static Map<Id,boolean> isValidationsPassed(List<Case> cases){                    
            Map<Id,boolean> validationMap = new Map<Id,boolean>();
            for(Case c : cases){
                if(((c.Status.Contains('Closed') || c.Status.equalsIgnoreCase('Waiting for Response')) && !c.Status.equalsIgnoreCase('Closed - By User')) && (c.origin==null || c.contactId==null || c.Type==null || c.ES_DJC_Topic__c==null))  {
                  validationMap.put(c.Id,false);         
               }
               else{
                  validationMap.put(c.Id,true); 
               }                
            }
            return validationMap;
        }
    
    
    public static boolean canRunTrigger() { 
        if (settings != null) {
            return settings.Run_trigger__c;
        }
        return true;
    }
    
    public static Map<Id,String> validateRequiredFields(Schema.SObjectType soType, SObject record) {
        
        Map<Id,String> SObjectErrorMap = new Map<Id,String>();
        String requiredFieldsErrors = '';
        String errorPrefix = getErrorPrefix(soType);
        Map<String,String> requiredFieldsMap = getRequiredFieldsForSobject(soType);
            
        for(String fieldName : requiredFieldsMap.keySet()) {
            if(record.get(fieldName) == null) {
                requiredFieldsErrors = requiredFieldsErrors + getErrorTextForRequiredField(errorPrefix,requiredFieldsMap.get(fieldName)) + ',';
            }
        }
        
        if(String.isBlank(requiredFieldsErrors) == false) {
            SObjectErrorMap.put(record.Id,requiredFieldsErrors);
            return SObjectErrorMap;
        } 
        
        return null;
    }
    
    private static Map<String,String> getRequiredFieldsForSobject(Schema.sObjectType soType){
    
        Map<String,String> fieldNamesAndLabels = new Map<String,String>();
        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();
        
        if(soType == Warmline__c.sObjectType) {
            fields = SObjectType.Warmline__c.FieldSets.Warmline_Required_Fields_For_Case_Closur.getFields();
        }

        for(Schema.FieldSetMember field : fields){
            fieldNamesAndLabels.put(field.getFieldPath(),field.getLabel());
        }

        return fieldNamesAndLabels;
    }
    
    private static String getErrorPrefix(Schema.sObjectType soType) {
        if(soType == Warmline__c.sObjectType) {
            return 'Warmline';
        }
        return '';
    }
    
    private static String getErrorTextForRequiredField(String objectName, String fieldLabel) {
        return objectName.toUpperCase() + ' ' + fieldLabel.toUpperCase()+' REQUIRED';
    }

    // This is not in use, please remove as soon as possible. It was used for code coverage
    @TestVisible
    private static Boolean checkStatusForEnforcement(String status) {
        if (status == null) {
            return false;
        }

        if ((status.contains(CLOSED) || status.contains(WAITING_FOR_RESPONSE) || status.equalsIgnoreCase(IN_PROGRESS)) && !status.equalsIgnoreCase(CLOSED_BY_USER)) {
            return true;
        }

        return false;
    }
}