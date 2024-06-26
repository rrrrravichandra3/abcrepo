/*
*  @Author : Prathap
*  W-7739658 - M&A Preboarding App - Ability to share large number of tableau records
*  This batch job is to handle large number of acquisition compensation records when sharing acquisition company record
*  After refactoring we should not get DML exception
*/

global class MA_AcquisitionCompensationShareBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    //constructor variables
    private Id compId;
    private set<Id> userIds;
    private List<Acquisition_Company__Share> companyShares;
    private Map<Id, String> selectedUserIds;
    private string deleteShareUser;
    private string action;
    
    //Stateful variables
    @TestVisible
    private Map<Id, decimal> failedBatchRecordCount = new Map<Id, decimal>();
    @TestVisible
    private Map<String, String> failedDeleteBatchRecordCount = new Map<String, String>();
    private decimal totalFailedCount;
    private decimal totalScopeCount;
    Private Integer successfulDelCount = 0;
    private Map<Id, decimal> totalScopeRecords = new Map<Id, decimal>();
    
    //Constructor
    public MA_AcquisitionCompensationShareBatch(Id companyId, set<Id> usersId, List<Acquisition_Company__Share> companyShare, Map<Id, String> selectedUserIdsMap, String deleteShareUserId, String actionType) {
        compId = companyId;
        userIds = usersId;
        companyShares = companyShare;
        selectedUserIds = selectedUserIdsMap;
        deleteShareUser = deleteShareUserId;
        action = actionType;    
       // system.debug(usersId+ '  **actionType*** '+selectedUserIdsMap+ ' *** ' +deleteShareUserId);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {    
        String query;   
        If(action == 'SAVE'){       
            query = 'SELECT Id, Name FROM Acquisition_Compensation__c Where Acquisition_Contact__r.Acquisition_Company__c =: compId';           
        }else if(action == 'DELETE'){  
            query = Test.isRunningTest()?'SELECT AccessLevel,Id,ParentId,RowCause,UserOrGroupId FROM Acquisition_Compensation__Share WHERE RowCause=\'From_Company_Sharing__c\' AND UserOrGroupId=:deleteShareUser':
            'SELECT AccessLevel,Id,ParentId,RowCause,UserOrGroupId FROM Acquisition_Compensation__Share WHERE Parent.Acquisition_Contact__r.Acquisition_Company__c=: compId and RowCause=\'From_Company_Sharing__c\' AND UserOrGroupId=:deleteShareUser';
        }       
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
     try{  
        //Scope variables
        Integer successfulDeleteCount = 0;
        Map<Id, decimal> failedRecordCount = new Map<Id, decimal>();
        Map<String, String> failedDeleteRecordCount = new Map<String, String>(); 
        set<Id> setofSharingIds = new set<Id>();
        Map<Id, decimal> totalRecords = new Map<Id, decimal>();
        Map<Id, List<Acquisition_Compensation__Share>> successRecordsInfo = new Map<Id, List<Acquisition_Compensation__Share>>();        
        
        //Executed when Save is clicked on VF Page       
        If(action == 'SAVE'){                                  
            List<Acquisition_Compensation__Share> compensationShares = new List<Acquisition_Compensation__Share>();                            
            for(Id userId : userIds){ 
                for(sObject compensation : scope){
                    compensationShares.add(new Acquisition_Compensation__Share(ParentId=compensation.Id , UserOrGroupId = userId, RowCause='From_Company_Sharing__c', AccessLevel='Edit'));                                 
                    //Total Records Scope Map
                    if(totalRecords.containsKey(userId)){
                        decimal totalRecord = 0;                               
                        totalRecord+= scope.size();                               
                        totalRecords.put(userId, totalRecord);                           
                    }else{                           
                        totalRecords.put(userId, scope.size());                            
                    } 
                }
                
            }
            if(!compensationShares.isEmpty()){             
                Database.SaveResult[] compensationSharesSaveResult = Database.insert(compensationShares, false);                        
                if(!compensationSharesSaveResult.isEmpty()){                    
                    //Total success Map
                    for(Integer i=0;i<compensationSharesSaveResult.size();i++){                           
                        if(compensationSharesSaveResult.get(i).isSuccess()){                               
                            setofSharingIds.add(compensationSharesSaveResult.get(i).getId());
                        }                           
                    }
                    if(!setofSharingIds.isEmpty()){                
                        for(Acquisition_Compensation__Share share: [SELECT Id,ParentId,UserOrGroupId FROM Acquisition_Compensation__Share WHERE Id IN: setofSharingIds]){
                            //Success insert Ids 
                            if(!successRecordsInfo.containsKey(share.UserOrGroupId)){
                                successRecordsInfo.put(share.UserOrGroupId, new List<Acquisition_Compensation__Share>());
                            }
                            successRecordsInfo.get(share.UserOrGroupId).add(share);
                        }  
                    }                
                    for(Id userId: totalRecords.keyset()){ 
                        //Failed records count  
                        if(successRecordsInfo.containsKey(userId)){
                            failedRecordCount.put(userId, totalRecords.get(userId)-successRecordsInfo.get(userId).size());
                        }else{
                            failedRecordCount.put(userId, totalRecords.get(userId)); 
                        } 
                    }                                                                     
                    if(!failedRecordCount.isEmpty()){
                        for(Id userId: failedRecordCount.keyset()){
                            //Complete batch failed records count               
                            if(failedRecordCount.get(userId) != 0){   
                                if(!failedBatchRecordCount.containsKey(userId)){                   
                                    failedBatchRecordCount.put(userId, failedRecordCount.get(userId));                                          
                                }else{                                      
                                    totalFailedCount = failedBatchRecordCount.get(userId) + failedRecordCount.get(userId);                        
                                    failedBatchRecordCount.put(userId, totalFailedCount);                       
                                }           
                            }             
                        }     
                    }                
                    if(!totalRecords.isEmpty()){           
                        for(Id userId: totalRecords.keyset()){           
                            if(!totalScopeRecords.containsKey(userId)){               
                                totalScopeRecords.put(userId, totalRecords.get(userId));                   
                            }else{                   
                                totalScopeCount = totalScopeRecords.get(userId) + totalRecords.get(userId);                   
                                totalScopeRecords.put(userId,totalScopeCount); 
                            }
                        }
                    } 
                    
                }       
            }                        
        }else if(action == 'DELETE'){ //Executed when Delete hyperlink is clicked on VF Page       
            Database.DeleteResult[] compensationSharesDeleteResult =  Database.Delete(scope, false);  
            if(!compensationSharesDeleteResult.isEmpty()){                            
                for(Integer i=0;i<compensationSharesDeleteResult.size();i++){                                
                    if(compensationSharesDeleteResult.get(i).isSuccess()){
                        successfulDeleteCount++;
                    }else{
                        String failedCompDescName = String.ValueOf((scope.get(i)).Id);
                        String errorMessage = '';
                        for(Database.Error err : compensationSharesDeleteResult.get(i).getErrors()){
                            errorMessage = errorMessage + ' | ' + err.getMessage();
                        }
                        failedDeleteRecordCount.put(failedCompDescName,errorMessage);
                    }
                }                                                   
            }         
            if(!failedDeleteRecordCount.isEmpty()){
                failedDeleteBatchRecordCount = failedDeleteRecordCount;                     
            }
            if(successfulDelCount==0){           
                successfulDelCount = successfulDeleteCount;           
            }else{           
                successfulDelCount = successfulDelCount+successfulDeleteCount;               
            }  
        } 
        }catch(Exception e){
            PF_Logger.log('M&A','ERROR',e.getMessage(),' Error occured while deleting Acquisition Compensation Share records ',' UserId '
            + UserInfo.getUserId(), 'MA_AcquisitionCompensationShareBatch');
        }             
    }   
    
    global void finish(Database.BatchableContext BC) {
        //Mail is sent when all records in the scope are inserted successfully
        If(action == 'SAVE'){
            if(failedBatchRecordCount.isEmpty()){                  
                if(selectedUserIds.keySet().size() > 0 && compId != null){                   
                    EmailTemplate maNotificationEmailTemplate=[SELECT id FROM EmailTemplate WHERE DeveloperName = 'M_A_Company_Sharing_Notifications' LIMIT 1];  
                    orgWideEmailAddress owdEmailAddress=[SELECT id FROM OrgWideEmailAddress WHERE Address = 'employeesuccessma@salesforce.com' LIMIT 1];
                    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage ();
                    email.setTemplateId(maNotificationEmailTemplate.Id);
                    email.setSaveAsActivity(false);
                    List<User> users = [SELECT Id, Name, Email FROM User WHERE Id IN :  userIds];
                    Contact userContact = [SELECT Id FROM Contact WHERE Email like : UserInfo.getUserEmail()+'%' limit 1];
                    if(userContact == null) userContact = [SELECT Id FROM Contact limit 1];                   
                    email.setTargetObjectId(userContact.Id);
                    List<String> emailAddresses = new List<String>();
                    for(User usr: users){
                        emailAddresses.add(usr.Email);
                    }
                    email.setToAddresses(emailAddresses);
                    email.setWhatId(compId);
                    emails.add(email);
                    email.setOrgWideEmailAddressId(owdEmailAddress.Id);
                    if(!Test.isRunningTest()){
                        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
                    }
                }                    
            }else{//Mail is sent when all partial records in the scope are inserted or if error occurs  
                if(!failedBatchRecordCount.isEmpty()){                 
                    Map<Id,User> userNameMap = new  Map<Id,User>([Select id, Name From User Where Id IN:failedBatchRecordCount.keyset()]);                                              
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {UserInfo.getUserEmail()};
                        mail.setToAddresses(toAddresses);
                    mail.setSenderDisplayName(System.Label.PF_MA_Compensation_Share_Sender_Display_Name);
                    mail.setSubject(System.Label.PF_MA_Compensation_Share_Subject);                        
                    String message = System.Label.PF_MA_Compensation_Share_Hello +' '+UserInfo.getName()+','+'\n';                        
                    message = message + '\n'+System.Label.PF_MA_Compensation_Share_Body +'\n';                       
                    for(Id userID : failedBatchRecordCount.keySet()){                            
                        message = message +'\n'+userNameMap.get(userID).Name+ ' : '+failedBatchRecordCount.get(userID)+' '+System.Label.PF_MA_Compensation_Share_Sub_Body+' '+totalScopeRecords.get(userID) ;                            
                    }                      
                    message = message+'\n'+'\n'+System.Label.PF_MA_Compensation_Share_Thanks;
                    mail.setPlainTextBody(message);                       
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                       
                }                  
            } 
            
        }else if(action == 'DELETE'){
            //Mail is sent when all partial records in the scope are deleted or if error occurs            
            if(!failedDeleteBatchRecordCount.isEmpty() && deleteShareUser!=null){                        
                Map<Id,User> userNameMap = new  Map<Id,User>([Select id, Name From User Where Id =: deleteShareUser]);                        
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                       
                String[] toAddresses = new String[] {UserInfo.getUserEmail()};
                    mail.setToAddresses(toAddresses);                       
                mail.setSenderDisplayName(System.Label.PF_MA_Compensation_Delete_Sender_Display_Name);
                mail.setSubject(System.Label.PF_MA_Compensation_Share_Subject);                
                String message = System.Label.PF_MA_Compensation_Share_Hello +' '+UserInfo.getName()+','+'\n';   
                message = message + '\n'+System.Label.PF_MA_Compensation_Delete_Body +' '+failedDeleteBatchRecordCount.keySet().size()+' '+System.Label.PF_MA_Compensation_Delete_Sub_Body +' '+successfulDelCount+' '+System.Label.PF_MA_Compensation_Delete_Sub_Body_Text +' '+userNameMap.get(deleteShareUser).Name +'\n' ;                      
                for(String compDescName : failedDeleteBatchRecordCount.keySet()){
                    message = message +'\n'+compDescName + ' : '+failedDeleteBatchRecordCount.get(compDescName);
                } 
                message = message+'\n'+'\n'+System.Label.PF_MA_Compensation_Share_Thanks;                     
                mail.setPlainTextBody(message);                       
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });      
            }                      
        }     
    }   
}