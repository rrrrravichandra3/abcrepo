public with sharing class NHW_BUCCCategoryMatcher implements NHW_CategoryMatcher{

    public List<NH_Profile__c> matchProfiles(Case provisioningCase, List<NH_Profile__c> profiles){
        
        Map<Id,NH_Profile__c> profilesMap = new Map<Id,NH_Profile__c>(profiles);
        List<NH_Profile__c> profilesMatched = new List<NH_Profile__c>();
        
        List<AggregateResult> profilesCount = [SELECT NH_Profile__c, COUNT(Id)proCount FROM NH_BU_CC_Profile__c WHERE ((Business_Unit__c != null AND Cost_Center__c != null
                                                AND Business_Unit__c = :provisioningCase.NHW_Business_Unit__c AND Cost_Center__c = :provisioningCase.NHW_Cost_Center__c)
                                                OR (Business_Unit__c != null AND Cost_Center__c = null AND Business_Unit__c = :provisioningCase.NHW_Business_Unit__c)
                                                OR (Business_Unit__c = null AND Cost_Center__c != null AND Cost_Center__c = :provisioningCase.NHW_Cost_Center__c))
                                                AND NH_Profile__c IN :profilesMap.keySet() GROUP BY NH_Profile__c];
        
        for(AggregateResult result:profilesCount){
            profilesMatched.add(profilesMap.get((Id)result.get('NH_Profile__c')));
        }
        
        return profilesMatched;
    }
}