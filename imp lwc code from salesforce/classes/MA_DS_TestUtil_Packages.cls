/**
 * Test Utility class to setup Packages (Master & Acquisition Master type) data.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         02/12/2023      Chakshu Malhotra        Adds utility methods to setup Packages (Master & Acquisition Master type) data.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_Packages {

    public enum PackageType {MASTER, ACQUISITION}

    public enum MA_Package {US_PACKAGE, INDIA_PACKAGE}

    public static final String PACKAGE_TYPE_MASTER = Label.MA_DS_Package_Type_Master;
    public static final String PACKAGE_TYPE_ACQUISITION = Label.MA_DS_Package_Type_Acquisition;
    
    private static final String US_PACKAGE = 'US Package';
    private static final String INDIA_PACKAGE = 'India Package';

    private static final String PACKAGE_DESC_SUFFIX = ' test description';

    public static Map<String, MA_Package> maPackageMap {
        get {
            if(maPackageMap == null) {
                maPackageMap = new Map<String, MA_Package> {
                    US_PACKAGE => MA_Package.US_PACKAGE,
                    INDIA_PACKAGE => MA_Package.INDIA_PACKAGE
                };
            }
            return maPackageMap;
        }set;
    }

    private static Map<PackageType, String> packageTypeMap {
        get {
            if(packageTypeMap == null) {
                packageTypeMap = new Map<PackageType, String> {
                    PackageType.MASTER => PACKAGE_TYPE_MASTER,
                    PackageType.ACQUISITION => PACKAGE_TYPE_ACQUISITION
                };
            }
            return packageTypeMap;
        }set;
    }

    private static Map<MA_Package, String> maPackageToPackageNameMap {
        get {
            if(maPackageToPackageNameMap == null) {
                maPackageToPackageNameMap = new Map<MA_Package, String> {
                    MA_Package.US_PACKAGE => US_PACKAGE,
                    MA_Package.INDIA_PACKAGE => INDIA_PACKAGE
                };
            }
            return maPackageToPackageNameMap;
        }set;
    }

    public static Map<MA_Package, MA_DS_Package__c> setupMasterPackages() {
        return setupMasterPackages(new Set<MA_Package>(MA_Package.values()));
    }

    public static Map<MA_Package, MA_DS_Package__c> setupMasterPackages(Set<MA_Package> maPackages) {
        Map<MA_Package, MA_DS_Package__c> masterPackageMap = new Map<MA_Package, MA_DS_Package__c>();

        for(MA_Package maPackage : maPackages) {
            MA_DS_Package__c masterPackage = new MA_DS_Package__c();
            masterPackage.MA_DS_Package_Type__c = PACKAGE_TYPE_MASTER;
            masterPackage.Name = maPackageToPackageNameMap.get(maPackage);
            masterPackage.MA_DS_Package_Description__c = masterPackage.Name + PACKAGE_DESC_SUFFIX;
            masterPackageMap.put(maPackage, masterPackage);
        }
        
        insert masterPackageMap.values();
        return masterPackageMap;
    }

    public static Map<MA_Package, MA_DS_Package__c> setupAcquisitionPackages(Acquisition_Company__c acqCompany, Map<MA_Package, MA_DS_Package__c> masterPackageMap) {
        Map<MA_Package, MA_DS_Package__c> acqPackageMap = new Map<MA_Package, MA_DS_Package__c>();

        for(MA_Package maPackage : masterPackageMap.keySet()) {
            MA_DS_Package__c masterPackage = masterPackageMap.get(maPackage);

            MA_DS_Package__c acqPackage = new MA_DS_Package__c();
            acqPackage.Name = masterPackage.Name;
            acqPackage.MA_DS_Acquisition_Company__c = acqCompany.Id;
            acqPackage.MA_DS_Derived_From_Package__c = masterPackage.Id;
            acqPackage.MA_DS_Package_Type__c = PACKAGE_TYPE_ACQUISITION;
            acqPackage.MA_DS_Package_Description__c = masterPackage.MA_DS_Package_Description__c;

            acqPackageMap.put(maPackage, acqPackage);
        }

        insert acqPackageMap.values();
        return acqPackageMap;
    }

    private static List<MA_DS_Package__c> getPackages(Set<MA_Package> maPackages, PackageType maPackageType, Acquisition_Company__c acqCompany) {
        Id acqCompanyId = acqCompany?.Id;
        String packageType = packageTypeMap.get(maPackageType);
        Set<String> packageNames = getPackageNames(maPackages);

        String queryStr = 'SELECT Id, Name, MA_DS_Package_Type__c, MA_DS_Acquisition_Company__c, MA_DS_Derived_From_Package__c, MA_DS_Package_Description__c ';
        queryStr += ' FROM MA_DS_Package__c';
        queryStr += ' WHERE Name IN :packageNames AND';
        queryStr += ' MA_DS_Package_Type__c = :packageType';
        queryStr += (acqCompanyId == null) ? '' : ' AND MA_DS_Acquisition_Company__c = :acqCompanyId';

        return (List<MA_DS_Package__c>)Database.query(queryStr);
    }

    public static Set<String> getPackageNames(Set<MA_Package> maPackages) {
        Set<String> packageNames = new Set<String>();
        
        for(MA_Package maPackage : maPackages) {
            packageNames.add(maPackageToPackageNameMap.get(maPackage));
        }
        
        return packageNames;
    }

    public static MA_DS_Package__c getPackage(MA_Package maPackage, PackageType maPackageType) {
        List<MA_DS_Package__c> packages = getPackages(new Set<MA_Package> {maPackage}, maPackageType, null);
        return (packages.size() > 0) ? packages[0] : null;
    }

    public static MA_DS_Package__c getPackage(MA_Package maPackage, PackageType maPackageType, Acquisition_Company__c acqCompany) {
        List<MA_DS_Package__c> packages = getPackages(new Set<MA_Package> {maPackage}, maPackageType, acqCompany);
        return (packages.size() > 0) ? packages[0] : null;
    }

    public static Map<MA_Package, MA_DS_Package__c> getPackageMap(Set<MA_Package> maPackages, PackageType maPackageType) {
        return getPackageMap(maPackages, maPackageType, null);
    }

    public static Map<MA_Package, MA_DS_Package__c> getPackageMap(Set<MA_Package> maPackages, PackageType maPackageType, Acquisition_Company__c acqCompany) {
        Map<MA_Package, MA_DS_Package__c> packageMap = new Map<MA_Package, MA_DS_Package__c>();

        for(MA_DS_Package__c packageRef : getPackages(maPackages, maPackageType, acqCompany)) {
            packageMap.put(maPackageMap.get(packageRef.Name), packageRef);
        }
        
        return packageMap;
    }

    public static Set<Id> getPackageIds(Set<MA_Package> maPackages, PackageType maPackageType) {
        return getPackageIds(maPackages, maPackageType, null);
    }

    public static Set<Id> getPackageIds(Set<MA_Package> maPackages, PackageType maPackageType, Acquisition_Company__c acqCompany) {
        Set<Id> packageIds = new Set<Id>();

        for(MA_DS_Package__c packageRef : getPackages(maPackages, maPackageType, acqCompany)) {
            packageIds.add(packageRef.Id);
        }

        return packageIds;
    }
}