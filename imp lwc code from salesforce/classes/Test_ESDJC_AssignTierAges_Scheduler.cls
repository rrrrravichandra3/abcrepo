@isTest
public class Test_ESDJC_AssignTierAges_Scheduler {

	private static User currentUser = [select userroleId,userrole.name from User where Id = : userinfo.getUserId()]; 

	public static testMethod void assignTierAgesSchedulerTest(){

		Test.startTest();

		ESDJC_Settings__c settings = new ESDJC_Settings__c();
		settings.Tier_Age_Date_Filter__c = Date.newInstance(2015, 1, 1);
		settings.Site_URL__c = '/site/url';

		insert settings;

		RecordType amerRecordType = [select Id from RecordType where developerName = 'ES_DJC_All_Case_Types_except_ER_AMER'];

		
        List<Case> cases = new List<Case>();

        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 1'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 2'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 3'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 4'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 1'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 2'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 3'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 4'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 1'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 1'));
        cases.add(new Case(Origin = 'Web',Type = '# djc support',ES_DJC_Topic__c = 'Bug', ES_DJC_Sub_Topic__c = 'Chatter Answers', RecordTypeId = amerRecordType.ID, Subject = 'Case tier calculation test', Tier__c='Tier 1'));

        cases.get(8).ESDJC_Supportforce_Case_Number__c = '15';
        cases.get(9).Status = 'Sent to Supportforce';
        cases.get(10).Status = 'In Transit';

        insert cases;

		ESDJC_AssignTierAges_Scheduler scheduler = new ESDJC_AssignTierAges_Scheduler();
		scheduler.execute(null);
		Test.stopTest();
	}

}