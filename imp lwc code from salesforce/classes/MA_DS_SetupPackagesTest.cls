/**
* W-12578116
* Test Utility Class for M&A Test data
* 
* 
* Version      Date            Author                  Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         21/04/2023      Manish Pal		       Test Utility Class for M&A Test data
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class MA_DS_SetupPackagesTest {
    
    @testSetup
    public static void MS_DS_TestSetupMethod(){
        Acquisition_Company__c acqCompany = MA_DS_TestUtility.createAcqCompanies();
        insert acqCompany;
        
        List<Acquisition_Contacts__c> createAcqContacts = MA_DS_TestUtility.createAcqContacts(acqCompany.id,1);
        insert createAcqContacts;
        
        List<MA_DS_Package__c> masterPackages = MA_DS_TestUtility.getMasterPackages();
        insert masterPackages;

        List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
        insert masterTemplates;

        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
        insert inUseMasterTemplates;
    }
    
    @isTest
    public static void getMasterPackagesTestMethod(){
        MA_DS_SetupPackages.getMasterPackages();
    }
    
    @isTest
    public static void getInUseTemplatesTestMethod(){
        Acquisition_Company__c acqCmp = [Select id from Acquisition_Company__c LIMIT 1];
        List<MA_DS_Package__c> listOfPAckages = [Select id from MA_DS_Package__c LIMIT 1];
        MA_DS_SetupPackages.getInUseTemplates(acqCmp.id,listOfPAckages[0].id);
    }
 
    @isTest
    public static void CalloutTestMethod(){
        Acquisition_Company__c acqCmp = [Select id from Acquisition_Company__c LIMIT 1];
        List<MA_DS_Package__c> listOfPAckages = [Select id from MA_DS_Package__c LIMIT 1];
        List<MA_DS_Template__c> listOfTemplate = [Select id from MA_DS_Template__c LIMIT 1];
        List<MA_DS_In_Use_Template__c> listOfInUseTemplate = [Select id from MA_DS_In_Use_Template__c LIMIT 1];
        
        
        MA_DS_SetupPackagesWrapper.PackageWrapper pw = new MA_DS_SetupPackagesWrapper.PackageWrapper();
        pw.packageId = listOfPAckages[0].Id;
        pw.packageDescription = 'Contains ALL AVAILABLE DOCUMENTS';
        pw.packageName = 'MASTER PACKAGE';
        
        MA_DS_SetupPackagesWrapper.TemplateWrapper tw = new MA_DS_SetupPackagesWrapper.TemplateWrapper();
        tw.mergeCapable=false;
        tw.templateDocumentType='Package Document'; 
        tw.templateId=listOfTemplate[0].Id;
        tw.templateName='Canada ON Hours Worked and Overtime Notice';
        
        MA_DS_SetupPackagesWrapper.InUseTemplateWrapper iw = new MA_DS_SetupPackagesWrapper.InUseTemplateWrapper();
        iw.inUseTemplateId=listOfInUseTemplate[0].Id; 
        iw.packageUsing = pw;
        iw.templateBeingUsed = tw;
        
        
        MA_DS_SetupPackagesWrapper mads = new MA_DS_SetupPackagesWrapper();
        mads.derivedInUseTemplate = null;
        mads.masterInUseTemplate = iw;
 
        MA_DS_SetupPackagesWrapper mads1 = new MA_DS_SetupPackagesWrapper();
        mads1.derivedInUseTemplate = iw;
        mads1.masterInUseTemplate = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MA_DS_SetupPackagesMockCallout());
        MA_DS_SetupPackages.copyPackagesAndTemplates(acqCmp.Id,new List<MA_DS_SetupPackagesWrapper>{mads},new List<MA_DS_SetupPackagesWrapper>{mads1});    
    	Test.stopTest();
    }
}