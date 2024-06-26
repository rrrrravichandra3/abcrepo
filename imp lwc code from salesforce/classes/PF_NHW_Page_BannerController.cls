/*
* @Author : Satyam Kumar
* Controller for lightning component PF_NHW_Page_Banner
* Based on parameter appPageName, componentId on the component, it retrieves the corresponding record of custom metadata PF_Banner_mdt
*/
public with sharing class PF_NHW_Page_BannerController {
    private static String GENERAL_EXCEPTION_MESSAGE = 'Internal System Error';
    
    @AuraEnabled
    public static String getPageBannerDetails(String appPageName, String componentId) {

        PF_NHW_PageBannerSettings__mdt bannerSetting = new PF_NHW_PageBannerSettings__mdt();
        
        Try {
            //To avoid exceptions when there is no record
            for(PF_NHW_PageBannerSettings__mdt bannerSettingTemp : [Select Page_Banner_Aura_Id__c, Page_Name__c, Banner_Message__c
                                                                    From PF_NHW_PageBannerSettings__mdt 
                                                                    Where Page_Banner_Aura_Id__c =: componentId And Page_Name__c =: appPageName]) 
            {
                bannerSetting = bannerSettingTemp;
            }
            
            if(bannerSetting == null || (bannerSetting != null && String.isBlank(bannerSetting.Banner_Message__c))) {
                return 'Configure PF_NHW_PageBannerSettings__mdt correctly';
            }
        } catch(Exception ex){
            system.debug('ex'+ex.getMessage()+ex.getLineNumber());
            throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
        }
        return bannerSetting.Banner_Message__c;
    }
}