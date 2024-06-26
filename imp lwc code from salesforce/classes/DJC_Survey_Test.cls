@isTest(seeAllData=false)
public class DJC_Survey_Test {
    private static Contact amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];   
    
    public static testmethod  void testSurveyAutomatic(){
        init();             
        
        Test.startTest();
        
        List<Case> cases = createCase(4, 'Closed');
        List<Case> caseTest = createCase(1, null);
        closeAllCases(caseTest);
        
        Test.stopTest();
        
        List<Case> additionalCase = createCase(1, null);
        closeAllCases(additionalCase);
        
		assertSurveySent(caseTest.get(0), true, false);
		assertSurveySent(additionalCase.get(0), false, false);                         
    }
    
      public static testmethod  void testSurveyAutomaticForErgo(){
        init();             
        Test.startTest();               
        List<Case> c0 = createErgoCases(1);
        List<Case>ClosedC0 = closeAllCases(c0);
        List<case> cases = createErgoCases(5);
        List<Case> closedCases = closeAllCases(cases);      
        Test.stoptest();        
        //survey go
        assertSurveySent(ClosedC0.get(0), true, false);
        //survey no go
        assertSurveySent(closedCases.get(0), false, false);
        //survey no go
        assertSurveySent(closedCases.get(1), false, false);
        //survey no go
        assertSurveySent(closedCases.get(2), false, false);
        //survey no go
        assertSurveySent(closedCases.get(3), false, false);
        //survey no go
        assertSurveySent(closedCases.get(4), true, false);
    }
  
        
    //manual survey delivery
    public static testmethod void testSurveyManual(){
        init();             
        Test.startTest();               
        List<Case> c = createCase(1, null);   
        List<Case> closed = closeAllCases(c);                                       
        //no automated survey
        assertSurveySent(closed.get(0), false, false);
        DJC_Survey_Service.sendSurvey(closed.get(0).id);                    
        Test.stoptest();    
        assertSurveySent(closed.get(0), true, true);
    }
    
    
    private static  void assertSurveySent(Case c, boolean surveySent, boolean surveyManuallySent){
    case newCase = [select DJC_Is_Survey_Email_Sent__c, DJC_Survey_Email_Sent_On__c, DJC_Was_Survey_Sent_Manually__c from case where id = :c.id];
        system.assertEquals(surveySent, newCase.DJC_Is_Survey_Email_Sent__c);
        if (surveySent){
            System.AssertNotEquals(null,newCase.DJC_Survey_Email_Sent_On__c);
        }
        system.assertEquals(surveyManuallySent,newCase.DJC_Was_Survey_Sent_Manually__c);            
    }   
    
    private static List<case> createCase(integer num, String status){
        List<case> cases = new List<case>();
        for (integer i=0; i<num; i++){                      
            Case c = new Case();
            c.put('ContactId', amerContact.id);
            c.put('Type','ESPP');
            c.put('ES_DJC_Topic__c','How to Enroll');   
            c.put('ES_DJC_Sub_Topic__c','New Hire');            
            c.put('Tier__c', 'Tier 1');
            c.put('Origin','Phone');    
            c.put('Subject',String.valueOf(i));
            
            if(status != null){
                c.put('Status', status);
            }
            
            cases.add(c);           
        }           
        insert cases;
        return cases;                                   
    }
    
    private static List<case> createErgoCases(integer num){
        List<case> cases = new List<case>();
        id recType = [select id from recordType where developername = 'DJC_Ergo_All_Ergo_cases_AMER' and sobjectType = 'Case'].id;
        for (integer i=0; i<num; i++){                      
            Case c = new Case();
            c.put('ContactId', amerContact.id);
            c.put('Type','Ergonomics Assessment Request');
            c.put('ES_DJC_Topic__c','1x1 Assessment	');   
            c.put('ES_DJC_Sub_Topic__c','New Hire');            
            c.put('Tier__c', 'Tier 1');
            c.put('Origin','Ergo - Web');    
            c.put('Subject',String.valueOf(i));    
            c.put('RecordTypeid', recType);
            cases.add(c);           
        }           
        insert cases;
        return cases;                                   
    }



    private static List<case> closeAllCases(List<case> cases){
        for (case c: cases){
            c.status = 'Closed';
        }
        update cases;
        return cases;
    }
    
    private static void init(){
        ESDJC_Settings__c setting = new ESDJC_Settings__c();
        setting.Run_trigger__c = true;
        setting.Site_URL__c = '/site/url';
        setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
        setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
        setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
        setting.Valid_SLA_Origins__c='Web,REWS - Web,Chatter Answers,Personal Email,Concierge';
        setting.Ergo_Locations__c = 'san francisco,new york,chicago,portland,spokane,toronto';
        insert setting;
        REWS_Setting__c rewsSetting = new REWS_Setting__c();
        rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
        rewsSetting.Case_Package_Delivery_Record_Type__c = '00Gn0000000JH8YEAW';
        insert  rewsSetting;

    }
}