@isTest
public class MA_DS_AddRulesCriteriaTest {
    
    @testSetup
    public static void MS_DS_TestSetupMethod(){
        List<MA_DS_Package__c> masterPackages = MA_DS_TestUtility.getMasterPackages();
        insert masterPackages;
        
        MA_DS_Package_Distribution__c packageDistribution = MA_DS_TestUtility.createPackageDistribution(masterPackages[0].Id);
        insert packageDistribution;
        
        MA_DS_Package_Distribution__c packageDistribution1 = MA_DS_TestUtility.createPackageDistribution(masterPackages[0].Id);
        packageDistribution1.Name = 'Test Distribution1';
        packageDistribution1.MA_DS_Rules_Sync_Status__c = 'Need Sync - Template Rules';
        packageDistribution1.MA_DS_Status__c = 'Package Audit Complete';
        insert packageDistribution1;
        
        List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
        insert masterTemplates;
        
        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
        insert inUseMasterTemplates;
    }
    
    @isTest
    public static void processRulesTestMethod(){
        
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        
        
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrpr = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrpr.label='Allowance Amount';
        fieldWrpr.name='Car_Allowance_Amount__c'; 
        fieldWrpr.picklistOptions=null;
        fieldWrpr.sampleSize=null;
        fieldWrpr.type='CURRENCY';
        fieldWrpr.value='car_allowance_amount__c';
        
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrprCon = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrprCon.label='Office Address - Country'; 
        fieldWrprCon.name='Office_Address_Country__c'; 
        fieldWrprCon.picklistOptions=null;
        fieldWrprCon.sampleSize=null;
        fieldWrprCon.type='PICKLIST';
        fieldWrprCon.value='office_address_country__c';
        
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrprCon2 = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrprCon2.label='Office Address - State/Province'; 
        fieldWrprCon2.name='Office_Address_State_Province__c'; 
        fieldWrprCon2.picklistOptions=null;
        fieldWrprCon2.sampleSize=null;
        fieldWrprCon2.type='STRING';
        fieldWrprCon2.value='office_address_state_province__c';
        
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrprCon3 = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrprCon3.label='Executive';
        fieldWrprCon3.name='Executive__c'; 
        fieldWrprCon3.picklistOptions=null; 
        fieldWrprCon3.sampleSize=null;
        fieldWrprCon3.type='BOOLEAN';
        fieldWrprCon3.value='executive__c';
        
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrprCon4 = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrprCon4.label='Acknowledged On';
        fieldWrprCon4.name='Confirmed_On__c'; 
        fieldWrprCon4.picklistOptions=null; 
        fieldWrprCon4.sampleSize=null;
        fieldWrprCon4.type='DATETIME';
        fieldWrprCon4.value='confirmed_on__c';
        
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrprCon5 = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrprCon5.label='Contractor End Date';
        fieldWrprCon5.name='Contractor_End_Date__c'; 
        fieldWrprCon5.picklistOptions=null; 
        fieldWrprCon5.sampleSize=null;
        fieldWrprCon5.type='DATE';
        fieldWrprCon5.value='contractor_end_date__c';
        
        MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper rulesCriteriaWrpr = new MA_DS_AddRulesCriteriaWrapper.RulesCriteriaWrapper();
        rulesCriteriaWrpr.customLogicMap = new Map<String, Boolean>();
        rulesCriteriaWrpr.fieldOperatorMap = new Map<String, String>();
        rulesCriteriaWrpr.fieldRowMap = new Map<String, List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>();
        rulesCriteriaWrpr.fieldValueMap = new Map<String, String>();
        rulesCriteriaWrpr.ruleLogicMap = new Map<String,  List<String>>();
        
        rulesCriteriaWrpr.customLogicMap.put('Acquisition_Compensation__c',false);
        rulesCriteriaWrpr.customLogicMap.put('Acquisition_Contacts__c',true);
        rulesCriteriaWrpr.fieldOperatorMap.put('Acquisition_Compensation__ccar_allowance_amount__c1','GREATER THAN');
        rulesCriteriaWrpr.fieldOperatorMap.put('Acquisition_Contacts__cexecutive__c3','EQUALS');
        rulesCriteriaWrpr.fieldOperatorMap.put('Acquisition_Contacts__coffice_address_country__c1','CONTAINS');
        rulesCriteriaWrpr.fieldOperatorMap.put('Acquisition_Contacts__coffice_address_state_province__c2','EQUALS');
        rulesCriteriaWrpr.fieldOperatorMap.put('Acquisition_Compensation__ccar_allowance_amount__c1','GREATER THAN');
        rulesCriteriaWrpr.fieldOperatorMap.put('Acquisition_Contacts__cconfirmed_on__c4','EQUALS');
        rulesCriteriaWrpr.fieldOperatorMap.put('Acquisition_Contacts__ccontractor_end_date__c5','GREATER THAN');
        rulesCriteriaWrpr.fieldRowMap.put('Acquisition_Compensation__c',new List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper>{fieldWrpr});
        rulesCriteriaWrpr.fieldRowMap.put('Acquisition_Contacts__c',new List<MA_DS_AddRulesCriteriaWrapper.FieldWrapper>{fieldWrprCon,fieldWrprCon2,fieldWrprCon3,fieldWrprCon4,fieldWrprCon5});
        rulesCriteriaWrpr.fieldValueMap.put('Acquisition_Compensation__ccar_allowance_amount__c1','10');
        rulesCriteriaWrpr.fieldValueMap.put('Acquisition_Contacts__cexecutive__c3','False');
        rulesCriteriaWrpr.fieldValueMap.put('Acquisition_Contacts__coffice_address_country__c1','India');
        rulesCriteriaWrpr.fieldValueMap.put('Acquisition_Contacts__coffice_address_state_province__c2','Karnataka');
        rulesCriteriaWrpr.fieldValueMap.put('Acquisition_Contacts__cconfirmed_on__c4','2023-05-02T13:43:00.000Z');
        rulesCriteriaWrpr.fieldValueMap.put('Acquisition_Contacts__ccontractor_end_date__c5','2023-06-10');
        rulesCriteriaWrpr.ruleLogicMap.put('Acquisition_Compensation__c',new List<String>{'1'});
        rulesCriteriaWrpr.ruleLogicMap.put('Acquisition_Contacts__c',new List<String>{'1', 'AND', '2', 'AND', '3','AND', '4','AND', '5'});
        
        
        MA_DS_AddRulesCriteriaWrapper addRuleCriteriaWrpr = new MA_DS_AddRulesCriteriaWrapper();
        addRuleCriteriaWrpr.childRelationshipMap = new Map<String,String>();
        addRuleCriteriaWrpr.allowedOperatorsMap = null;
        addRuleCriteriaWrpr.auditFlagsFieldMap = null;
        addRuleCriteriaWrpr.auditFlagsJSON =null;
        addRuleCriteriaWrpr.childRelationshipMap.put('Acquisition_Compensation__c','Acquisition_Compensation__r');
        addRuleCriteriaWrpr.displayAuditFlags = null;
        addRuleCriteriaWrpr.displayRulesCriteria=null; 
        addRuleCriteriaWrpr.maxSampleSize=null;
        addRuleCriteriaWrpr.noRulesDisplayMessage=null;
        addRuleCriteriaWrpr.parentSObject='Acquisition_Contacts__c'; 
        addRuleCriteriaWrpr.rulesCriteriaFieldMap=null;
        addRuleCriteriaWrpr.rulesCriteriaJSON = rulesCriteriaWrpr;
        
        Test.startTest();
        MA_DS_AddRulesCriteria.processRules(listOfPAckagesDistribution[0].Id,'MA_DS_Package_Distribution__c',addRuleCriteriaWrpr);
        Test.stopTest();
    }
    @isTest
    public static void getRulesWrapperTestMethod(){
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        Test.startTest();
        MA_DS_AddRulesCriteria.getRulesWrapper(listOfPAckagesDistribution[0].Id,'MA_DS_Package_Distribution__c');
        Test.stopTest();
        
    }
    
