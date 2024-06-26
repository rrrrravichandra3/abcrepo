@isTest
public class Test_MA_CommunitySSOController {
    
    @isTest
    static void testGenerateSSOUrl() {
        
        
        // Test the generateSSOUrl method
        Test.startTest();
        String ssoUrl = MA_CommunitySSOController.generateSSOUrl(null, 'startUrl', 'communityUrl');
        // Add assertions based on your expected behavior
        System.assertNotEquals(null, ssoUrl, 'SSO URL should not be null');
        // Add more assertions as needed
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void testGetSSOUrlFromInvitation() {
        String CASE_CLOSURE_SURVEY_NAME = Label.MA_CaseClose_Survey_Name;
        Survey testSurvey = [SELECT Id FROM Survey WHERE Name = :CASE_CLOSURE_SURVEY_NAME LIMIT 1]; 
        Contact c = [SELECT Id FROM Contact LIMIT 1]; 
        
        // Create a survey invitation
        SurveyInvitation testSurveyInvitation = new SurveyInvitation(
            Name = 'testInvitation',
            ParticipantId = c.Id,
            SurveyId = testSurvey.Id,
            CommunityId = [SELECT NetworkId FROM NetworkMember limit 1][0].NetworkId
        );
        insert testSurveyInvitation;
        try{
            String ssoUrl;
            Test.startTest();
            ssoUrl = MA_CommunitySSOController.getSSOUrlFromInvitation(testSurveyInvitation.Id, 'startUrl', 'communityUrl');
            Test.stopTest();
            
            // Add assertions based on your expected behavior
            System.assertNotEquals(null, ssoUrl, 'SSO URL should not be null');
            
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
    }
}