/**
 * Test utility class for MA_DS_Test_PackageDistributionTrigger class.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         13/12/2023      Chakshu Malhotra        Adds utility methods for MA_DS_Test_PackageDistributionTrigger class.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_PkgDistributionTrigger {

    public enum DistributionStage {READY_FOR_SUMMARY_PREP, SUMMARY_GEN_FAIL, NEED_SUMMARY_REGEN, READY_FOR_SUMMARY_DELIVERY, SUMMARY_DELIVERED, PARTIAL_SUMMARY_DELIVERED, 
                                   READY_FOR_PACKAGE_PREP, PACKAGE_GEN_FAIL, NEED_PACKAGE_REGEN, READY_FOR_PACKAGE_DELIVERY, PACKAGE_DELIVERED, PARTIAL_PACKAGE_DELIVERED}
    
    public static final String RULES_SYNCED = Label.MA_DS_Rules_Synced_Status;
    public static final String SYNCING_PACKAGE_RULES = Label.MA_DS_Syncing_Package_Rules_Status;
    public static final String SYNCING_TEMPLATE_RULES = Label.MA_DS_Syncing_Templates_Rules_Status;
    public static final String NEED_SYNC_TEMPLATE_RULES = Label.MA_DS_Need_Sync_Template_Rules_Status;
    public static final String NEED_SYNC_PACKAGE_TEMPLATE_RULES = Label.MA_DS_Need_Sync_Package_Template_Rules_Status;

    public static final String STATUS_PACKAGE_SENT = Label.MA_DS_PD_Status_Sent;
    public static final String SUMMARY_AUDIT_COMPLETE = Label.MA_DS_PD_Status_Summary_Audit_Complete;
    public static final String PACKAGE_AUDIT_COMPLETE = Label.MA_DS_PD_Status_Package_Audit_Complete;

    public static final String STAGE_READY_FOR_SUMMARY_PREP = Label.MA_DS_PD_Stage_Ready_For_Summary_Prep;
    public static final String STAGE_READY_FOR_PACKAGE_PREP = Label.MA_DS_PD_Stage_Ready_For_Package_Prep;
    public static final String STAGE_READY_FOR_SUMMARY_DELIVERY = Label.MA_DS_PD_Stage_Ready_For_Summary_Delivery;
    public static final String STAGE_READY_FOR_PACKAGE_DELIVERY = Label.MA_DS_PD_Stage_Ready_For_Package_Delivery;

    private static void updatePackageDistribution(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = triggerDisabled;
        update packageDistribution;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = false;
    }

    public static MA_DS_Package_Distribution__c getPackageDistribution(MA_DS_TestUtil_PackageDistributions.Distribution maDistribution, MA_DS_Package__c packageRef) {
        return MA_DS_TestUtil_PackageDistributions.getPackageDistribution(maDistribution, packageRef);
    }

    public static void updateRulesSyncStatus(MA_DS_Package_Distribution__c packageDistribution, String rulesSyncStatus, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Rules_Sync_Status__c = rulesSyncStatus;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updateSummaryRequired(MA_DS_Package_Distribution__c packageDistribution, Boolean summaryRequired, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Summary_Required__c = summaryRequired;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updateDistributionStatus(MA_DS_Package_Distribution__c packageDistribution, String distributionStatus, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Status__c = distributionStatus;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updateDistributionAndRulesSyncStatus(MA_DS_Package_Distribution__c packageDistribution, String distributionStatus, String rulesSyncStatus, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Status__c = distributionStatus;
        packageDistribution.MA_DS_Rules_Sync_Status__c = rulesSyncStatus;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updateSummaryDeliverySchedule(MA_DS_Package_Distribution__c packageDistribution, Boolean scheduled, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Schedule_Summary_Delivery__c = scheduled;
        if(scheduled) {
            updateSummaryDeliverySchedule(packageDistribution);
        }
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    private static void updateSummaryDeliverySchedule(MA_DS_Package_Distribution__c packageDistribution) {
        packageDistribution.MA_DS_Summary_Delivery_Date__c = System.today().addDays(2);
        packageDistribution.MA_DS_Summary_Delivery_Time__c = Time.newInstance(10, 30, 0, 0);
        packageDistribution.MA_DS_Summary_Delivery_Time_Zone__c = 'America/New_York';
        packageDistribution.MA_DS_Summary_Delivery_Datetime_GMT__c = getScheduledDeliveryDatetimeGMT(packageDistribution.MA_DS_Summary_Delivery_Date__c, packageDistribution.MA_DS_Summary_Delivery_Time__c, packageDistribution.MA_DS_Summary_Delivery_Time_Zone__c);
    }

    private static Datetime getScheduledDeliveryDatetimeGMT(Date scheduledDate, Time scheduledTime, String timeZoneStr) {
        Datetime scheduledDatetimeGMT = Datetime.newInstanceGmt(scheduledDate, scheduledTime);
        Integer timeZoneOffset = (TimeZone.getTimeZone(timeZoneStr).getOffset(scheduledDatetimeGMT)) / 1000;
        return scheduledDatetimeGMT.addSeconds(-timeZoneOffset);
    }

    public static void updatePackageDeliverySchedule(MA_DS_Package_Distribution__c packageDistribution, Boolean scheduled, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Schedule_Package_Delivery__c = scheduled;
        if(scheduled) {
            updatePackageDeliverySchedule(packageDistribution);
        }
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    private static void updatePackageDeliverySchedule(MA_DS_Package_Distribution__c packageDistribution) {
        packageDistribution.MA_DS_Package_Delivery_Date__c = System.today().addDays(2);
        packageDistribution.MA_DS_Package_Delivery_Time__c = Time.newInstance(10, 30, 0, 0);
        packageDistribution.MA_DS_Package_Delivery_Time_Zone__c = 'America/New_York';
        packageDistribution.MA_DS_Package_Delivery_Datetime_GMT__c = getScheduledDeliveryDatetimeGMT(packageDistribution.MA_DS_Package_Delivery_Date__c, packageDistribution.MA_DS_Package_Delivery_Time__c, packageDistribution.MA_DS_Package_Delivery_Time_Zone__c);
    }

    public static void updatePackageDistributionStage(MA_DS_Package_Distribution__c packageDistribution, DistributionStage maDistributionStage, Boolean summaryRequired, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Rules_Sync_Status__c = RULES_SYNCED;
        packageDistribution.MA_DS_Package_Rules_Sync_Date__c = Datetime.now().addDays(-6);
        packageDistribution.MA_DS_Last_Synced_Criteria_Query__c = packageDistribution.MA_DS_Rules_Criteria_Query__c;
        packageDistribution.MA_DS_Last_Synced_Rules_Criteria_JSON__c = packageDistribution.MA_DS_Rules_Criteria_JSON__c;
        packageDistribution.MA_DS_Manager_Summary_Rules_Sync_Date__c = summaryRequired ? Datetime.now().addDays(-8) : null;

        switch on maDistributionStage {
            when PACKAGE_DELIVERED {
                packageDistribution.MA_DS_Status__c = STATUS_PACKAGE_SENT;
                updatePackageDistributionStage(packageDistribution, DistributionStage.READY_FOR_PACKAGE_DELIVERY, true, true, true, true);
            }
        }

        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    private static void updatePackageDistributionStage(MA_DS_Package_Distribution__c packageDistribution, DistributionStage maDistributionStage, Boolean summaryPrepped, Boolean summarySent, Boolean packagePrepped, Boolean packageSent) {
        packageDistribution.MA_DS_Manager_Summaries_Prep_Date__c = summaryPrepped ? Datetime.now().addDays(-7) : null;
        packageDistribution.MA_DS_Manager_Summaries_Sent_Date__c = summarySent ? Datetime.now().addDays(-5) : null;
        packageDistribution.MA_DS_Package_Prep_Date__c = packagePrepped ? Datetime.now().addDays(-4) : null;
        packageDistribution.MA_DS_Package_Sent_Date__c = packageSent ? Datetime.now().addDays(-2) : null;

        switch on maDistributionStage {
            when READY_FOR_SUMMARY_PREP {
                packageDistribution.MA_DS_Package_Distribution_Stage__c = STAGE_READY_FOR_SUMMARY_PREP;
            }when READY_FOR_SUMMARY_DELIVERY {
                packageDistribution.MA_DS_Package_Distribution_Stage__c = STAGE_READY_FOR_SUMMARY_DELIVERY;
            }when READY_FOR_PACKAGE_PREP {
                packageDistribution.MA_DS_Package_Distribution_Stage__c = STAGE_READY_FOR_PACKAGE_PREP;
            }when READY_FOR_PACKAGE_DELIVERY {
                packageDistribution.MA_DS_Package_Distribution_Stage__c = STAGE_READY_FOR_PACKAGE_DELIVERY;
            }
        }
    }
}