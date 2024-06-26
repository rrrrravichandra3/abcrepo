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
private class Test_TFFBPCustomCTL_Unit {

    static testMethod void myUnitTest() {
    	List<User> adminUserList = TestTF_Utils_Unit.getAdminUsers('System Administrator');
        FBPCustomCTL controller = new FBPCustomCTL();
        List<SelectOption> divisionList =controller.getDivisions();
        List<SelectOption> departmentList =controller.getDepartments();
        List<SelectOption> regionList =controller.getRegions();
        controller.showFilter();
        System.assert(divisionList != null);
        System.assert(departmentList != null);
        System.assert(regionList != null);
        String division = divisionList.get(0).getValue();
        List<String> regionStrList =new List<String>();
        regionStrList.add(regionList.get(0).getValue());
        List<String> departmentStrList =new List<String>();
        departmentStrList.add(departmentList.get(0).getValue());
        controller.division = division;
        controller.selectedRegions = regionStrList;
        controller.selectedDepartments = departmentStrList;
        controller.applyFilter();
        controller.showModifyScreen();
        Regional_FBP_Lookup__c fbLookup = new Regional_FBP_Lookup__c();
        fbLookup.Approver_Name__c =adminUserList.get(0).Name;
        fbLookup.FBP_Offer_Approver__c =adminUserList.get(1).Name;
        fbLookup.Regional_ESBP__c =adminUserList.get(2).Name;
        controller.fbpLookup = fbLookup;
        controller.fbpInfoCompleteList.get(0).setSelectedFBP(true);
        controller.applyValue();
        System.assert(ApexPages.hasMessages());
        controller.division = null;
        controller.selectedRegions = regionStrList;
        controller.selectedDepartments = departmentStrList;
        controller.applyFilter();
        controller.showModifyScreen();
        controller.division = null;
        controller.selectedRegions = null;
        controller.selectedDepartments = departmentStrList;
        controller.applyFilter();
        controller.showModifyScreen();
        
    }
    
    static testMethod void myUnitTest1() {
    	List<User> adminUserList = TestTF_Utils_Unit.getAdminUsers('System Administrator');
        FBPCustomCTL controller = new FBPCustomCTL();
        List<SelectOption> divisionList =controller.getDivisions();
        List<SelectOption> departmentList =controller.getDepartments();
        List<SelectOption> regionList =controller.getRegions();
        controller.showFilter();
        System.assert(divisionList != null);
        System.assert(departmentList != null);
        System.assert(regionList != null);
        String division = divisionList.get(0).getValue();
        List<String> regionStrList =new List<String>();
        regionStrList.add(regionList.get(0).getValue());
        List<String> departmentStrList =new List<String>();
        departmentStrList.add(departmentList.get(0).getValue());
        controller.division = division;
        controller.selectedRegions = regionStrList;
        controller.selectedDepartments = departmentStrList;
        controller.applyFilter();
        controller.showModifyScreen();
        Regional_FBP_Lookup__c fbLookup = new Regional_FBP_Lookup__c();
        fbLookup.Approver_Name__c =adminUserList.get(0).Name;
        fbLookup.FBP_Offer_Approver__c =adminUserList.get(1).Name;
        fbLookup.Regional_ESBP__c =adminUserList.get(2).Name;
        controller.fbpLookup = fbLookup;
        controller.applyValue();
        System.assert(ApexPages.hasMessages());
        controller.fbpLookup = new Regional_FBP_Lookup__c();
        controller.fbpInfoCompleteList.get(0).setSelectedFBP(true);
        controller.applyValue();
        System.assert(ApexPages.hasMessages());
        fbLookup.Approver_Name__c ='Test';
        fbLookup.FBP_Offer_Approver__c ='Test';
        fbLookup.Regional_ESBP__c ='Test';
        controller.fbpLookup = fbLookup;
        controller.fbpInfoCompleteList.get(0).setSelectedFBP(true);
        controller.applyValue();
        System.assert(ApexPages.hasMessages());
        System.debug('ApexPages.hasMessages()------->'+ ApexPages.hasMessages());
        System.debug('ApexPages.getMessages()------->'+ ApexPages.getMessages());
                
    }
    
    static testMethod void myUnitTest2() {
    	List<User> adminUserList = TestTF_Utils_Unit.getAdminUsers('System Administrator');
        FBPCustomCTL controller = new FBPCustomCTL();
        List<SelectOption> divisionList =controller.getDivisions();
        List<SelectOption> departmentList =controller.getDepartments();
        List<SelectOption> regionList =controller.getRegions();
        controller.showFilter();
        System.assert(divisionList != null);
        System.assert(departmentList != null);
        System.assert(regionList != null);
        String division = divisionList.get(0).getValue();
        List<String> regionStrList =new List<String>();
        regionStrList.add(regionList.get(0).getValue());
        List<String> departmentStrList =new List<String>();
        departmentStrList.add(departmentList.get(0).getValue());
        controller.division = division;
        controller.selectedRegions = regionStrList;
        controller.selectedDepartments = departmentStrList;
        controller.applyFilter();
        controller.showModifyScreen();
         controller.fbpInfoCompleteList.get(0).setSelectedFBP(true);
        Regional_FBP_Lookup__c fbLookup = new Regional_FBP_Lookup__c();
        fbLookup.Approver_Name__c ='Test';
        fbLookup.FBP_Offer_Approver__c ='Test';
        fbLookup.Regional_ESBP__c ='Test';
        controller.fbpLookup = fbLookup;
        controller.applyValue();
        System.assert(ApexPages.hasMessages());
        System.debug('ApexPages.hasMessages()------->'+ ApexPages.hasMessages());
        System.debug('ApexPages.getMessages()------->'+ ApexPages.getMessages());
                
    }
}