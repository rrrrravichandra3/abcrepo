public without sharing class MA_UpcomingEventsController {

    public class picklistValues{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Object>> getEventsAttendeesRecords(){
        try{
            Map<String, List<Object>> dataByObjectName = new Map<String, List<Object>>();
            List<MA_Community_Event_Attendee__c> communityEventsList = new List<MA_Community_Event_Attendee__c>();
            List<MA_UpcomingEventsSettings__c> settingsEventList = new List<MA_UpcomingEventsSettings__c>();
            
            Acquisition_Contacts__c acqCon = MA_AcquisitionStore.getAcquisitionContactByEmail(UserInfo.getUserEmail());
            for(MA_Community_Event_Attendee__c communityEventRecord : [SELECT Id, Name, Community_Event__c, RSVP__c, 
                                                                       Community_Event__r.CreatedDate,Community_Event__r.Active__c,
                                                                       Community_Event__r.Last_Processed_State__c ,Community_Event__r.Description__c
                                                                       FROM MA_Community_Event_Attendee__c
                                                                       WHERE Acquisition_Contacts__c =: acqCon.Id AND 
                                                                       Community_Event__r.Active__c = true AND 
                                                                       Community_Event__r.Start_Date__c != null
                                                                       LIMIT :Limits.getLimitQueryRows()]) 
            {
                
                communityEventsList.add(communityEventRecord);
                
            }
            dataByObjectName.put('MA_Community_Events__c', communityEventsList);
            
            MA_UpcomingEventsSettings__c settingsEventRecord = MA_UpcomingEventsSettings__c.getInstance ('MA_SettingsEvents');
            settingsEventList.add(settingsEventRecord);
            dataByObjectName.put('MA_UpcomingEventsSettings__c', settingsEventList);
            
            dataByObjectName.put('picklistValues', getPicklistValues());
            
            return dataByObjectName;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage()+' '+ex.getStackTraceString());
        }
    
    }
    
    @AuraEnabled
    public static void updateRSVPValue(String recordId, String response){
        try{
            update new MA_Community_Event_Attendee__c(Id = recordId, RSVP__c = response);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage()+' '+ex.getStackTraceString());
        }
    }
    

    private static List<picklistValues> getPicklistValues(){
        List<picklistValues> picklistWrapperList = new List<picklistValues>();
        Schema.DescribeFieldResult fieldResult = MA_Community_Events__c.Event_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            if(f.isActive()){
                picklistValues wrapperRecord = new picklistValues();
                wrapperRecord.label = f.getLabel();
                wrapperRecord.value = f.getValue();
                picklistWrapperList.add(wrapperRecord);
            }
        }
        return picklistWrapperList;
    }
}