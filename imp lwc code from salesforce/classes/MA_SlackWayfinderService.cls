public with sharing class MA_SlackWayfinderService {


    /**
     * Accepts a list of slack messages to send to Workato and prepares the JSON to call Workato API.
     * Determines whether to call as Future Method or Synchronous
     * @param messages List<SlackMessageBody> - List of messages to send
     * @param callAsFuture Boolean - Whether you want to send in Async or Synchronous
     */
    public static void sendMessagestoSlackWayfinderBot(List<SlackMessageBody> messages, Boolean callAsFuture){
        if(!messages.isEmpty()){
            String body = JSON.serialize(messages);
            body = '{"messages":'+body+'}';
            if(callAsFuture){
                if(system.isFuture() || system.isBatch()) {
                    system.enqueueJob(new MA_CallSlackApiQueuable(body));
                } else {
                    callApiAsync(body);
                }
            }else {
                callApiSynchronous(body);
            }
        }
    }

    @future(callout=true)
    public static void callApiAsync(string body){
        HttpResponse res = workatoWayfinderServiceCallout(body);
        boolean success = workatoWayfinderResponseHandler(res);
        if (success){
            System.debug('Successfully sent message to slack');
        } else {
            System.debug('Failed to send message to slack');
        }
        PF_Logger.createLogs(PF_Logger.logs);
    }

    public static void callApiSynchronous(string body){
        HttpResponse res = workatoWayfinderServiceCallout(body);
        boolean success = workatoWayfinderResponseHandler(res);
        if (success){
            System.debug('Successfully sent message to slack');
        } else {
            System.debug('Failed to send message to slack');
        }
        PF_Logger.createLogs(PF_Logger.logs);
    }

    /**
        Executes a call to the workato wayfinder bot service, which in turn will call Slack corporate workspace
     */
    @TestVisible
    public static HttpResponse workatoWayfinderServiceCallout(String body){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:WorkatoWayfinder');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('API-Token', '{!$Credential.Password}');
        request.setBody(body);
        try {
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            return response;
        }catch(Exception e){
            PF_Logger.log('Wayfinder Slack Integration', 'ERROR', e.getMessage(), '', 'Callout to workato wayfinder service failed.', 'Wayfinder');
            return null;
        }
    }

    /**
        Parses response from the workato wayfinder service and logs errors if any are found.
        As this is essentially a one-way notification, nothing to do if the request was successful
    */
    @TestVisible
    public static boolean workatoWayfinderResponseHandler(HttpResponse response){
        boolean success = false;
        if(response !=null){
            if (response.getStatusCode() != 200) {
                PF_Logger.log('Wayfinder Slack Integration', 'ERROR', response.getBody(), '', 'Callout to workato wayfinder service failed.', 'Wayfinder');
            } else {
                Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                if (res.get('status') != 'ok'){
                    PF_Logger.log('Wayfinder Slack Integration', 'ERROR', response.getBody(), '', 'Callout to workato wayfinder service responded with 200 but body returned unexpected payload. ', 'Wayfinder');
                } else {
                    success = true;
                }
            }
        }
        return success;
    }

    /**
     This class represents the expected payload for the workato wayfinder api
     * @param emailAddress - EMAIL ADDRESS OF SLACK EMPLOYEE
     * @param message - MESSAGE TEXT TO EMPLOYEE
     * @param link - DEEPLINK TO CASE IN COMMUNITY
     * @param buttonText - TEXT OF BUTTON DISPLAYED IN SLACK MESSAGE
     */
    @TestVisible
    public class SlackMessageBody {
        public SlackMessageBody(String email_address, String message_text, String button_link, String button_text){
            this.email_address = email_address;
            this.message_text = message_text;
            this.button_link = button_link;
            this.button_text = button_text;
        }
        String email_address;
        String message_text;
        String button_link;
        String button_text;
    }

    public static List<Case> getCaseInfo(List<Id> ids){
        List<Case> maCases = new ElevatedContext().performCaseQuery(ids);

        return maCases;
    }
    
    public static List<Acquisition_Contact_Task__c> getTaskInfo(List<Id> ids){
        return new ElevatedContext().performTaskQuery(ids);
    }
    
    public static Map<String, String> getContactInfo(List<String> emails){
        return new ElevatedContext().performContactQuery(emails);
    }

    private without sharing class ElevatedContext{
        public List<Case> performCaseQuery(List<Id>  ids){
            List<Case> maCases = [SELECT Id,CaseNumber, Status,Acquisition_Contact__r.Email_Address_Target__c,Contact.Email,ES_DJC_Last_Comment__c, Contact.M_A_Community_URL__c FROM CASE WHERE Id IN: ids ];
            return maCases;
        }
        
        public Map<String, String> performContactQuery(List<Id>  ids) {
            Map<String, String> emailCummunityUrlMap = new Map<String, String>();

            for(Contact con : [SELECT Acquisition_Contacts__r.Email_Address_Target__c, M_A_Community_URL__c FROM Contact WHERE Acquisition_Contacts__r.Email_Address_Target__c != null AND Acquisition_Contacts__c IN: ids ]) {
                emailCummunityUrlMap.put(con.Acquisition_Contacts__r.Email_Address_Target__c, con.M_A_Community_URL__c);
            }
            return emailCummunityUrlMap;
        }
        
        public List<Acquisition_Contact_Task__c> performTaskQuery(List<Id>  ids) {
            return [SELECT Acquisition_Contact__r.Email_Address_Target__c, Subject__c FROM Acquisition_Contact_Task__c WHERE Acquisition_Contact__r.Email_Address_Target__c != null AND Id IN: ids ];
        }

    }
}