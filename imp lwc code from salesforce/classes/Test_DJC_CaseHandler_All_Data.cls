@isTest(SeeAllData=true)
public class Test_DJC_CaseHandler_All_Data {
	private static Contact amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];
    
        private static testmethod void testEntitlementsApplied(){
		
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        System.runAs(cuser) { 
            Test.startTest();		
            //ES DJC Update AMER Record Type
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Concierge Desktop');
            Case newCase = createCase(nameValuePair);           
            Test.stopTest();
			system.assert(newCase.EntitlementId != null);	            
        }
    }

    private static testmethod void testEntitlementsNotApplied(){
		
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        System.runAs(cuser) { 
            Test.startTest();		
            //ES DJC Update AMER Record Type
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Email');
            Case newCase = createCase(nameValuePair);           
            Test.stopTest();
			system.assert(newCase.EntitlementId == null);	            
        }
    }
    
    private static testmethod void testEntitlementsNotAppliedForEthicsPoint(){
		
        User cuser = ESDJC_TestUtil.getConciergeUser('United States','Americas - USA');
        System.runAs(cuser) { 
            Test.startTest();		
            //ES DJC Update AMER Record Type
            Map<String,String> nameValuePair = new Map<String, String>();
            nameValuePair.put('ContactId', amerContact.id);
            nameValuePair.put('Type','GEPS');
            nameValuePair.put('Tier__c', 'Tier 1');
            nameValuePair.put('Origin','Ethics Point');
            Case newCase = createCase(nameValuePair);           
            Test.stopTest();
			system.assert(newCase.EntitlementId == null);	            
        }
    }

    
    private static case createCase(Map<String,String> nameValPair){
		Case c = new Case();
		if ((nameValPair!=null)&&(nameValPair.size()>0)){
			for (String key: nameValPair.keySet()){
				String value= nameValPair.get(key);
				c.put(key, value);
			}
			insert c;
			Case newCase = [select owner.name, status, recordtype.Name, priority,ES_DJC_Case_Re_open_Date__c,type, Tier__c, 
                            ES_DJC_Topic__c, ES_DJC_Sub_Topic__c, First_Response_Flag__c, EntitlementId from case where id = :c.id];
			return newCase;					
		}
		return null;		
	}

    

}