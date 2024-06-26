/**
 * Test utility class for MA_DS_Test_PackageStageHandlerService.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05/01/2024      Chakshu Malhotra        Adds utility methods for MA_DS_Test_PackageStageHandlerService class.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_PkgStageHandlerService {
    
    private static final String TEST_ENVELOPE_ID = '864818f7-aae7-4e6f-b7a2-d83247fcd80';

    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;

    public static final String PACKAGE_STAGE_ACCEPTED = Label.MA_DS_Package_Stage_Accepted;
    public static final String PACKAGE_STAGE_DECLINED = Label.MA_DS_Package_Stage_Declined;

    public static final Integer MAX_QUERY_LIMIT = MA_DS_PackageStageHandlerWrapper.LIST_AUDIT_EVENTS_CALLOUT_COUNT;

    public static List<Id> getAcquisitionContactIds(Id packageDistributionId, Integer queryLimit) {
        List<AggregateResult> aggAppliedRules = [SELECT MA_DS_Acquisition_Contact__c acqContactId, Count(Id)
                                                 FROM MA_DS_Applied_Rule__c
                                                 WHERE MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                                                 MA_DS_Package_Distribution__c = :packageDistributionId AND
                                                 MA_DS_Acquisition_Contact__r.MA_DS_Package_Stage__c = :MA_DS_TestUtil_Acquisition.PACKAGE_STAGE_DELIVERED
                                                 GROUP BY MA_DS_Acquisition_Contact__c LIMIT :queryLimit];

        List<Id> acqContactIds = new List<Id>();

        for(AggregateResult aggAppliedRule : aggAppliedRules) {
            acqContactIds.add((Id)aggAppliedRule.get('acqContactId'));
        }

        return acqContactIds;
    }

    public static void updatePackageStageForAcquisitionContacts(List<Id> acqContactIds, String packageStage) {
        List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>();

        for(Integer idIndex = 0; idIndex < acqContactIds.size(); idIndex++) {
            Acquisition_Contacts__c acqContact = new Acquisition_Contacts__c(Id = acqContactIds[idIndex]);
            acqContact.MA_DS_Package_Stage__c = packageStage;
            acqContact.MA_DS_Envelope_Id__c = TEST_ENVELOPE_ID + idIndex;
            acqContacts.add(acqContact);
        }

        update acqContacts;
    }

    public static Integer getUpdatedSignerIPAddressCount(List<Id> acqContactIds) {
        return [SELECT Id, MA_DS_Signer_IP_Address__c 
                FROM Acquisition_Contacts__c 
                WHERE Id IN :acqContactIds AND 
                MA_DS_Signer_IP_Address__c != null].size();
    }
}