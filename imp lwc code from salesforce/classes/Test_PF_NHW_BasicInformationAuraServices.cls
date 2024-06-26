@isTest
public class Test_PF_NHW_BasicInformationAuraServices {

    private static final String TEST_EMAIL = 'Test@test.com';
    private static final String REGULAR_EMPLOYEE = 'Regular Employee';
    private static final String CASE_SUBJECT = 'Case Subject';
    private static final String CASE_DESC = 'Case Description';
    private static final String ALERT_MSG = 'Alert ES of Change';
    private static final String CHANGE_DATA = 'Change Data';

    @istest
    static void validateExactTarget(){
        WDR_Candidate__c wdrCandidate = new WDR_Candidate__c(Name='Test', First_Name__c ='Test11',Last_Name__c ='Test11',Email__c ='Test@test4w4.com');
        insert wdrCandidate;
        Contact cnt = new Contact(RecordTypeid = NHW_Util.getEmployeeContactRecordTypeId(),EMail = TEST_EMAIL, FirstName='Test', LastName='Test');
        insert cnt;
        Contact cnt2 = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),EMail = TEST_EMAIL, FirstName='Test', LastName='Test',NHW_Candidate__c=WdrCandidate.Id);
        insert cnt2;
        List<Case> cases = new List<Case>{new Case(ContactId=cnt.Id,NHW_Employee__c = cnt.Id, NHW_Employee_Type__c = REGULAR_EMPLOYEE,Subject=CASE_SUBJECT, Description=CASE_DESC, PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c=ALERT_MSG, ES_DJC_Sub_Topic__c=CHANGE_DATA, RecordTypeId='012700000005qHn'),
            							  new Case(ContactId=cnt.Id, Subject=CASE_SUBJECT, NHW_Employee__c = cnt.Id, NHW_Employee_Type__c = 'Remote',Description=CASE_DESC, PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c=ALERT_MSG, ES_DJC_Sub_Topic__c=CHANGE_DATA, RecordTypeId='012700000005qHn'), 
            							  new Case(ContactId=cnt.Id, Subject=CASE_SUBJECT, NHW_Employee__c = cnt2.Id, NHW_Employee_Type__c = REGULAR_EMPLOYEE,Description=CASE_DESC, PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c=ALERT_MSG, ES_DJC_Sub_Topic__c=CHANGE_DATA, RecordTypeId='012700000005qHn')};
        insert cases;
        List<Business_Unit__c > bussinessUnit = new List<Business_Unit__c >{new Business_Unit__c(Name='Test',BU_Code__c='1099'),
            							  									new Business_Unit__c(Name='Test1',BU_Code__c='1098')};
        insert bussinessUnit;
        NHW_Exact_Target_BU__c cs = new NHW_Exact_Target_BU__c();
        cs.Name='test';
        cs.Business_Unit__c='Test';
        insert cs; 
        System.assertEquals(true,PF_NHW_BasicInformationAuraServices.calculateIsExactTarget(BussinessUnit[0].Id),'calculate is exact target');
    }
    @isTest
    static void validateCloneCase(){
		WDR_Candidate__c wdrCandidate = new WDR_Candidate__c(Name='Test', First_Name__c ='Test11',Last_Name__c ='Test11',Email__c ='Test@test4w4.com');
        insert wdrCandidate;
        Contact cnt = new Contact(RecordTypeid = NHW_Util.getEmployeeContactRecordTypeId(),EMail = TEST_EMAIL, FirstName='Test', LastName='Test');
        insert cnt;
        Contact cnt2 = new Contact(RecordTypeid = NHW_Util.getCandidateContactRecordTypeId(),EMail = TEST_EMAIL, FirstName='Test', LastName='Test',NHW_Candidate__c=WdrCandidate.Id);
        insert cnt2;
        List<Case> cases = new List<Case>{new Case(ContactId=cnt.Id,NHW_Employee__c = cnt.Id, NHW_Employee_Type__c = REGULAR_EMPLOYEE,Subject=CASE_SUBJECT, Description=CASE_DESC, PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c=ALERT_MSG, ES_DJC_Sub_Topic__c=CHANGE_DATA, RecordTypeId='012700000005qHn'),
            							  new Case(ContactId=cnt.Id, Subject=CASE_SUBJECT, NHW_Employee__c = cnt.Id, NHW_Employee_Type__c = 'Remote',Description=CASE_DESC, PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c=ALERT_MSG, ES_DJC_Sub_Topic__c=CHANGE_DATA, RecordTypeId='012700000005qHn'), 
            							  new Case(ContactId=cnt.Id, Subject=CASE_SUBJECT, NHW_Employee__c = cnt2.Id, NHW_Employee_Type__c = REGULAR_EMPLOYEE,Description=CASE_DESC, PII__c='No', Origin='Chatter', Type='Talentforce', ES_DJC_Topic__c=ALERT_MSG, ES_DJC_Sub_Topic__c=CHANGE_DATA, RecordTypeId='012700000005qHn')};
        insert cases;
        List<Business_Unit__c > bussinessUnit = new List<Business_Unit__c >{new Business_Unit__c(Name='Tets',BU_Code__c='1099'),
            							  									new Business_Unit__c(Name='Test',BU_Code__c='1098')};
        insert bussinessUnit;
        NHW_Exact_Target_BU__c cs = new NHW_Exact_Target_BU__c();
        cs.Business_Unit__c='test';
        cs.Name='Tets';
        insert cs;
        Map<String,Object> m = PF_NHW_BasicInformationAuraServices.updateDetailsFromCloneHire(cases[0].Id,cases[1].Id,'Test');
        System.assert(m!=null,'get clone case details');
    }
}