/**
 * Created by kmoseley on 11/16/21.
 */

@IsTest
private class CEMCI_WD_Candidates_Test {
  /**
   * GIVEN: A Candidate Contact is created
   * WHEN: the Mailing Country provided is a COUNTRY CODE (US)
   * THEN: Mailing Country Global field should be properly populated
   */
  @IsTest
  static void testMailingCountryGlobal_CountryCode() {
    WDR_Candidate__c cand = createCandidate('US');
    Test.startTest();
    insert cand;
    Test.stopTest();
    cand = [SELECT id, Mailing_Country_Global__c FROM WDR_Candidate__c LIMIT 1];
    System.assertEquals('US', cand.Mailing_Country_Global__c, 'Mailing Country Global should be US');
  }

  /**
   * GIVEN: A Candidate Contact is created
   * WHEN: the Mailing Country provided is a COUNTRY VALUE (United States of America)
   * THEN: Mailing Country Global field should be properly populated
   */
  @IsTest
  static void testMailingCountryGlobal_CountryValue() {
    WDR_Candidate__c cand = createCandidate('United States of America');
    Test.startTest();
    insert cand;
    Test.stopTest();
    cand = [SELECT id, Mailing_Country_Global__c FROM WDR_Candidate__c LIMIT 1];
    System.assertEquals('US', cand.Mailing_Country_Global__c, 'Mailing Country Global should be US');
  }

  /**
   * GIVEN: A Candidate Contact is created
   * WHEN: the Mailing Country provided is a Bad Value, i.e. not a Country Code of Country Value in the Mailing County Global picklist
   * THEN: Mailing Country Global field should be null and a PF Debug Log should be created
   */
  @IsTest
  static void testMailingCountryGlobal_CountryCode_BadValue() {
    WDR_Candidate__c cand = createCandidate('Test Country');
    Test.startTest();
    insert cand;
    Test.stopTest();
    cand = [SELECT id, Mailing_Country_Global__c FROM WDR_Candidate__c LIMIT 1];
    List<PF_Debug_Log__c> log = [
      SELECT id
      FROM PF_Debug_Log__c
      WHERE Error_Type__c = 'Bad value for restricted pick-list'
      LIMIT 1
    ];
    System.assertEquals(
      null,
      cand.Mailing_Country_Global__c,
      'Mailing Country Global should be null because of bad value'
    );
    System.assertEquals(false, log.isEmpty(), 'PF Debug Log should have been generated');
  }

  static WDR_Candidate__c createCandidate(String mailingValue) {
    WDR_Candidate__c candidate = new WDR_Candidate__c();
    candidate.Name = 'Test Name ';
    candidate.First_Name__c = 'Test First Name';
    candidate.Last_Name__c = 'Test Last Name';
    candidate.Email__c = 'testcandidateCreate@abc.com';
    candidate.Mobile_Phone__c = '123455';
    candidate.Phone__c = '123455';
    candidate.Phone_Extension__c = '1234';
    candidate.Referral_Comments__c = 'Test comments';
    candidate.Current_Company__c = 'Test company';
    candidate.Candidate_Type__c = 'Prospect';
    candidate.Mailing_Country__c = mailingValue;

    return candidate;
  }
}