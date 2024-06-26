/**
 * Test Utility class to setup In Use Templates (Master & Acquisition Master type) data.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         02/12/2023      Chakshu Malhotra        Adds utility methods to setup In Use Templates (Master & Acquisition Master type) data.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_InUseTemplates {

    public enum InUseTemplateTemplate {MASTER_IN_USE_TEMPLATE, ACQUISITION_IN_USE_TEMPLATE}

    private static Map<InUseTemplateTemplate, MA_DS_TestUtil_Packages.PackageType> packageTypeMap {
        get {
            if(packageTypeMap == null) {
                packageTypeMap = new Map<InUseTemplateTemplate, MA_DS_TestUtil_Packages.PackageType> {
                    InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE => MA_DS_TestUtil_Packages.PackageType.MASTER,
                    InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE => MA_DS_TestUtil_Packages.PackageType.ACQUISITION
                };
            }
            return packageTypeMap;
        }set;
    }

    private static Map<InUseTemplateTemplate, MA_DS_TestUtil_Templates.TemplateType> templateTypeMap {
        get {
            if(templateTypeMap == null) {
                templateTypeMap = new Map<InUseTemplateTemplate, MA_DS_TestUtil_Templates.TemplateType> {
                    InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE => MA_DS_TestUtil_Templates.TemplateType.MASTER,
                    InUseTemplateTemplate.ACQUISITION_IN_USE_TEMPLATE => MA_DS_TestUtil_Templates.TemplateType.ACQUISITION
                };
            }
            return templateTypeMap;
        }set;
    }
    
    private static Map<MA_DS_TestUtil_Packages.MA_Package, Set<MA_DS_TestUtil_Templates.Template>> packageToTemplateTypeMap {
        get {
            if(packageToTemplateTypeMap == null) {
                packageToTemplateTypeMap = new Map<MA_DS_TestUtil_Packages.MA_Package, Set<MA_DS_TestUtil_Templates.Template>> {
                    MA_DS_TestUtil_Packages.MA_Package.US_PACKAGE => MA_DS_TestUtil_Templates.getUSPackageTemplates(),
                    MA_DS_TestUtil_Packages.MA_Package.INDIA_PACKAGE => MA_DS_TestUtil_Templates.getIndiaPackageTemplates()
                };
            }
            return packageToTemplateTypeMap;
        }set;
    }

    public static List<MA_DS_In_Use_Template__c> setupInUseTemplates(Map<MA_DS_TestUtil_Packages.MA_Package, MA_DS_Package__c> packageMap, Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap, Boolean triggerDisabled) {
        Map<String, MA_DS_In_Use_Template__c> masterInUseTemplateMap = getMasterInUseTemplateMap(packageMap, templateMap);
        List<MA_DS_In_Use_Template__c> inUseTemplates = new List<MA_DS_In_Use_Template__c>();

        for(MA_DS_TestUtil_Packages.MA_Package packageType : packageMap.keySet()) {
            MA_DS_Package__c packageRef = packageMap.get(packageType);

            for(MA_DS_TestUtil_Templates.Template templateType : packageToTemplateTypeMap.get(packageType)) {
                if(templateMap.containsKey(templateType)) {
                    MA_DS_Template__c templateRef = templateMap.get(templateType);
                    MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper = MA_DS_TestUtil_Templates.getTemplateWrapper(templateRef.Name);

                    MA_DS_In_Use_Template__c inUseTemplate = new MA_DS_In_Use_Template__c();
                    inUseTemplate.MA_DS_Package_Using__c = packageRef.Id;
                    inUseTemplate.MA_DS_Template_Being_Used__c = templateRef.Id;
                    inUseTemplate.MA_DS_Sort_Order__c = templateWrapper.sortOrder;
                    inUseTemplate.MA_DS_Suppress_Audit_Flags__c = templateWrapper.suppressAuditFlags;
                    inUseTemplate.MA_DS_Suppress_Rules_Criteria__c = templateWrapper.suppressRulesCriteria;
                    inUseTemplate.MA_DS_Concatenated_Id__c = String.valueOf(packageRef.Id) + String.valueOf(templateRef.Id);  
                    
                    String masterConcatenatedId = getMasterConcatenatedId(packageRef, templateRef);

                    if(String.isNotBlank(masterConcatenatedId) && masterInUseTemplateMap.containsKey(masterConcatenatedId)) {
                        MA_DS_In_Use_Template__c masterInUseTemplate = masterInUseTemplateMap.get(masterConcatenatedId);
                        inUseTemplate.MA_DS_Audit_Flags_JSON__c = masterInUseTemplate.MA_DS_Audit_Flags_JSON__c;
                        inUseTemplate.MA_DS_Audit_Flags_Added__c = masterInUseTemplate.MA_DS_Audit_Flags_Added__c;
                        inUseTemplate.MA_DS_Rules_Criteria_JSON__c = masterInUseTemplate.MA_DS_Rules_Criteria_JSON__c;
                        inUseTemplate.MA_DS_Rules_Criteria_Query__c = masterInUseTemplate.MA_DS_Rules_Criteria_Query__c;
                        inUseTemplate.MA_DS_Rules_Criteria_Added__c = masterInUseTemplate.MA_DS_Rules_Criteria_Added__c;
                    }

                    inUseTemplates.add(inUseTemplate);
                }
            }
        }

        insertInUseTemplates(inUseTemplates, triggerDisabled);
        return inUseTemplates;
    }

    private static void insertInUseTemplates(List<MA_DS_In_Use_Template__c> inUseTemplates, Boolean triggerDisabled) {
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = triggerDisabled;
        insert inUseTemplates;
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = false;
    }

    private static Map<String, MA_DS_In_Use_Template__c> getMasterInUseTemplateMap(Map<MA_DS_TestUtil_Packages.MA_Package, MA_DS_Package__c> packageMap, Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap) {
        Map<String, MA_DS_In_Use_Template__c> masterInUseTemplateMap = new Map<String, MA_DS_In_Use_Template__c>();
        
        List<MA_DS_In_Use_Template__c> masterInUseTemplates = [SELECT Id, MA_DS_Audit_All__c, MA_DS_Concatenated_Id__c, MA_DS_Audit_Flags_Added__c, MA_DS_Rules_Criteria_Added__c, MA_DS_Audit_Flags_JSON__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c
                                                               FROM MA_DS_In_Use_Template__c
                                                               WHERE MA_DS_Package_Using__c IN :getMasterPackageIds(packageMap) AND
                                                               MA_DS_Template_Being_Used__c IN :getMasterTemplateIds(templateMap)];

        for(MA_DS_In_Use_Template__c masterInUseTemplate : masterInUseTemplates) {
            masterInUseTemplateMap.put(masterInUseTemplate.MA_DS_Concatenated_Id__c, masterInUseTemplate);
        }

        return masterInUseTemplateMap;
    }

    private static Set<Id> getMasterPackageIds(Map<MA_DS_TestUtil_Packages.MA_Package, MA_DS_Package__c> packageMap) {
        Set<Id> packageIds = new Set<Id>();

        for(MA_DS_Package__c packageRef : packageMap.values()) {
            if(packageRef.MA_DS_Derived_From_Package__c != null) {
                packageIds.add(packageRef.MA_DS_Derived_From_Package__c);
            }
        }

        return packageIds;
    }

    private static Set<Id> getMasterTemplateIds(Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap) {
        Set<Id> templateIds = new Set<Id>();

        for(MA_DS_Template__c templateRef : templateMap.values()) {
            if(templateRef.MA_DS_Derived_From_Template__c != null) {
                templateIds.add(templateRef.MA_DS_Derived_From_Template__c);
            }
        }

        return templateIds;
    }

    private static String getMasterConcatenatedId(MA_DS_Package__c packageRef, MA_DS_Template__c templateRef) {
        String masterPackageId = (packageRef.MA_DS_Derived_From_Package__c != null) ? String.valueOf(packageRef.MA_DS_Derived_From_Package__c) : '';
        String masterTemplateId = (templateRef.MA_DS_Derived_From_Template__c != null) ? String.valueOf(templateRef.MA_DS_Derived_From_Template__c) : '';
        return masterPackageId + masterTemplateId;
    }

    private static List<MA_DS_In_Use_Template__c> getInUseTemplates(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Acquisition_Company__c acqCompany, InUseTemplateTemplate inUseTemplateType) {
        Set<Id> packageIds = MA_DS_TestUtil_Packages.getPackageIds(maPackages, packageTypeMap.get(inUseTemplateType), acqCompany);
        Set<Id> templateIds = MA_DS_TestUtil_Templates.getTemplateIds(maTemplates, templateTypeMap.get(inUseTemplateType), acqCompany);

        String queryStr = 'SELECT Id, MA_DS_Audit_All__c, MA_DS_Concatenated_Id__c, MA_DS_Package_Using__c, MA_DS_Package_Using__r.Name, MA_DS_Template_Being_Used__c, MA_DS_Template_Being_Used__r.Name, MA_DS_Template_Being_Used__r.MA_DS_Template_Document_Type__c, MA_DS_Sort_Order__c, MA_DS_Audit_Flags_Added__c, MA_DS_Rules_Criteria_Added__c,';
        queryStr += ' MA_DS_Suppress_Audit_Flags__c, MA_DS_Suppress_Rules_Criteria__c, MA_DS_Audit_Flags_JSON__c, MA_DS_Applied_Audit_Flags_JSON__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c, MA_DS_Sync_Rules_On_PD_Ids__c';
        queryStr += ' FROM MA_DS_In_Use_Template__c';
        queryStr += ' WHERE MA_DS_Package_Using__c IN :packageIds AND';
        queryStr += ' MA_DS_Template_Being_Used__c IN :templateIds';

        return (List<MA_DS_In_Use_Template__c>)Database.query(queryStr);
    }

    public static MA_DS_In_Use_Template__c getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package maPackage, MA_DS_TestUtil_Templates.Template maTemplate, InUseTemplateTemplate inUseTemplateType) {
        List<MA_DS_In_Use_Template__c> inUseTemplates = getInUseTemplates(new Set<MA_DS_TestUtil_Packages.MA_Package> {maPackage}, new Set<MA_DS_TestUtil_Templates.Template> {maTemplate}, null, inUseTemplateType);
        return (inUseTemplates.size() > 0) ? inUseTemplates[0] : null;
    }

    public static MA_DS_In_Use_Template__c getInUseTemplate(MA_DS_TestUtil_Packages.MA_Package maPackage, MA_DS_TestUtil_Templates.Template maTemplate, Acquisition_Company__c acqCompany, InUseTemplateTemplate inUseTemplateType) {
        List<MA_DS_In_Use_Template__c> inUseTemplates = getInUseTemplates(new Set<MA_DS_TestUtil_Packages.MA_Package> {maPackage}, new Set<MA_DS_TestUtil_Templates.Template> {maTemplate}, null, inUseTemplateType);
        return (inUseTemplates.size() > 0) ? inUseTemplates[0] : null;
    }

    public static Map<MA_DS_TestUtil_Templates.Template, MA_DS_In_Use_Template__c> getInUseTemplateMap(MA_DS_TestUtil_Packages.MA_Package maPackage, Set<MA_DS_TestUtil_Templates.Template> maTemplates, InUseTemplateTemplate inUseTemplateType) {
        return getInUseTemplateMap(maPackage, maTemplates, null, inUseTemplateType);
    }

    public static Map<MA_DS_TestUtil_Templates.Template, MA_DS_In_Use_Template__c> getInUseTemplateMap(MA_DS_TestUtil_Packages.MA_Package maPackage, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Acquisition_Company__c acqCompany, InUseTemplateTemplate inUseTemplateType) {
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_In_Use_Template__c> inUseTemplateMap = new Map<MA_DS_TestUtil_Templates.Template, MA_DS_In_Use_Template__c>();

        for(MA_DS_In_Use_Template__c inUseTemplate : getInUseTemplates(new Set<MA_DS_TestUtil_Packages.MA_Package> {maPackage}, maTemplates, acqCompany, inUseTemplateType)) {
            MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper = MA_DS_TestUtil_Templates.getTemplateWrapper(inUseTemplate.MA_DS_Template_Being_Used__r.Name);
            inUseTemplateMap.put(templateWrapper.templateEnumType, inUseTemplate);
        }

        return inUseTemplateMap;
    }

    public static Map<String, MA_DS_In_Use_Template__c> getInUseTemplateMap(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates, InUseTemplateTemplate inUseTemplateType) {
        return getInUseTemplateMap(maPackages, maTemplates, null, inUseTemplateType);
    }

    public static Map<String, MA_DS_In_Use_Template__c> getInUseTemplateMap(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Acquisition_Company__c acqCompany, InUseTemplateTemplate inUseTemplateType) {
        Map<String, MA_DS_In_Use_Template__c> inUseTemplateMap = new Map<String, MA_DS_In_Use_Template__c>();

        for(MA_DS_In_Use_Template__c inUseTemplate : getInUseTemplates(maPackages, maTemplates, acqCompany, inUseTemplateType)) {
            String maPackage = MA_DS_TestUtil_Packages.maPackageMap.get(inUseTemplate.MA_DS_Package_Using__r.Name).name();
            String maTemplate = MA_DS_TestUtil_Templates.getTemplateWrapper(inUseTemplate.MA_DS_Template_Being_Used__r.Name).templateEnumType.name();
            String concatenatedKey = maPackage + maTemplate;
            inUseTemplateMap.put(concatenatedKey, inUseTemplate);
        }

        return inUseTemplateMap;
    }

    public static void updateAcqInUseTemplatesWithRules(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Boolean triggerDisabled) {
        Map<String, MA_DS_In_Use_Template__c> acqInUseTemplateMap = new Map<String, MA_DS_In_Use_Template__c>();
        Map<String, MA_DS_In_Use_Template__c> masterInUseTemplateMap = new Map<String, MA_DS_In_Use_Template__c>();
        
        List<MA_DS_In_Use_Template__c> inUseTemplates = getInUseTemplates(maPackages, maTemplates);

        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            String concatenatedKey = inUseTemplate.MA_DS_Package_Using__r.Name + inUseTemplate.MA_DS_Template_Being_Used__r.Name;

            if(inUseTemplate.MA_DS_Package_Using__r.MA_DS_Package_Type__c.equalsIgnoreCase(MA_DS_TestUtil_Packages.PACKAGE_TYPE_MASTER)) {
                masterInUseTemplateMap.put(concatenatedKey, inUseTemplate);
            }else {
                acqInUseTemplateMap.put(concatenatedKey, inUseTemplate);
            }
        }

        updateInUseTemplates(getInUseTemplatesWithUpdatedRules(inUseTemplates, masterInUseTemplateMap, acqInUseTemplateMap), triggerDisabled);
    }

    private static List<MA_DS_In_Use_Template__c> getInUseTemplates(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        return [SELECT Id, MA_DS_Package_Using__r.MA_DS_Package_Type__c, MA_DS_Package_Using__r.Name, MA_DS_Template_Being_Used__r.Name, MA_DS_Audit_Flags_JSON__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c
                FROM MA_DS_In_Use_Template__c
                WHERE MA_DS_Package_Using__r.Name IN :MA_DS_TestUtil_Packages.getPackageNames(maPackages) AND
                MA_DS_Template_Being_Used__r.Name IN :MA_DS_TestUtil_Templates.getTemplateNames(maTemplates)];
    }

    private static List<MA_DS_In_Use_Template__c> getInUseTemplatesWithUpdatedRules(List<MA_DS_In_Use_Template__c> inUseTemplates, Map<String, MA_DS_In_Use_Template__c> masterInUseTemplateMap, Map<String, MA_DS_In_Use_Template__c> acqInUseTemplateMap) {
        List<MA_DS_In_Use_Template__c> updatedInUseTemplates = new List<MA_DS_In_Use_Template__c>();

        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            String concatenatedKey = inUseTemplate.MA_DS_Package_Using__r.Name + inUseTemplate.MA_DS_Template_Being_Used__r.Name;

            if(inUseTemplate.MA_DS_Package_Using__r.MA_DS_Package_Type__c.equalsIgnoreCase(MA_DS_TestUtil_Packages.PACKAGE_TYPE_ACQUISITION)) {
                MA_DS_In_Use_Template__c acqInUseTemplate = acqInUseTemplateMap.get(concatenatedKey);
                MA_DS_In_Use_Template__c masterInUseTemplate = masterInUseTemplateMap.get(concatenatedKey);

                acqInUseTemplate.MA_DS_Audit_Flags_JSON__c = masterInUseTemplate.MA_DS_Audit_Flags_JSON__c;
                acqInUseTemplate.MA_DS_Rules_Criteria_JSON__c = masterInUseTemplate.MA_DS_Rules_Criteria_JSON__c;
                acqInUseTemplate.MA_DS_Rules_Criteria_Query__c = masterInUseTemplate.MA_DS_Rules_Criteria_Query__c;
                updatedInUseTemplates.add(acqInUseTemplate);
            }
        }

        return updatedInUseTemplates;
    }

    private static void updateInUseTemplates(List<MA_DS_In_Use_Template__c> inUseTemplates, Boolean triggerDisabled) {
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = triggerDisabled;
        update inUseTemplates;
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = false;
    }
}