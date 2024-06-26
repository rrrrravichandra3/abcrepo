/**
* @author Apuroop Gadde
* @date 09-18-2017
* @group Unit Test Classes
* @description Utils class for unit tests for workday - SIFT integration related code
*/
@isTest
public class IFB_WDTestUtils {
    /**
     * @description Util method to setup default custom settings values for SIFT Settings(List) custom setting
    */
    public static void setupSiftSettingsListCS() {
        IFB_SIFT_Settings_List__c siftSettingsList = new IFB_SIFT_Settings_List__c();
        siftSettingsList.Name = 'SIFT';
        siftSettingsList.WDR_Rejected_Offer_Status__c = 'Declined By Candidate';
        siftSettingsList.WDR_Rejected_Candidate_Stages__c = 'Rejected';
        siftSettingsList.WDR_Accepted_Offer_Status__c = 'Pre-Placement,Placement';
        siftSettingsList.Post_Placement_Candidate_Stages__c = 'Placement';
        insert siftSettingsList;
    }
}