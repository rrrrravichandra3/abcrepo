@istest
public class PB_CommLoginRedirectServiceTest {

    @istest
    static void validateSSOURL() {
        Preboarding_Community_Config__c settings = new Preboarding_Community_Config__c(SSO_URL__c = 'https://test.com');
        insert settings;
        Test.startTest();
        String url = PB_CommLoginRedirectService.getRedirectURL();
        System.assertEquals(settings.SSO_URL__c,url,'Incorrect URL Returned');
        Test.stopTest();
    }
    
}