    @isTest
    public static void inusetemplateTestMethod(){
        List<MA_DS_In_Use_Template__c> listOfInUseTemplate = [Select id from MA_DS_In_Use_Template__c LIMIT 1];

        Map<String,MA_DS_AddRulesCriteriaWrapper.FieldWrapper> aqCompansaion = new Map<String,MA_DS_AddRulesCriteriaWrapper.FieldWrapper>();
        Map<String,MA_DS_AddRulesCriteriaWrapper.FieldWrapper> aqContact = new Map<String,MA_DS_AddRulesCriteriaWrapper.FieldWrapper>();
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrpr = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrpr.label=null;
        fieldWrpr.name=null;
        fieldWrpr.picklistOptions=null; 
        fieldWrpr.sampleSize=2; 
        fieldWrpr.type='BOOLEAN';
        fieldWrpr.value=null;
        
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrpr2 = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrpr2.label=null;
        fieldWrpr2.name=null;
        fieldWrpr2.picklistOptions=null; 
        fieldWrpr2.sampleSize=1; 
        fieldWrpr2.type='STRING';
        fieldWrpr2.value=null;
        
        MA_DS_AddRulesCriteriaWrapper.FieldWrapper fieldWrpr3 = new MA_DS_AddRulesCriteriaWrapper.FieldWrapper();
        fieldWrpr2.label=null;
        fieldWrpr2.name=null;
        fieldWrpr2.picklistOptions=null; 
        fieldWrpr2.sampleSize=1; 
        fieldWrpr2.type='PICKLIST';
        fieldWrpr2.value=null;
        
        aqCompansaion.put('billable_target__c',fieldWrpr);
        aqCompansaion.put('job_grade_target__c',fieldWrpr2);
        aqCompansaion.put('pay_plan__c',fieldWrpr3);
        
        aqContact.put('division__c',fieldWrpr3);
        aqContact.put('employee_type_target__c',fieldWrpr2);
            
        MA_DS_AddRulesCriteriaWrapper addRuleCriteriaWrpr = new MA_DS_AddRulesCriteriaWrapper();
        addRuleCriteriaWrpr.auditFlagsJSON = new Map<String,Map<String,MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>();
		addRuleCriteriaWrpr.childRelationshipMap = new Map<String,String>();
        addRuleCriteriaWrpr.allowedOperatorsMap = null;
        addRuleCriteriaWrpr.auditFlagsFieldMap = null;
        addRuleCriteriaWrpr.auditFlagsJSON.put('Acquisition_Compensation__c',aqCompansaion);
        addRuleCriteriaWrpr.auditFlagsJSON.put('Acquisition_Contacts__c',aqContact);

        addRuleCriteriaWrpr.childRelationshipMap.put('Acquisition_Compensation__c','Acquisition_Compensation__r');
        addRuleCriteriaWrpr.displayAuditFlags = null;
        addRuleCriteriaWrpr.displayRulesCriteria=null; 
        addRuleCriteriaWrpr.maxSampleSize=null;
        addRuleCriteriaWrpr.noRulesDisplayMessage=null;
        addRuleCriteriaWrpr.parentSObject='Acquisition_Contacts__c'; 
        addRuleCriteriaWrpr.rulesCriteriaFieldMap=null;
        addRuleCriteriaWrpr.rulesCriteriaJSON = null;
        addRuleCriteriaWrpr.sObjectMap = null;
        
        Test.startTest();
        MA_DS_AddRulesCriteria.processRules(listOfInUseTemplate[0].Id,'MA_DS_In_Use_Template__c',addRuleCriteriaWrpr);
        Test.stopTest();
    }
    
    @isTest
    public static void addProcessRulesTestMethod(){
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c Where Name = 'Test Distribution'];
        Test.startTest();
        MA_DS_ApplyRules.applyRules(listOfPAckagesDistribution[0].id);
    	Test.stopTest();
    }
    
    @isTest
    public static void addProcessRulesTestMethod1(){
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c where Name = 'Test Distribution1'];
        Test.startTest();
        MA_DS_ApplyRules.applyRules(listOfPAckagesDistribution[0].id);
    	Test.stopTest();
    }
}