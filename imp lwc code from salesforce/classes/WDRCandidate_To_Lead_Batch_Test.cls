@isTest
public class WDRCandidate_To_Lead_Batch_Test {
  @testSetup
  static void setup() {
    List<WDR_Candidate__c> WDCandidates = new List<WDR_Candidate__c>();
    for (Integer i = 1; i <= 100; i++) {
      WDR_Candidate__c candidate = new WDR_Candidate__c();
      candidate.Name = 'Test Name ' + i;
      candidate.First_Name__c = 'Test First Name';
      candidate.Last_Name__c = 'Test Last Name';
      candidate.Email__c = 'test@abc.com';
      candidate.Mobile_Phone__c = '123455';
      candidate.Phone__c = '123455';
      candidate.Phone_Extension__c = '1234';
      candidate.Referral_Comments__c = 'Test comments';
      candidate.Current_Company__c = 'Test company';
      candidate.Is_Lead_Created_for_this_WD_Candidate__c = false;
      candidate.Candidate_Type__c = 'Prospect';
      candidate.Confidential__c = true;

      WDCandidates.add(candidate);
    }
    insert WDCandidates;

    CEMCI_Test_Util.createCEMCICustomSetting();
  }

  @isTest
  static void testConfidentialWDCandToLeadBatch() {
    Test.startTest();
    WDRCandidate_To_Lead_Batch cWDLBatch = new WDRCandidate_To_Lead_Batch();
    Id batchId = Database.executeBatch(cWDLBatch);
    Test.stopTest();

    System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Confidential__c = TRUE]);
  }
}