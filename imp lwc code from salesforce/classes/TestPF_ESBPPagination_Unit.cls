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
private class TestPF_ESBPPagination_Unit {

    static testMethod void testMethodOne()
    {
           
           
           
             PageReference esbp = Page.EmployeeServiceAdmin;
            Test.setCurrentPageReference(esbp);
            esbp.getParameters().put('lastStatus', ''); 
            System.assertEquals(esbp.getParameters().get('lastStatus'), '');
            Test.startTest();
              
            ESBPPaginationController.getNumberOfPages(1,true,true,'0','','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','','All','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','','All','All');
            
            ESBPPaginationController.getNumberOfPages(1,true,true,'','0','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','0','All','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','0','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','0','All','All');
            
            ESBPPaginationController.getNumberOfPages(1,true,true,'0','0','','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','0','','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','0','','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','0','','All');
            
            ESBPPaginationController.getNumberOfPages(1,true,true,'0','0','All','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','0','All','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','0','All','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','0','All','');
            

            Test.stopTest();
    }
    
    
    
    static testMethod void testMethodTwo()
    {
    
         PageReference esbp = Page.EmployeeServiceAdmin;
            Test.setCurrentPageReference(esbp);
            esbp.getParameters().put('lastStatus', ''); 
            System.assertEquals(esbp.getParameters().get('lastStatus'), '');
            Test.startTest();
            
            //PCOMM - PRP
            ESBPPaginationController.getNumberOfPages(1,true,true,'','','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','','All','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','','All','All');
            
            
            //PCOMM - EF
            ESBPPaginationController.getNumberOfPages(1,true,true,'','0','','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','0','','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','0','','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','0','','All');
            
            //PCOMM - Status

            ESBPPaginationController.getNumberOfPages(1,true,true,'','0','All','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','0','All','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','0','All','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','0','All','');
            
            //PRP - ED

            ESBPPaginationController.getNumberOfPages(1,true,true,'0','','','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','','','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','','','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','','','All');
            
            //PRP - Status

            ESBPPaginationController.getNumberOfPages(1,true,true,'0','','All','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','','All','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','','All','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','','All','');
            
            //Status - ED

            ESBPPaginationController.getNumberOfPages(1,true,true,'0','0','','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','0','','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','0','','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','0','','');
            
            Test.stopTest();
            
    }
    
    static testMethod void testMethodThree()
    {
        
         PageReference esbp = Page.EmployeeServiceAdmin;
            Test.setCurrentPageReference(esbp);
            esbp.getParameters().put('lastStatus', ''); 
            System.assertEquals(esbp.getParameters().get('lastStatus'), '');
            Test.startTest();
            
            
                //PCOMM - PRP - ED
            ESBPPaginationController.getNumberOfPages(1,true,true,'','','','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','','','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','','','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','','','All');
            
            //PCOMM - PRP - STATUS
            ESBPPaginationController.getNumberOfPages(1,true,true,'','','All','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','','All','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','','All','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','','All','');
            
            //PRP - STATUS - ED
            ESBPPaginationController.getNumberOfPages(1,true,true,'0','','','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','','','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','','','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','','','');
            
                        Test.stopTest();
          
    }
    
    static testMethod void testThreeContinue()
    {
            PageReference esbp = Page.EmployeeServiceAdmin;
            Test.setCurrentPageReference(esbp);
            esbp.getParameters().put('lastStatus', ''); 
            System.assertEquals(esbp.getParameters().get('lastStatus'), '');
            Test.startTest();
            
            //ED - STATUS - PCOMM
            ESBPPaginationController.getNumberOfPages(1,true,true,'','0','','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','0','','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','0','','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','0','','');
         
            Test.stopTest();
    }
    
    static testMethod void testThreeContinueTwo()
    {
            PageReference esbp = Page.EmployeeServiceAdmin;
            Test.setCurrentPageReference(esbp);
            esbp.getParameters().put('lastStatus', ''); 
            
            Test.startTest();
            
         
            
          
            Test.stopTest();
    }
    
    static testMethod void testMethodFour()
    {
         PageReference esbp = Page.EmployeeServiceAdmin;
            Test.setCurrentPageReference(esbp);
            esbp.getParameters().put('lastName', '');
            
            Test.startTest();
            
            //PCOMM - PRP
            ESBPPaginationController.getNumberOfPages(1,true,true,'','','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','','All','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','','All','All');
            
            
            //PCOMM - EF
            ESBPPaginationController.getNumberOfPages(1,true,true,'','0','','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','0','','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','0','','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','0','','All');
            
            //PCOMM - Status

            ESBPPaginationController.getNumberOfPages(1,true,true,'','0','All','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','0','All','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','0','All','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','0','All','');
            
            //PRP - ED

            ESBPPaginationController.getNumberOfPages(1,true,true,'0','','','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','','','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','','','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','','','All');
            
            //PRP - Status

            ESBPPaginationController.getNumberOfPages(1,true,true,'0','','All','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','','All','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','','All','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','','All','');
            
                        Test.stopTest();
    }
    
    
    static testMethod void testMethodFiveContinue()
    {
            PageReference esbp = Page.EmployeeServiceAdmin;
            Test.setCurrentPageReference(esbp);
            esbp.getParameters().put('lastName', '');
          	System.assertEquals(esbp.getParameters().get('lastName'), ''); 
              Test.startTest();
              
           ESBPPaginationController.getNumberOfPages(1,true,true,'0','','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','','All','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','','All','All');
            
            ESBPPaginationController.getNumberOfPages(1,true,true,'','0','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','0','All','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','0','All','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','0','All','All');
            
            ESBPPaginationController.getNumberOfPages(1,true,true,'0','0','','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','0','','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','0','','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','0','','All');
            
            ESBPPaginationController.getNumberOfPages(1,true,true,'0','0','All','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','0','All','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','0','All','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','0','All','');  
            
            Test.stopTest();
    }
    static testMethod void testMethodSix()
    {
           PageReference esbp = Page.EmployeeServiceAdmin;
            Test.setCurrentPageReference(esbp);
            esbp.getParameters().put('lastName', '');
            System.assertEquals(esbp.getParameters().get('lastName'), '');
            Test.startTest();
            //Status - ED

            ESBPPaginationController.getNumberOfPages(1,true,true,'0','0','','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','0','','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','0','','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','0','','');
            
            //PCOMM - PRP - ED
            ESBPPaginationController.getNumberOfPages(1,true,true,'','','','All');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','','','All');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','','','All');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','','','All');
            
            //PCOMM - PRP - STATUS
            ESBPPaginationController.getNumberOfPages(1,true,true,'','','All','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'','','All','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'','','All','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'','','All','');
            
            //PRP - STATUS - ED
            ESBPPaginationController.getNumberOfPages(1,true,true,'0','','','');
            ESBPPaginationController.getNumberOfPages(1,false,true,'0','','','');
            ESBPPaginationController.getNumberOfPages(1,true,false,'0','','','');
            ESBPPaginationController.getNumberOfPages(1,false,false,'0','','','');
            
                 Test.stopTest();     
    }
        
}