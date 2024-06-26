/**
 * Test Utility class to setup Package Distributions data.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         09/12/2023      Chakshu Malhotra        Adds utility methods to setup Package Distributions data.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_PackageDistributions {
    
    public enum Distribution {US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, US_OTHERS, US_KEY_EMP, US_CRITICAL_EMP, US_ALL_EMP, IN_TELANGANA, IN_KARNATAKA, IN_KEY_EMP, IN_CRITICAL_EMP, IN_ALL_EMP}

    private static final String DEFAULT_STAGE = Label.MA_DS_PD_Status_In_Definition;
    private static final String DEFAULT_STATUS = Label.MA_DS_PD_Status_In_Definition;
    private static final String DEFAULT_RULES_SYNC_STATUS = Label.MA_DS_Rule_Sync_Status_NA;
    private static final String DEFAULT_INTEGRATION_STATUS = Label.MA_DS_Eligible_Integration_Status;

    private static final String SUMMARY_EMAIL_BODY = 'Custom Manager Summary Email Body For ';
    private static final String SUMMARY_EMAIL_SUBJECT = 'Custom Manager Summary Email Subject For ';
    private static final String PACKAGE_ENVELOPE_EMAIL_BODY = 'Custom Package Envelope Email Body For ';
    private static final String PACKAGE_ENVELOPE_EMAIL_SUBJECT = 'Custom Package Envelope Email Subject For ';

    private static List<DistributionWrapper> distributionWrappers {
        get {
            if(distributionWrappers == null) {
                distributionWrappers = distributionTypeWrapperMap.values();
            }
            return distributionWrappers;
        }set;
    }

    private static Map<Distribution, DistributionWrapper> distributionTypeWrapperMap {
        get {
            if(distributionTypeWrapperMap == null) {
                distributionTypeWrapperMap = new Map<Distribution, DistributionWrapper>();
                distributionTypeWrapperMap.put(Distribution.US_CALIFORNIA, new DistributionWrapper(Distribution.US_CALIFORNIA, true, 'US - California', true, true, 'United States of America', 'California', null));
                distributionTypeWrapperMap.put(Distribution.US_WASHINGTON, new DistributionWrapper(Distribution.US_WASHINGTON, true, 'US - Washington', true, true, 'United States of America', 'Washington', null));
                distributionTypeWrapperMap.put(Distribution.US_ILLINOIS, new DistributionWrapper(Distribution.US_ILLINOIS, true, 'US - Illinois', true, true, 'United States of America', 'Illinois', null));

                distributionTypeWrapperMap.put(Distribution.US_OTHERS, new DistributionWrapper(Distribution.US_OTHERS, true, 'US - Others', true, true, 'United States of America', null, null));

                distributionTypeWrapperMap.put(Distribution.US_KEY_EMP, new DistributionWrapper(Distribution.US_KEY_EMP, true, 'US - Key Employees', true, true, 'United States of America', null, null));
                
                distributionTypeWrapperMap.put(Distribution.US_CRITICAL_EMP, new DistributionWrapper(Distribution.US_CRITICAL_EMP, false, 'US - Critical Employees', false, false, 'United States of America', null, null));
                
                distributionTypeWrapperMap.put(Distribution.US_ALL_EMP, new DistributionWrapper(Distribution.US_ALL_EMP, true, 'US - All Employees', true, true, 'United States of America', null, null));
                
                distributionTypeWrapperMap.put(Distribution.IN_TELANGANA, new DistributionWrapper(Distribution.IN_TELANGANA, true, 'IN - Telangana', true, true, 'India', 'Telangana', null));
                distributionTypeWrapperMap.put(Distribution.IN_KARNATAKA, new DistributionWrapper(Distribution.IN_KARNATAKA, true, 'IN - Karnataka', true, true, 'India', 'Karnataka', null));
                
                distributionTypeWrapperMap.put(Distribution.IN_KEY_EMP, new DistributionWrapper(Distribution.IN_KEY_EMP, true, 'IN - Key Employees', true, true, 'India', null, null));
                
                distributionTypeWrapperMap.put(Distribution.IN_CRITICAL_EMP, new DistributionWrapper(Distribution.IN_CRITICAL_EMP, false, 'IN - Critical Employees', false, false, 'India', null, null));
                
                distributionTypeWrapperMap.put(Distribution.IN_ALL_EMP, new DistributionWrapper(Distribution.IN_ALL_EMP, true, 'IN - All Employees', true, true, 'India', null, null));
            }
            return distributionTypeWrapperMap;
        }set;
    }

    public static Set<Distribution> getUSDistributions() {
        return new Set<Distribution> {Distribution.US_CALIFORNIA, Distribution.US_WASHINGTON, Distribution.US_ILLINOIS, Distribution.US_OTHERS, Distribution.US_KEY_EMP, Distribution.US_CRITICAL_EMP, Distribution.US_ALL_EMP};
    }

    public static Set<Distribution> getINDistributions() {
        return new Set<Distribution> {Distribution.IN_TELANGANA, Distribution.IN_KARNATAKA, Distribution.IN_KEY_EMP, Distribution.IN_CRITICAL_EMP, Distribution.IN_ALL_EMP};
    }

    public static Map<Distribution, MA_DS_Package_Distribution__c> setupPackageDistributionsWithRules(Set<Distribution> maDistributions, MA_DS_Package__c packageRef, Boolean triggerDisabled) {
        Map<Distribution, MA_DS_Package_Distribution__c> distributionMap = setupPackageDistributions(maDistributions, packageRef, triggerDisabled);
        generateRules(distributionMap.values(), triggerDisabled);
        return distributionMap;
    }
    
    public static Map<Distribution, MA_DS_Package_Distribution__c> setupPackageDistributions(Set<Distribution> maDistributions, MA_DS_Package__c packageRef, Boolean triggerDisabled) {
        Map<Distribution, MA_DS_Package_Distribution__c> distributionMap = new Map<Distribution, MA_DS_Package_Distribution__c>();

        for(Distribution maDistribution : maDistributions) {
            DistributionWrapper distributionWrapper = distributionTypeWrapperMap.get(maDistribution);

            if(distributionWrapper != null) {
                MA_DS_Package_Distribution__c distribution = new MA_DS_Package_Distribution__c();
                distribution.MA_DS_Package__c = packageRef.Id;
                distribution.Name = distributionWrapper.distributionName;
                distribution.MA_DS_Summary_Required__c = distributionWrapper.summaryRequired;

                distribution.MA_DS_Status__c = DEFAULT_STATUS;
                distribution.MA_DS_Package_Distribution_Stage__c = DEFAULT_STAGE;
                distribution.MA_DS_Rules_Sync_Status__c = DEFAULT_RULES_SYNC_STATUS;
                distribution.MA_DS_Integration_Status__c = DEFAULT_INTEGRATION_STATUS;

                distribution.MA_DS_Custom_Manager_Summary_Email__c = distributionWrapper.customSummaryEmail;
                distribution.MA_DS_Custom_Package_Envelope_Email__c = distributionWrapper.customPackageEnvelopeEmail;
                
                distribution.MA_DS_Manager_Summary_Email_Body__c = distributionWrapper.summaryEmailBody;
                distribution.MA_DS_Manager_Summary_Email_Subject__c = distributionWrapper.summaryEmailSubject;

                distribution.MA_DS_Package_Envelope_Email_Body__c = distributionWrapper.packageEnvelopeEmailBody;
                distribution.MA_DS_Package_Envelope_Email_Subject__c = distributionWrapper.packageEnvelopeEmailSubject;

                distributionMap.put(maDistribution, distribution);
            }
        }

        insertPackageDistributions(distributionMap.values(), triggerDisabled);
        return distributionMap;
    }

    private static void insertPackageDistributions(List<MA_DS_Package_Distribution__c> packageDistributions, Boolean triggerDisabled) {
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = triggerDisabled;
        insert packageDistributions;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = false;
    }

    public static void generateRules(List<MA_DS_Package_Distribution__c> packageDistributions, Boolean triggerDisabled) {
        MA_DS_TestUtil_RulesGenerator.generateRules(packageDistributions, triggerDisabled);
    }

    public static DistributionWrapper getDistributionWrapper(String distributionName) {
        Integer distributionIndex = distributionWrappers.indexOf(new DistributionWrapper(distributionName));
        return distributionWrappers.get(distributionIndex);
    }

    public static List<MA_DS_Package_Distribution__c> getPackageDistributions(Set<Distribution> maDistributions, MA_DS_Package__c packageRef) {
        Id packageId = packageRef.Id;
        Set<String> distributionNames = getDistributionNames(maDistributions);

        String queryStr = 'SELECT Id, Name, MA_DS_Package__c, MA_DS_Summary_Required__c, MA_DS_Status__c, MA_DS_Package_Distribution_Stage__c, MA_DS_Rules_Sync_Status__c, MA_DS_Integration_Status__c,';
        queryStr += ' MA_DS_Rules_Criteria_JSON__c, MA_DS_Last_Synced_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c, MA_DS_Last_Synced_Criteria_Query__c,';
        queryStr += ' MA_DS_Manager_Summary_Rules_Sync_Date__c, MA_DS_Package_Rules_Sync_Date__c, MA_DS_Summary_Delivery_Datetime_GMT__c, MA_DS_Package_Delivery_Datetime_GMT__c';
        queryStr += ' FROM MA_DS_Package_Distribution__c';
        queryStr += ' WHERE Name IN :distributionNames AND';
        queryStr += ' MA_DS_Package__c = :packageId';

        return (List<MA_DS_Package_Distribution__c>)Database.query(queryStr);
    }

    private static Set<String> getDistributionNames(Set<Distribution> maDistributions) {
        Set<String> distributionNames = new Set<String>();
        
        for(Distribution maDistribution : maDistributions) {
            distributionNames.add(distributionTypeWrapperMap.get(maDistribution).distributionName);
        }
        
        return distributionNames;
    }

    public static MA_DS_Package_Distribution__c getPackageDistribution(Distribution maDistribution, MA_DS_Package__c packageRef) {
        List<MA_DS_Package_Distribution__c> packageDistributions = getPackageDistributions(new Set<Distribution> {maDistribution}, packageRef);
        return (packageDistributions.size() > 0) ? packageDistributions[0] : null;
    }

    public static List<MA_DS_Package_Distribution__c> getPackageDistributions(MA_DS_Package__c packageRef) {
        return getPackageDistributions(new Set<Distribution>(Distribution.values()), packageRef);
    }

    public static Map<Distribution, MA_DS_Package_Distribution__c> getPackageDistributionMap(Distribution maDistribution, MA_DS_Package__c packageRef) {
        return getPackageDistributionMap(new Set<Distribution> {maDistribution}, packageRef);
    }

    public static Map<Distribution, MA_DS_Package_Distribution__c> getPackageDistributionMap(MA_DS_Package__c packageRef) {
        return getPackageDistributionMap(new Set<Distribution>(Distribution.values()), packageRef);
    }

    public static Map<Distribution, MA_DS_Package_Distribution__c> getPackageDistributionMap(Set<Distribution> maDistributions, MA_DS_Package__c packageRef) {
        Map<Distribution, MA_DS_Package_Distribution__c> distributionMap = new Map<Distribution, MA_DS_Package_Distribution__c>();

        for(MA_DS_Package_Distribution__c packageDistribution : getPackageDistributions(maDistributions, packageRef)) {
            distributionMap.put(getDistributionWrapper(packageDistribution.Name).distributionType, packageDistribution);
        }

        return distributionMap;
    }

    public class DistributionWrapper {
        public Boolean summaryRequired {get; private set;}
        public String distributionName {get; private set;}
        public Boolean customSummaryEmail {get; private set;}
        public Boolean customPackageEnvelopeEmail {get; private set;}

        public String city {get; private set;}
        public String state {get; set;}
        public String country {get; private set;}

        public String summaryEmailBody {get; private set;}
        public String summaryEmailSubject {get; private set;}

        public String packageEnvelopeEmailBody {get; private set;}
        public String packageEnvelopeEmailSubject {get; private set;}

        public Distribution distributionType {get; private set;}

        public DistributionWrapper() {}

        public DistributionWrapper(String distributionName) {
            this.distributionName = distributionName;
        }

        public DistributionWrapper(Distribution distributionType, Boolean summaryRequired, String distributionName, Boolean customSummaryEmail, Boolean customPackageEnvelopeEmail, String country, String state, String city) {
            this.city = city;
            this.state = state;
            this.country = country;

            this.distributionType = distributionType;

            this.summaryRequired = summaryRequired;
            this.distributionName = distributionName;

            this.customSummaryEmail = customSummaryEmail;
            this.customPackageEnvelopeEmail = customPackageEnvelopeEmail;

            this.summaryEmailBody = customSummaryEmail ? SUMMARY_EMAIL_BODY + distributionName : null;
            this.summaryEmailSubject = customSummaryEmail ? SUMMARY_EMAIL_SUBJECT + distributionName : null;

            this.packageEnvelopeEmailBody = customPackageEnvelopeEmail ? PACKAGE_ENVELOPE_EMAIL_BODY + distributionName : null;
            this.packageEnvelopeEmailSubject = customPackageEnvelopeEmail ? PACKAGE_ENVELOPE_EMAIL_SUBJECT + distributionName : null;
        }

        public Boolean equals(Object obj) {
            Boolean isEquals = false;
    
            if(obj instanceof DistributionWrapper) {
                DistributionWrapper distributionWrapper = (DistributionWrapper) obj;
                isEquals = this.distributionName.equalsIgnoreCase(distributionWrapper.distributionName);
            }
    
            return isEquals;
        }
    
        public Integer hashCode() {
            return System.hashCode(distributionName);
        }
    }
}