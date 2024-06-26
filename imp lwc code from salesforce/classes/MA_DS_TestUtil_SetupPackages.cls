/**
 * Test utility class for MA_DS_Test_SetupPackages class.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         04/12/2023      Chakshu Malhotra        Adds utility methods for MA_DS_Test_SetupPackages class.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_SetupPackages {

    public class DataWrapper {
        public List<MA_DS_In_Use_Template__c> inUseTemplates {get; private set;}
        public Map<MA_DS_TestUtil_Packages.MA_Package, MA_DS_Package__c> packageMap {get; private set;}
        public Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap {get; private set;}
    }

    public static DataWrapper setupMasterPackagesAndTemplates() {
        Set<MA_DS_TestUtil_Packages.MA_Package> maPackages = new Set<MA_DS_TestUtil_Packages.MA_Package>(MA_DS_TestUtil_Packages.MA_Package.values());
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template>(MA_DS_TestUtil_Templates.Template.values());
        return setupMasterPackagesAndTemplates(maPackages, maTemplates);
    }

    public static DataWrapper setupMasterPackagesAndTemplates(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        DataWrapper wrapperInstance = new DataWrapper();
        wrapperInstance.packageMap = MA_DS_TestUtil_Packages.setupMasterPackages(maPackages);
        wrapperInstance.templateMap = MA_DS_TestUtil_Templates.setupMasterTemplates(maTemplates, true);
        wrapperInstance.inUseTemplates = MA_DS_TestUtil_InUseTemplates.setupInUseTemplates(wrapperInstance.packageMap, wrapperInstance.templateMap, true);
        return wrapperInstance;
    }

    public static DataWrapper setupAcquisitionPackagesAndTemplates(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Acquisition_Company__c acqCompany) {
        DataWrapper wrapperInstance = new DataWrapper();
        wrapperInstance.packageMap = MA_DS_TestUtil_Packages.setupAcquisitionPackages(acqCompany, MA_DS_TestUtil_Packages.getPackageMap(maPackages, MA_DS_TestUtil_Packages.PackageType.MASTER));
        wrapperInstance.templateMap = MA_DS_TestUtil_Templates.setupAcquisitionTemplates(acqCompany, MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, MA_DS_TestUtil_Templates.TemplateType.MASTER), true);
        wrapperInstance.inUseTemplates = MA_DS_TestUtil_InUseTemplates.setupInUseTemplates(wrapperInstance.packageMap, wrapperInstance.templateMap, true);
        return wrapperInstance;
    }

    public static DataWrapper setupMasterPackagesAndTemplatesWithRules() {
        Set<MA_DS_TestUtil_Packages.MA_Package> maPackages = new Set<MA_DS_TestUtil_Packages.MA_Package>(MA_DS_TestUtil_Packages.MA_Package.values());
        Set<MA_DS_TestUtil_Templates.Template> maTemplates = new Set<MA_DS_TestUtil_Templates.Template>(MA_DS_TestUtil_Templates.Template.values());
        return setupMasterPackagesAndTemplatesWithRules(maPackages, maTemplates);
    }

    public static DataWrapper setupMasterPackagesAndTemplatesWithRules(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        DataWrapper wrapperInstance = setupMasterPackagesAndTemplates(maPackages, maTemplates);
        updateMasterInUseTemplatesWithRules(maPackages, maTemplates);
        return wrapperInstance;
    }

    public static void updateMasterInUseTemplatesWithRules(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        Map<String, MA_DS_In_Use_Template__c> inUseTemplateMap = MA_DS_TestUtil_InUseTemplates.getInUseTemplateMap(maPackages, maTemplates, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate.MASTER_IN_USE_TEMPLATE);
        MA_DS_TestUtil_RulesGenerator.generateRules(inUseTemplateMap.values(), true);
    }

    public static List<MA_DS_SetupPackagesWrapper> getSelectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package maPackage, MA_DS_TestUtil_Packages.PackageType maPackageType, Set<MA_DS_TestUtil_Templates.Template> maTemplates, MA_DS_TestUtil_Templates.TemplateType maTemplateType, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate inUseTemplateType) {
        MA_DS_SetupPackagesWrapper.PackageWrapper packageUsing = getPackageWrapper(maPackage, maPackageType);
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> templatesBeingUsedMap = getTemplateWrapperMap(maTemplates, maTemplateType);
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.InUseTemplateWrapper> inUseTemplateWrapperMap = getInUseTemplateWrapperMap(maPackage, packageUsing, templatesBeingUsedMap, inUseTemplateType);
        return getSelectedUnselectedInUseTemplates(true, inUseTemplateWrapperMap);
    }

    public static List<MA_DS_SetupPackagesWrapper> getUnselectedInUseTemplates(MA_DS_TestUtil_Packages.MA_Package maPackage, MA_DS_TestUtil_Packages.PackageType maPackageType, Set<MA_DS_TestUtil_Templates.Template> maTemplates, MA_DS_TestUtil_Templates.TemplateType maTemplateType, Acquisition_Company__c acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate inUseTemplateType) {
        MA_DS_SetupPackagesWrapper.PackageWrapper packageUsing = getPackageWrapper(maPackage, maPackageType, acqCompany);
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> templatesBeingUsedMap = getTemplateWrapperMap(maTemplates, maTemplateType, acqCompany);
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.InUseTemplateWrapper> inUseTemplateWrapperMap = getInUseTemplateWrapperMap(maPackage, packageUsing, templatesBeingUsedMap, acqCompany, inUseTemplateType);
        return getSelectedUnselectedInUseTemplates(false, inUseTemplateWrapperMap);
    }

    private static MA_DS_SetupPackagesWrapper.PackageWrapper getPackageWrapper(MA_DS_TestUtil_Packages.MA_Package maPackage, MA_DS_TestUtil_Packages.PackageType maPackageType) {
        MA_DS_Package__c packageRef = MA_DS_TestUtil_Packages.getPackage(maPackage, maPackageType);
        return getPackageWrapper(packageRef);
    }

    private static MA_DS_SetupPackagesWrapper.PackageWrapper getPackageWrapper(MA_DS_TestUtil_Packages.MA_Package maPackage, MA_DS_TestUtil_Packages.PackageType maPackageType, Acquisition_Company__c acqCompany) {
        MA_DS_Package__c packageRef = MA_DS_TestUtil_Packages.getPackage(maPackage, maPackageType, acqCompany);
        return getPackageWrapper(packageRef);
    }
    
    private static MA_DS_SetupPackagesWrapper.PackageWrapper getPackageWrapper(MA_DS_Package__c packageRef) {
        MA_DS_SetupPackagesWrapper.PackageWrapper packageWrapper = new MA_DS_SetupPackagesWrapper.PackageWrapper();
        packageWrapper.packageId = packageRef.Id;
        packageWrapper.packageName = packageRef.Name;
        packageWrapper.packageDescription = packageRef.MA_DS_Package_Description__c;
        return packageWrapper;
    }

    private static Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> getTemplateWrapperMap(Set<MA_DS_TestUtil_Templates.Template> maTemplates, MA_DS_TestUtil_Templates.TemplateType maTemplateType) {
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, maTemplateType);
        return getTemplateWrapperMap(templateMap);
    }

    private static Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> getTemplateWrapperMap(Set<MA_DS_TestUtil_Templates.Template> maTemplates, MA_DS_TestUtil_Templates.TemplateType maTemplateType, Acquisition_Company__c acqCompany) {
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, maTemplateType, acqCompany);
        return getTemplateWrapperMap(templateMap);
    }

    private static Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> getTemplateWrapperMap(Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap) {
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> templateWrapperMap = new Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper>();

        for(MA_DS_TestUtil_Templates.Template maTemplate : templateMap.keySet()) {
            MA_DS_Template__c templateRef = templateMap.get(maTemplate);

            MA_DS_SetupPackagesWrapper.TemplateWrapper templateWrapper = new MA_DS_SetupPackagesWrapper.TemplateWrapper();
            templateWrapper.templateId = templateRef.Id;
            templateWrapper.templateName = templateRef.Name;
            templateWrapper.mergeCapable = templateRef.MA_DS_Merge_Capable__c;
            templateWrapper.templateDocumentType = templateRef.MA_DS_Template_Document_Type__c;

            templateWrapperMap.put(maTemplate, templateWrapper);
        }

        return templateWrapperMap;
    }

    private static Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.InUseTemplateWrapper> getInUseTemplateWrapperMap(MA_DS_TestUtil_Packages.MA_Package maPackage, MA_DS_SetupPackagesWrapper.PackageWrapper packageUsing, Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> templatesBeingUsedMap, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate inUseTemplateType) {
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_In_Use_Template__c> inUseTemplateMap = MA_DS_TestUtil_InUseTemplates.getInUseTemplateMap(maPackage, templatesBeingUsedMap.keySet(), inUseTemplateType);
        return getInUseTemplateWrapperMap(packageUsing, templatesBeingUsedMap, inUseTemplateMap);
    }

    private static Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.InUseTemplateWrapper> getInUseTemplateWrapperMap(MA_DS_TestUtil_Packages.MA_Package maPackage, MA_DS_SetupPackagesWrapper.PackageWrapper packageUsing, Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> templatesBeingUsedMap, Acquisition_Company__c acqCompany, MA_DS_TestUtil_InUseTemplates.InUseTemplateTemplate inUseTemplateType) {
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_In_Use_Template__c> inUseTemplateMap = MA_DS_TestUtil_InUseTemplates.getInUseTemplateMap(maPackage, templatesBeingUsedMap.keySet(), acqCompany, inUseTemplateType);
        return getInUseTemplateWrapperMap(packageUsing, templatesBeingUsedMap, inUseTemplateMap);
    }

    private static Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.InUseTemplateWrapper> getInUseTemplateWrapperMap(MA_DS_SetupPackagesWrapper.PackageWrapper packageUsing, Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.TemplateWrapper> templatesBeingUsedMap, Map<MA_DS_TestUtil_Templates.Template, MA_DS_In_Use_Template__c> inUseTemplateMap) {
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.InUseTemplateWrapper> inUseTemplateWrapperMap = new Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.InUseTemplateWrapper>();

        for(MA_DS_TestUtil_Templates.Template maTemplate : inUseTemplateMap.keySet()) {
            MA_DS_SetupPackagesWrapper.InUseTemplateWrapper inUseTemplateWrapper = new MA_DS_SetupPackagesWrapper.InUseTemplateWrapper();
            inUseTemplateWrapper.packageUsing = packageUsing;
            inUseTemplateWrapper.templateBeingUsed = templatesBeingUsedMap.get(maTemplate);
            inUseTemplateWrapper.inUseTemplateId = inUseTemplateMap.get(maTemplate).Id;
            inUseTemplateWrapperMap.put(maTemplate, inUseTemplateWrapper);
        }

        return inUseTemplateWrapperMap;
    }

    private static List<MA_DS_SetupPackagesWrapper> getSelectedUnselectedInUseTemplates(Boolean isSelected, Map<MA_DS_TestUtil_Templates.Template, MA_DS_SetupPackagesWrapper.InUseTemplateWrapper> inUseTemplateWrapperMap) {
        List<MA_DS_SetupPackagesWrapper> selectedUnselectedInUseTemplates = new List<MA_DS_SetupPackagesWrapper>();

        for(MA_DS_SetupPackagesWrapper.InUseTemplateWrapper inUseTemplateWrapper : inUseTemplateWrapperMap.values()) {
            MA_DS_SetupPackagesWrapper newlySelectedInUseTemplate = new MA_DS_SetupPackagesWrapper();
            newlySelectedInUseTemplate.masterInUseTemplate = isSelected ? inUseTemplateWrapper : null;
            newlySelectedInUseTemplate.derivedInUseTemplate = isSelected ? null : inUseTemplateWrapper;
            selectedUnselectedInUseTemplates.add(newlySelectedInUseTemplate);
        }

        return selectedUnselectedInUseTemplates;
    }
}