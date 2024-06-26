@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
global with sharing class NHW_RetryPFDebugLog implements Schedulable, Database.AllowsCallouts{
    public static PF_Debug_Log1_Settings__c pfDebugLogSetting;
    public static Integer retryCount;
    public static Integer retryInterval; 
    
    private List<PF_Debug_Log__c> recordsToProcess;
    private Integer attempts;
    
    public NHW_RetryPFDebugLog(List<PF_Debug_Log__c> recordsToProcess, Integer attempts){
        this.recordsToProcess = recordsToProcess;
        this.attempts = attempts;
        
        pfDebugLogSetting = PF_Debug_Log1_Settings__c.getInstance();
        retryCount = Integer.valueOf(pfDebugLogSetting.Number_of_Retries__c);
        retryInterval = Integer.valueOf(pfDebugLogSetting.Retry_Interval__c);
    }
    
    global void execute(SchedulableContext context){
        List<PF_Debug_Log__c> calloutList = new List<PF_Debug_Log__c>();
        List<PF_Debug_Log__c> updateRetryProcessedFlag = new List<PF_Debug_Log__c>();
        for(PF_Debug_Log__c p:recordsToProcess){
            system.debug('**** p.Component__c ' + p.Component__c + ' p.Description__c ' + p.Description__c);
            if((p.Component__c != null && p.Component__c == 'NHW_Org62Service' && p.Description__c != null) && ((p.Description__c.startswith('Org62 Callout:') && p.Description__c.contains('Create Campaign member successful') &&
                  !p.Description__c.contains('CampaignId')) ||
                  (p.Description__c.startswith('CampaignMemberDelete Callout:') &&
                  !p.Description__c.contains('CampaignId')) ||
                  (p.Description__c.contains('Update to Org62 contact successful') && 
                   !p.Description__c.contains('coId)')))){
                        calloutList.add(p);
            }
            if(p.Processed_for_Retry__c == false) {
                p.Processed_for_Retry__c = true;
                updateRetryProcessedFlag.add(p);
            }
        }
        if(calloutList != null && calloutList.size() >0){
            system.debug('*****calloutList ' + calloutList);
            retryCallout(calloutList, attempts);
        }
        if(updateRetryProcessedFlag != null && updateRetryProcessedFlag.size() > 0 && PF_Debug_Log__c.sObjectType.getDescribe().isUpdateable()){
            try {
                    Database.update(updateRetryProcessedFlag, false);
                }  catch (DmlException ex) { 
                    system.debug('The following exception has occurred: ' + 
                                ex.getDmlStatusCode(0) + ex.getMessage());
                }	
        }
    }
    
    public static void retryCallout(List<PF_Debug_Log__c> calloutList, Integer attempts){
        String[] calloutStringArray = new List<String>();
        Boolean isSuccess = false;
        String retryResult;
        String nhNameConstant = ' & NH Name = ';
        String systemDebugPrefix = '*****Adding retryResult ';
        Map<String,String> retryResultMap = new Map<String,String>();

        List<PF_Debug_Log__c> recordsToRetry = new List<PF_Debug_Log__c>();
        for(PF_Debug_Log__c log:calloutList) {
            retryResult = '<br>';
            if(log.Callout__c != null && log.Callout__c != ''){
                calloutStringArray = parseCallOutString(log.Callout__c);
            }
            system.debug('**** calloutStringArray :' + calloutStringArray + ' attempts so far :'+attempts+' retryCount :' + retryCount + ' retryInterval :' + retryInterval);
            
            if(calloutStringArray != null && calloutStringArray.size() >= 3) {
                try{ 
                    HTTPResponse res = NHW_Util.performCallOut(calloutStringArray[0], calloutStringArray[1], calloutStringArray[2], calloutStringArray[3]);
                    if(res!=null && res.getStatusCode() == 200){
                        if(res.getBody() != null && res.getBody().contains('CampaignId')){
                            isSuccess = true;
                            retryResult = retryResult + 'Retry successful. Response = ' + res.getBody() + nhNameConstant + log.NH_Name__c + '<br>';
                            system.debug(systemDebugPrefix + retryResult);
                            break;
                        }
                        else{
                            retryResult = retryResult + 'Received OK response while performing retry with StatusCode = 200 but non OK Resp7onse = ' + res.getBody() + nhNameConstant + log.NH_Name__c + '<br>';
                            system.debug(systemDebugPrefix + retryResult);
                            recordsToRetry.add(log);
                        }
                    }
                    else{
                        retryResult = retryResult + 'Received non-OK response while performing retry with StatusCode = ' + res.getStatusCode() + ' Response = ' + res.getBody() + nhNameConstant + log.NH_Name__c + '<br>';
                        system.debug(systemDebugPrefix + retryResult);
                        recordsToRetry.add(log);
                    }
                }
                catch(Exception e){
                    retryResult = retryResult + 'Exception occurred while performing retry. Exception Message = ' + e.getMessage() + ' Type Name = ' + e.getTypeName() + ' at Line Number ' + e.getLineNumber() + nhNameConstant + log.NH_Name__c + '<br>';
                    system.debug(systemDebugPrefix + retryResult);
                }
            }
            System.debug('**** final retryResult ' + retryResult);
            retryResultMap.put(log.NH_Name__c,retryResult); 
        }
        attempts = attempts + 1;
        if(attempts >= retryCount) {
            sendRetryReportEmail(retryResultMap);
        }
        else {
            if(recordsToRetry.size() > 0) {
                Datetime sysTime = System.now().addSeconds(retryInterval);
                String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                System.schedule('NHW_RetryPFDebugLog ' + sysTime, chronExpression, new NHW_RetryPFDebugLog(recordsToRetry, attempts + 1));
            }
        }
    }
    
    public static void sendRetryReportEmail(Map<String,String> retryResult){
        System.Debug('Inside sendRetryReportEmail');
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Email> allMails = new List<Messaging.Email>();
        Id senderId = NHW_Util.getOrgWideEmail('noreply_nhw@salesforce.com');
        String[] toAddresses = new String[]{'itscrum-onboarding@salesforce.com'};
        for(String s:retryResult.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                                 
            mail.setToAddresses(toAddresses);
            mail.setOrgWideEmailAddressId(senderId);
            mail.setSubject('Org62 Callout Retry Results for ' + s);
            mail.setHtmlBody(draftEmailText(retryResult.get(s)));
            mail.setCharset('UTF-8');
            emailList.add(mail);    
        }
        if(emailList != null && emailList.size()>0){
            System.Debug('Emaillist values ' + emailList);
            try{
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);
                if (!results.get(0).isSuccess()) {
                System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
                String errorMessage = results.get(0).getErrors()[0].getMessage();
                System.Debug('Error Message ' + errorMessage);
                } 
            }
            catch(Exception ex){
            system.debug('*****Exception occurred while sending Retry Report ' + ex.getMessage());  
            }
        }   
    }
    
    private static String[] parseCallOutString(String calloutString){
        String[] calloutParams = new List<String>();
        if(calloutString != null && calloutString != ''){
            for(String s:calloutString.split(';;')){
                calloutParams.add(s);
            }
        }
        if(calloutParams != null && !calloutParams.isEmpty()){
            return calloutParams;
        }
        else{
            return null;
        }
    }
    
    //Added for background check confirmation
    public static String draftEmailText(String retryResult){
        String form = '<!DOCTYPE html>' +
            '<html>' +
            'Hi Onboarding Scrum Team, <br><br> ' +
            'Retry results while performing Org62 Callout are as follows: ' + retryResult + '.<br><br>' + 
            'Thank you. <br><br>'+
            'Regards, <br><br>'+
            'Salesforce<br><br>'+
            '</html>';            
        return form;
    }
}