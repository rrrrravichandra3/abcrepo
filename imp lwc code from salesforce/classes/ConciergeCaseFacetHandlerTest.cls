@isTest
public class ConciergeCaseFacetHandlerTest {
    
    @testSetup static void setup() {
        List<string> ExceptERRT = new List<string>{
            'All Case Types except ER - AMER',
                'All Case Types except ER - APAC',
                'All Case Types except ER - APAC',
                'All Case Types except ER - Japan'         
                };
                    
        List<String> ErgoRT = new list<string>{ 'All Ergo cases - Global'};
        List<String> REWSRT = new list<string>{ 'All REWS cases - AMER - NonHQ',
                            'All REWS cases - AMER HQ',
                            'All REWS cases - APAC',
                            'All REWS cases - EMEA',
                            'All REWS Package Management'	
                            };
        List<String> OrgRT = new list<string>{'All .org Cases - Global'};
        List<String> ERRT = new list<string>{
                                        'Employee Relations Case Type - AMER', 
                                            'Employee Relations Case Type - APAC', 
                                            'Employee Relations Case Type - EMEA', 
                                            'Employee Relations Case Type - Japan'         
                                            };
                                                
        List<String> ExpRT = new list<string>{'All Expense Cases' };  
                                                    
        List<Case> REWSCases = new List<Case>();
        List<Case> ExceptERCases = new List<Case>();
        List<Case> ERCases = new List<Case>();
        List<Case> OrgCases = new List<Case>();
        List<Case> ErgoCases = new List<Case>();
        List<Case> ExpCases = new List<Case>();
        List<Case> Allcases = new List<Case>();
        
        for(String RTName:ExceptERRT){
            Case ExceptERCase = new case();
            ExceptERCase.Origin = 'Chatter';
            ExceptERCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
            ExceptERCases.add(ExceptERCase);
        }
        for(String RTName:REWSRT){
            Case REWSCase = new case();
            REWSCase.Origin = 'Chatter';
            REWSCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
            REWSCases.add(REWSCase);
        }
        for(String RTName:ERRT){
            Case ERCase = new case();
            ERCase.Origin = 'Chatter';
            ERCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
            ERCases.add(ERCase);
        }
        for(String RTName:ErgoRT){
            Case ErgoCase = new case();
            ErgoCase.Origin = 'Chatter';
            ErgoCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
            ErgoCases.add(ErgoCase);
        }
        for(String RTName:ExpRT){
            Case ExpCase = new case();
            ExpCase.Origin = 'Chatter';
            ExpCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
            ExpCases.add(ExpCase);
        }
        for(String RTName:OrgRT){
            Case orgCase = new case();
            orgCase.Origin = 'Chatter';
            orgCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
            orgCases.add(orgCase);
        }
        
        Allcases.addAll(orgCases) ;
        Allcases.addAll(ExpCases) ;
        Allcases.addAll(ErgoCases) ;
        Allcases.addAll(ERCases) ;
        Allcases.addAll(REWSCases) ;
        Allcases.addAll(ExceptERCases) ;
        
        insert Allcases;
    }
    
    public static testMethod void testConciergeActionClone() {
        List<Case> AllCases = [select id,recordtype.developername,origin ,(select Can_Clone__c from Concierge_Case_Facets__r)
                               from case ];
        
        List<case> webformsUpdate = new List<case>();        
        for(case c:AllCases){
            System.assertEquals(c.Concierge_Case_Facets__r.size(), 1 ,'Expecting Concierge Facet rec to be created');
            
            //Except Expense cases all others have Clone
            if(c.recordtype.developername.contains('Expense') ){
                System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Clone__c, false,c);                
            }else{
                System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Clone__c, true,c);              
            }
            if(c.recordtype.developername.contains('REWS') 
               ||c.recordtype.developername.contains('Except_ER') 
               ||c.recordtype.developername.contains('Ergo')              
              ){
                  c.origin = 'web';
                  webformsUpdate.add(c);
              }
        }
        update webformsUpdate;
        webformsUpdate = [select id,recordtype.developername,origin ,(select Can_Clone__c from Concierge_Case_Facets__r)
                          from case where id in  :webformsUpdate];        
        //RTs with origin from webform shouldnt have clone.
        for(case c:webformsUpdate){
            System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Clone__c, false,c);           
        }
        
    }    
    public static testmethod void testConciergeActionReopen(){
        List<Case> AllCases = [select id,recordtype.developername,origin ,(select Can_Reopen__c from Concierge_Case_Facets__r)
                               from case where recordtype.developername != 'All_Expense_Cases'];
        
        for(case c:AllCases){
            System.assertEquals(c.Concierge_Case_Facets__r.size(), 1 ,'Expecting Concierge Facet rec to be created');
            
            //Open cases cannot be re-opened.
                System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Reopen__c, false,c);                
 
            
            c.status = 'Closed'; 
        }
        update AllCases;
        AllCases = [select id,recordtype.developername,origin ,ClosedDate ,status,(select Can_Reopen__c from Concierge_Case_Facets__r)
                          from case where id in  :AllCases];        
        //closed cases within 7 day window from today can be reopened.
        for(case c:AllCases){
            System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Reopen__c, true,c);           
        }      
    }
    public static testmethod void testConciergeActionClose(){
       List<Case> AllCases = [select id,recordtype.developername,origin ,(select Can_Close__c from Concierge_Case_Facets__r)
                              from case ];   
        //Except Expense cases all others can be closed
        for(case c:AllCases){
            System.assertEquals(c.Concierge_Case_Facets__r.size(), 1 ,'Expecting Concierge Facet rec to be created');
            if(c.recordtype.developername.contains('Expense') ){
                System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Close__c, false,c);                
            }else{
                System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Close__c, true,c);              
            }
        }
    }
    public static testmethod void testConciergeActionComment(){
       List<Case> AllCases = [select id,recordtype.developername,origin ,(select Can_Comment__c from Concierge_Case_Facets__r)
                              from case ];   
        //Except Expense cases all others can be commented
        for(case c:AllCases){
            System.assertEquals(c.Concierge_Case_Facets__r.size(), 1 ,'Expecting Concierge Facet rec to be created');
            if(c.recordtype.developername.contains('Expense') ){
                System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Comment__c, false,c);                
            }else{
                System.assertEquals(c.Concierge_Case_Facets__r[0].Can_Comment__c, true,c);              
            }
        }        
    }
    public static testmethod void testConciergeActionVisible(){
        List<Case> AllCases = [select id,recordtype.developername,origin ,(select Is_Visible__c from Concierge_Case_Facets__r)
                              from case ];   
        //Except cases except NHW,Legal will be visible in concierge
        for(case c:AllCases){
            System.assertEquals(c.Concierge_Case_Facets__r.size(), 1 ,'Expecting Concierge Facet rec to be created');
			System.assertEquals(c.Concierge_Case_Facets__r[0].Is_Visible__c, true,c);              
        }
               
    }
}