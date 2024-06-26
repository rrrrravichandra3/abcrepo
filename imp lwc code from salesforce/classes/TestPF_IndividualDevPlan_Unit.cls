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
private class TestPF_IndividualDevPlan_Unit {

    static testMethod void myUnitTest() {
    	MyCarrerPlan__c myc = new MyCarrerPlan__c();
    	myc.v2mom__c = [select id from V2mom__c limit 1][0].id;
    	upsert myc;
    	ApexPages.Standardcontroller stdcontroller =  new ApexPages.StandardController(myc);
       	ApexPages.currentPage().getParameters().put('v2mom', myc.v2mom__c);
       	ApexPages.currentPage().getParameters().put('id', myc.id);
       	IndividualDevPlanController controller = new IndividualDevPlanController(stdController);
		controller.getItems();
    	controller.save();
    	System.assert(controller.carPlan.Status__c.equals('Unlocked') );
    	controller.lockCareerPlan();
    	controller.gotoSharing();
    	controller.gotoAccess();
    	controller.cloneme();
    	controller.getDisabled();
    	controller.getRenderSharing();
    	System.assert(controller.carPlan.status__c.equals('Locked'));
    	controller.getItsMine();
    }
      static testMethod void myUnitTest2() {
      	MyCarrerPlan__c myc = new MyCarrerPlan__c();
      	myc.v2mom__c = [select id from V2mom__c limit 1][0].id;
    	upsert myc;
    	ApexPages.Standardcontroller stdcontroller =  new ApexPages.StandardController(myc);
    	ApexPages.currentPage().getParameters().put('v2mom', myc.v2mom__c);
       	ApexPages.currentPage().getParameters().put('id', 'new');
       	IndividualDevPlanController controller = new IndividualDevPlanController(stdController);
		controller.getItems();
    	controller.save();
    	System.assert(controller.carPlan.Status__c.equals('Unlocked') );
    	controller.lockCareerPlan();
    	System.assert(controller.carPlan.status__c.equals('Locked'));
    	controller.getItsMine();
    	controller.printView();
    	controller.gotoSharing();
    	controller.gotoAccess();
    	controller.cloneme();
    	controller.getDisabled();
    	controller.getRenderSharing();
    }
}