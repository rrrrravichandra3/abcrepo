@isTest
private class Test_V2MOM_Prioritization_Controller {
	
	public static testMethod void testv2momPrioritization(){
		try{
			GenerateEnvironmentTest.genV2MOMPrioritize(); 
		
			Test.startTest();
			
			System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.Id);
			V2MOM_Prioritization_Controller v2momPriori = new V2MOM_Prioritization_Controller();
			List<V2MOM_Value_Wrapper>myList = v2momPriori.getValues();
			System.assert(myList != null);
			
			Test.stopTest();
		}catch(Exception e) {
			System.debug(e);
		}
	}
}