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
@isTest(seeAllData=true)
public with sharing class DocuSignUtilsTest {

  static testMethod void  testgetOfferTemplateMap(){
    Map<String, Offer_Template__c> offerTemplateMap = DocuSignUtils.getOfferTemplateMap('ALL');
  	System.assert(offerTemplateMap.size()!=0);
  	
  }
  
  static testMethod void testFormatDateToDDMMMMYYYY(){
  	Datetime dateStr = Datetime.newInstance(2014, 8, 1);
    System.assertEquals('01 August 2014', DocuSignUtils.formatDateToDDMMMMYYYY(dateStr.date()+''));
  }
  
  static testMethod void testFormatDateToDDMMYYYY(){
    Datetime dateStr = Datetime.newInstance(2014, 8, 1);
    System.assertEquals('01/08/2014', DocuSignUtils.formatDateToDDMMYYYY(dateStr.date()+''));
    
  }
  
  static testMethod void testformatCurrencyCommaSeperated(){
    String amount='10000';
    System.assertEquals('10,000', DocuSignUtils.formatCurrencyCommaSeperated(amount));
  }
  
  static testMethod void formatCurrencyDotSeperated(){
   String amount='10000';
   System.assertEquals('10.000', DocuSignUtils.formatCurrencyDotSeperated(amount));
    
  }
  
  static testMethod void testTemplateIdReturnFromOfferTemplateObject(){
     
  }
  
}