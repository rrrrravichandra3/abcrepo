public with sharing class ES_AnalyticsController {
  @RemoteAction
  @AuraEnabled public static String getTrackingId(){
    String trackingId = '';
    WDC_Settings__c setting = WDC_Settings__c.getOrgDefaults();
    if (String.isNotBlank(setting.Analytics_Tracking_Id__c)) {
      trackingId = setting.Analytics_Tracking_Id__c;
    }
    return trackingId;
  }
}