public with sharing class ES_CaseAttachmentTriggerHandler {
    
    
    /*this method sets IsPartnerShared flag to true for records where parent is case and is shared with supportforce case via s2s connector. 
    Setting this flag to true enables attachments of size under 25kb to pass to supportforce. */
    public static void checkIsPartnerShared(List<Attachment> attachments){
        set<Id> caseIds = new set<Id>();

        Set<Id> sharedCases = new Set<Id>();
        List<Attachment> attachmentsList = new List<Attachment>();
        for(Attachment a : attachments){
            if(String.valueOf(a.ParentId).startswith('500')){
                caseIds.add(a.parentId);
            }           
        }
        if(caseIds.size() == 0){
            return; 
        }
        
        for(Case c : [select Id from Case where Id in : caseIds and ESDJC_Supportforce_Case_Number__c!=null]){
            sharedCases.add(c.Id);
        }
        for(Attachment att : attachments){
            if(sharedCases.contains(att.ParentId)){
                attachmentsList.add(new Attachment(Id=att.Id,IsPartnerShared = true));
            }
        }
        if(!attachmentsList.isEmpty()){
            try{
                update attachmentsList;
            } catch (DMLException e){ 
                System.debug('Exception occured' + e.getMessage());
            }
        }   
    }
    public static void reAssociateEmailAttachments(list<Attachment> attachments ){
        set<Id> emailMessageIds = new set<Id>();
        for(Attachment a : attachments){
            //Check if attachment is from email
            if(String.valueof(a.ParentId.getSobjectType()).equalsIgnoreCase('EmailMessage')){
                emailMessageIds.add(a.parentId);
            }           
        }       
        if(emailMessageIds.size()>0){
            map<Id,EmailMessage> mailWithAttachments = new map<Id,EmailMessage>([select id,subject,MessageDate,ParentId from EmailMessage where id in :emailMessageIds]);
            for(Attachment a : attachments){
                //If attachment is from email ,re-associate it to related case.
                if(emailMessageIds.contains(a.parentId)){
                    EmailMessage email = mailWithAttachments.get(a.parentId);
                    
                    //Check if email is from email To case.
                    if(String.valueof(email.ParentId.getSobjectType()).equalsIgnoreCase('Case')){ 
                        a.parentId= email.ParentId;

                        //Change Name of the attachment.
                     
                        String Extension =  a.name.substringAfterLast('.');
                        system.debug(LOGGINGLEVEL.INFO,'Extension '+Extension);
                        Extension = String.IsBlank(Extension) ? ' ' : '.' +Extension; 

                        String AttchmntNameWithoutExt =  a.name.removeEndIgnoreCase(Extension);
                        system.debug(LOGGINGLEVEL.INFO,'AttchmntNameWithoutExt '+AttchmntNameWithoutExt);
                    
                        a.Name  =email.MessageDate.format('yyyy-MM-dd HH:mm:ss',UserInfo.getTimeZone().getID())+' - ' +AttchmntNameWithoutExt + ' - '+ email.subject ;
                        system.debug(LOGGINGLEVEL.INFO,'Name before truncate'+a.Name);

                        //Attachment name limit is 80 - Truncate if larger.
                        if(a.Name.length()>70){
                            a.Name = a.Name.substring(0,70);
                        }  
                        a.Name  = a.Name + Extension;
                        system.debug(LOGGINGLEVEL.INFO,'Name after truncate'+a.Name);
                        
                    }
                }
         } 
             
        }
    }
    
}