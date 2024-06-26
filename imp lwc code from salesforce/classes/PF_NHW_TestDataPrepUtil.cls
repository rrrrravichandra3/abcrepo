public without sharing class PF_NHW_TestDataPrepUtil {
	public static WDR_Candidate__c createWDRCandidateObject() {
		WDR_Candidate__c candidate = new WDR_Candidate__c();
		candidate.First_Name__c = 'Test';
		candidate.Last_Name__c = 'Candidate';
		candidate.Email__c = 'test123@example.com';
		candidate.Name = 'Test Candidate';
		candidate.Mailing_Street__c = '';
		candidate.Mailing_City__c = '';
		candidate.Mailing_State__c = '';
		candidate.Mailing_Country__c = '';
		candidate.Mailing_Postal_Code__c = '';

		return candidate;
	}

	public static WDR_Job__c createWDRJobObject() {
		WDR_Job__c job = new WDR_Job__c();
		job.Name = 'Test job';
		job.Job_Title__c = 'Test job title';
		job.Job_Code__c = '';
		job.Employment_Type__c = '';
		TF2_Company__c compObj = new TF2_Company__c(Name = 'Test Comp', Company_Code__c = 'TC43');
		insert compObj;
		job.Company__c = compObj.Id;
		Business_Unit__c buObj = new Business_Unit__c(Name = 'Test BU', BU_Code__c = 'TBU43');
		insert buObj;
		job.Business_Unit__c = buObj.Id;
		TF2_Department__c dObj = new TF2_Department__c(Name = 'Test Dept');
		insert dObj;
		job.Department__c = dObj.Id;
		TF2_PCC__c pccObj = new TF2_PCC__c(Name = 'Test PCC');
		insert pccObj;
		job.PCC__c = pccObj.Id;
		job.Region__c = 'Test Region';
		User u = new User();
		u.LastName = 'Test Lastname';
		u.Alias = 'TLast';
		u.Email = 'tlast@example.com';
		u.Username = 'tlast@example.com';
		u.CommunityNickname = 'tlast.675435';
		u.ProfileId = [Select Id from Profile where Name = 'System Administrator'].Id;
		u.TimeZoneSidKey = 'America/Los_Angeles';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.LanguageLocaleKey = 'en_US';
		System.runAs(new User(id=UserInfo.getUserId())) {
			insert u;
			}
		job.Hiring_Manager__c = u.Id;

		return job;
	}

	public static WDR_Application__c createWDRAppObject() {
		WDR_Application__c application = new WDR_Application__c();
		TF2_Business_Site__c bsObj = new TF2_Business_Site__c();
		bsObj.Type__c = 'Test type';
		bsObj.Street_Address__c = 'Test St';
		bsObj.Country__c = 'Test Country';
		insert bsObj;
		application.Business_Site__c = bsObj.Id;
		application.Start_Date__c = System.today();

		return application;
	}
}