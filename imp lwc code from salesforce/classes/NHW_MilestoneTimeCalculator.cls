global with sharing class NHW_MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    
    @TestVisible
    private static Integer DEFAULT_TIME = 1; // in minutes
    private static String PROVISIONING_RECORDTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Hire_Process_Onboarding').getRecordTypeId();
    private static BusinessHours DEFAULT_BUSINESSHOUR = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1]; 
    private static Map<String, NH_Shipping_SLA__mdt> mapSlaMdtByName = getMapSlaMdtByName();

    global Integer calculateMilestoneTriggerTime (String caseId, String milestoneTypeId){
        Long calculatedTime = 0;

        Case c = [SELECT CreatedDate, Entitlement.BusinessHoursId, NHW_Start_Date__c, Shipping_Country__c, Office_Country__c, NHW_Job_Application__r.Business_Site__c, NHW_Job_Application__r.Business_Site__r.City__c, RecordTypeId FROM Case WHERE Id=:caseId];
        Id entitlementBusinessHoursId = c.Entitlement.BusinessHoursId == null ? DEFAULT_BUSINESSHOUR.Id : c.Entitlement.BusinessHoursId;
        String shippingCountry = c.Shipping_Country__c == null ? c.Office_Country__c : c.Shipping_Country__c;
        Date slaDate = getNHShippingSLADate(shippingCountry, c.NHW_Start_Date__c, c.RecordTypeId);
        calculatedTime = BusinessHours.diff(entitlementBusinessHoursId, c.CreatedDate, slaDate) / 1000 / 60;

        return calculatedTime.intValue() <= 0 ? DEFAULT_TIME : calculatedTime.intValue(); // This is because the milestone trigger must return an non-zero positive integer.
    }

    public static Date getNHShippingSLADate(String shippingCountry, Date nhwStartDate, String caseRecordTypeId) {
        Date slaDate = System.today();
        
        if (!mapSlaMdtByName.isEmpty() && mapSlaMdtByName.containsKey(shippingCountry)) {
            if(caseRecordTypeId == PROVISIONING_RECORDTYPE_ID) {
                slaDate =  nhwStartDate.addDays(-1 * Integer.valueOf(mapSlaMdtByName.get(shippingCountry).Provisioning_SLA__c));
            } else {
                slaDate =  nhwStartDate.addDays(-1 * Integer.valueOf(mapSlaMdtByName.get(shippingCountry).Preboarding_SLA__c));
            }
        }

        return slaDate;
    }

    public static Map<String, NH_Shipping_SLA__mdt> getMapSlaMdtByName() {
        Map<String, NH_Shipping_SLA__mdt> mapSlaMdtByName = new Map<String, NH_Shipping_SLA__mdt>();
        mapSlaMdtByName = NH_Shipping_SLA__mdt.getAll();
        Map<String, NH_Shipping_SLA__mdt> mapSlaMdtByCountry = new Map<String, NH_Shipping_SLA__mdt>();
        
        for (NH_Shipping_SLA__mdt mdt : mapSlaMdtByName.values()) {
          mapSlaMdtByCountry.put(mdt.Country__c, mdt);
        }

        return mapSlaMdtByCountry;
    }
}