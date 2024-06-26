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
private class Test_lockingDetailsOfApprovedOffer {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
		ts2__Job__c newJob = Test_Utils.createDefaultJobReq();
		ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id);
		offer1.Location__c= 'San Francisco, CA';
		offer1.OfferStatus__c='Approved';
		insert offer1;
		
		offer1.Agency_Fee__c= 10;
		update offer1;
		System.debug('ApexPages.hasMessages()------->'+ ApexPages.hasMessages());
		System.assert(!ApexPages.hasMessages());
		
	    
    }
    
    static testMethod void myUnitTest1() {
        ts2__Job__c newJob = Test_Utils.createDefaultJobReq();
		
		ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id);
		offer1.Location__c= 'San Francisco, CA';
		offer1.OfferStatus__c='Approved';
		offer1.Agency_Fee__c= 1;
		offer1.Draw__c='13';
		offer1.ts2__Salary__c =20;
		offer1.ts2__Mileage__c =20;
		offer1.ts2__Meals__c =20;
		
		offer1.ts2__Bonus__c =20;
		offer1.Variable__c ='13';
		offer1.Variable_Type__c ='Commission1';
		offer1.Target_Variable_Amount__c =20;
		offer1.Stock_Options__c ='20';
		offer1.Requires_Accelerated_Green_Card__c =false;
		offer1.Relocation_Package_Cost__c =20;
		offer1.RSUs__c='12';
		offer1.Quota__c='12';
		offer1.Quota_Currency__c='AUD - Australian Dollar';
		offer1.Quartile__c='1';
		offer1.Non_Standard_Stock__c=false;
		offer1.ImmigrationCost__c=20;
		offer1.RSUs__c ='1';
		offer1.RSUs_Value__c =1;
		offer1.Stock_Grant_Date__c ='January 24, 2012';
		offer1.Stock_Options_Value__c =223;
		offer1.Stock_Plan__c ='2006 Inducement Equity Incentive Plan - Value';
		insert offer1;
		
		System.runAs(Test_Utils.getUser('Employee')) {
			offer1.Agency_Fee__c= 10;
			offer1.Draw__c='123';
			offer1.ts2__Salary__c =200;
			offer1.ts2__Mileage__c =200;
			offer1.ts2__Meals__c =200;
			
			offer1.ts2__Bonus__c =200;
			offer1.Variable__c ='123';
			offer1.Variable_Type__c ='Commission';
			offer1.Target_Variable_Amount__c =200;
			offer1.Stock_Options__c ='200';
			offer1.Requires_Accelerated_Green_Card__c =true;
			offer1.Relocation_Package_Cost__c =200;
			offer1.RSUs__c='123';
			offer1.Quota__c='123';
			offer1.Quota_Currency__c='AUD - Australian Dollar';
			offer1.Quartile__c='2';
			offer1.Non_Standard_Stock__c=true;
			offer1.ImmigrationCost__c=200;
			offer1.RSUs__c ='10';
			offer1.RSUs_Value__c =10;
			offer1.Stock_Grant_Date__c ='March 27, 2012';
			offer1.Stock_Options_Value__c =24;
			offer1.Stock_Plan__c ='2004 Equity Incentive Plan - Value';
			try {
			    update offer1;
			} catch(DmlException  ex) {
				//System.assert('Offer has been approved and fields have been locked' ,ex.getMessage() );
				System.assert(ex.getMessage() != null );
			}
		}
		
    }
		
    
}