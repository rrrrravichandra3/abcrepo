public interface NHW_CategoryMatcher {

    List<NH_Profile__c> matchProfiles(Case provisioningCase, List<NH_Profile__c> profiles);
    
}