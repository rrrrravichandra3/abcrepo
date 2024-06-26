/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_PCOMMPaginationController {

    static testMethod void testMethodOne() 
    {
    	
  		Test.startTest();
    	
    	//None
    	PCOMMPaginationController.getNumberOfPages('All','All','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('All','All','0',System.Userinfo.getUserId(), false,10);
 		
 		
    	
    	//ED - STATUS - PRP
 		PCOMMPaginationController.getNumberOfPages('','','',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','','',System.Userinfo.getUserId(), false,10);
 		
 		//ED - STATUS 
 		PCOMMPaginationController.getNumberOfPages('','','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','','0',System.Userinfo.getUserId(), false,10);
 		
 		//ED - PRP 
 		PCOMMPaginationController.getNumberOfPages('','All','',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','All','',System.Userinfo.getUserId(), false,10);
 		
 		//STATUS - PRP
 		PCOMMPaginationController.getNumberOfPages('All','','',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('All','','',System.Userinfo.getUserId(), false,10);
 		
 		//ED
 		PCOMMPaginationController.getNumberOfPages('','All','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','All','0',System.Userinfo.getUserId(), false,10);
	
		//STATUS
 		PCOMMPaginationController.getNumberOfPages('All','','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('All','','0',System.Userinfo.getUserId(), false,10);
 		
 		
		//PRP
 		PCOMMPaginationController.getNumberOfPages('All','All','',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('All','All','',System.Userinfo.getUserId(), false,10);
     	     	
     	System.currentPageReference().getParameters().put('lastName', '');
     	
     	//None
    	PCOMMPaginationController.getNumberOfPages('All','All','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('All','All','0',System.Userinfo.getUserId(), false,10);
 		
    	//ED - STATUS - PRP
 		PCOMMPaginationController.getNumberOfPages('','','',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','','',System.Userinfo.getUserId(), false,10);
 		
 		//ED - STATUS 
 		PCOMMPaginationController.getNumberOfPages('','','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','','0',System.Userinfo.getUserId(), false,10);
 		
 		//ED - PRP 
 		PCOMMPaginationController.getNumberOfPages('','All','',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','All','',System.Userinfo.getUserId(), false,10);
 		
 		//STATUS - PRP
 		PCOMMPaginationController.getNumberOfPages('All','','',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('All','','',System.Userinfo.getUserId(), false,10);
 		
 		//ED
 		PCOMMPaginationController.getNumberOfPages('','All','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','All','0',System.Userinfo.getUserId(), false,10);
	
		//STATUS
 		PCOMMPaginationController.getNumberOfPages('All','','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('All','','0',System.Userinfo.getUserId(), false,10);
 		
 		
		//PRP
 		PCOMMPaginationController.getNumberOfPages('All','All','',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('All','All','',System.Userinfo.getUserId(), false,10);
     	 
     	 //PRP
 		PCOMMPaginationController.getNumberOfPages('','','0',System.Userinfo.getUserId(), true,10);
 		PCOMMPaginationController.getNumberOfPages('','','0',System.Userinfo.getUserId(), false,10);
     	 
     	Test.stopTest();
  	
    }
}