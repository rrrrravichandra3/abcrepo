/******************************************************************************/
//Name			: Testv2momCCAfterUpdateTrigger
//Author		: 
//Date			: 06 Nov, 2009
//Description	: Code coverage for v2momCCAfterUpdateTrigger
/******************************************************************************/
public class TestPF_v2momCCAftrUpdtTrggr_Unit{
    @isTest
    private static void testv2momCCAfterUpdateTrigger(){
        V2MOM__c newV2mom = new V2MOM__c();
        newV2mom.OwnerId = UserInfo.getUserId();
        newV2mom.Effective_Date__c = 'FY16';
        newV2mom.Status__c = 'Submitted';
        newV2mom.Name = 'new v2mom name';
        newV2mom.Vision__c = 'new v2mom vision';
        insert newV2mom;
        
        V2MOM__c oldV2mom = [SELECT id, Status__c from V2MOM__c where id =: newV2mom.Id LIMIT 1];
        oldV2mom.Status__c = 'Approved';
        oldV2mom.Effective_Date__c = getCurrentFiscalYear();
        oldV2mom.Vision__c = 'test';
        update oldV2mom;
    }
    private static String getCurrentFiscalYear() {
  	Date d = Date.today();
  	if(d.month() >= 2)
  	  return 'FY' + String.valueOf(d.year()).substring(2);
  	else
  	  return 'FY' + String.valueOf(d.year() - 1).substring(2);
  }
}