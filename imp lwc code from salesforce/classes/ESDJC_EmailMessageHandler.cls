public with sharing class ESDJC_EmailMessageHandler {
    
    private static ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();

     public static void checkValidationsConsole(List<EmailMessage> triggerNew){
              
         if(!UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c) && !UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c) && !UserInfo.getUserId().equals(settings.djc_Helpdesk_API_User__c)){ //only console users (and not helpdek api user) 
                      
            Set<Id> caseIds = ESDJC_CollectionHelper.getIdFieldSet(triggerNew, 'parentId');
            String validRTSOQL = 'select id from RecordType where developername in '+ System.Label.ES_DJC_ValidationsCheck_SOQL;
            Set<Id> validRecordTypeIds = (new Map<Id,sObject>(Database.query(validRTSOQL))).keySet();   //exclude NHW and Package mgmnt cases*/             

            Map<Id, Case> cases = new Map<Id, Case>([select id,recordtypeId,Status,origin,contactId,Type,ES_DJC_Topic__c,ES_DJC_Sub_Topic__c from case where id in : caseIds and recordTypeid in :validRecordTypeIds ]);
            Map<Id,boolean> getMapValidations = ESDJC_Util.isValidationsPassed(cases.values());
            for(EmailMessage cc : triggerNew){
                if(!cc.Incoming && getMapValidations.get(cc.parentId)!=null && !getMapValidations.get(cc.parentId)){
                    List<String> params = new List<String>{cases.get(cc.ParentId).Status};
                    String errMessage = String.format(System.Label.ES_DJC_Validations_Error_Message, params);
                    cc.addError(errMessage);
                    ESDJC_Util.IgnoreCaseIds.add(cc.parentId);
                }
                
            }
            
         }
    }

    public static void updateCaseResponseFlag(List<EmailMessage> messages){

        List<EmailMessage> messagesToProcess = new List<EmailMessage>();



        for (EmailMessage email : messages){
            if (!email.Incoming && email.ParentId != null && ((String)email.ParentId).startsWith('500') && (email.Headers == null || !email.Headers.containsIgnoreCase('Auto-Submitted: auto-generated'))){
                messagesToProcess.add(email);
            }
        }

        Set<Id> caseIds = ESDJC_CollectionHelper.getIdFieldSet(messagesToProcess, 'parentId');
        ESDJC_CaseHandler.updateCaseResponseFlag(caseIds);
    }
    
    public static void sendAutoResponseEmailForClosedCases(List<EmailMessage> messages){

        List<EmailMessage> incomingMessages = new List<EmailMessage>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
                
        for (EmailMessage email : messages){
            
            if (email.Incoming && email.ParentId != null && ((String)email.ParentId).startsWith('500')){
            
                incomingMessages.add(email);
                caseIds.add(email.ParentId);
            }
        }  
                
        for(Case c : [Select Id,ClosedDate from Case where Id IN :caseIds]){
        
            caseMap.put(c.Id,c);
        
        }
        
        
        for (EmailMessage email : incomingMessages){

            Set<String> japaneseEmailAddresses = new Set<String>(); 
            String japaneseEmailAlias = System.Label.E2C_Japan_Email;                           
            Case caseRec;
            
            if(caseMap.get(email.ParentId)!= null){
                
                caseRec = caseMap.get(email.ParentId);
            }
                        
            if(caseRec !=null){
            
                if(caseRec.ClosedDate != null){
                    
                    Date caseCloseDate = caseRec.ClosedDate.date();
                    Date currentDate = System.Today();
                    Integer numberDaysClosed = caseCloseDate.daysBetween(currentDate);
                                    
                    if(numberDaysClosed > Integer.valueOf(System.Label.E2C_Number_of_Days_Since_Case_Closed)){
                    
                        String fromAddresses = email.fromAddress;  
                        String toAddresses = email.toAddress;  

                        for(String str : japaneseEmailAlias.split(',')){
               
                           japaneseEmailAddresses.add(str);
           
                        }        
                                            
                        Boolean isInternalEmployee = fromAddresses.containsIgnoreCase(System.Label.E2C_Internal_Employee_Email);
                        Boolean isJapaneseAddress = japaneseEmailAddresses.add(toAddresses);
                                            
                        if(isInternalEmployee){
                        
                            if(!isJapaneseAddress){
                            
                                Messaging.SingleEmailMessage mail = createEmailMessage(fromAddresses,System.Label.E2C_Internal_Employee_JP_Email_Subject,System.Label.E2C_Internal_Employee_JP_Email_Body);
                                mails.add(mail);
                                                            
                            }
                            else{
                                
                                Messaging.SingleEmailMessage mail = createEmailMessage(fromAddresses,System.Label.E2C_Internal_Employee_Non_JP_Email_Subject,System.Label.E2C_Internal_Employee_Non_JP_Email_Body);
                                mails.add(mail);              
                            }                       
                        }
                        
                        else{
                            
                            if(!isJapaneseAddress){
                                
                                Messaging.SingleEmailMessage mail = createEmailMessage(fromAddresses,System.Label.E2C_External_JP_Email_Subject,System.Label.E2C_External_JP_Email_Body);
                                mails.add(mail); 

                            }
                            else{
                            
                                Messaging.SingleEmailMessage mail = createEmailMessage(fromAddresses,System.Label.E2C_External_Non_JP_Email_Subject,System.Label.E2C_External_Non_JP_Email_Body);
                                mails.add(mail); 
                            
                            }
                        }
                    }
                }                       
            }                 
        }  
                
        Messaging.sendEmail(mails);
        
    }

    private static Messaging.SingleEmailMessage createEmailMessage(String fromAddresses, String emailSubject, String emailBody){
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{fromAddresses});
        mail.subject = emailSubject;
        mail.setHtmlBody(emailBody);
        mail.setOrgWideEmailAddressId([Select Id from OrgWideEmailAddress where Address =:System.Label.E2C_Org_Wide_Email_Address].Id);
        return mail;
    
    }

}