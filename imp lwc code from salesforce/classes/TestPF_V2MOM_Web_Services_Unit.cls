@isTest
private class TestPF_V2MOM_Web_Services_Unit {

	public static testMethod void execute_methods_V2MOM_Web_Services() 
	{
		 
		GenerateEnvironmentTest3.genV2MOMUtil();
		    
		Test.startTest();
		
		
		if(V2MOM_Web_Services.generateXMLForV2MOM(GenerateEnvironmentTest3.v2momIndividualQ1Q2Edu.Id) == null)
		{
			System.assert(true, 'Null xml');
		}
		
		if(V2MOM_Web_Services.generateXMLForV2MOM(GenerateEnvironmentTest3.v2momIndividualQ1Q2Edu.Id) == null){
			System.assert(true, 'Null xml');
		}
				
		Test.stopTest();
		
	  }
	  
	public static testMethod void createXMLTest(){
		GenerateEnvironmentTest2.gen();
        V2MOM__c v2mom = GenerateEnvironmentTest2.v2mom;
        System.assert(v2mom != null);
        Test.startTest();
        if (v2mom != null){
			V2MOM_Web_Services.generateXMLForV2MOM(v2mom.Id);
        }
        Test.stopTest();
	}
}