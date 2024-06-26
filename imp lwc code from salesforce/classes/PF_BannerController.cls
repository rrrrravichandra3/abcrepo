/*
 * @Author : Kshitiz Srivastava
 * Controller for lightning component PF_Banner
 * Based on parameter appName on the component, it retrieves the corresponding record of custom metadata PF_Banner_mdt
 */
public with sharing class PF_BannerController {
    
    @AuraEnabled
    public static BannerDetails getBannerDetails(String appName){
        PF_Banner__mdt banner = [Select Visible__c,Banner_Message__c from PF_Banner__mdt where  DeveloperName LIKE :appName limit 1];
        if(banner == null){
            return new BannerDetails(false,'');
        }
        return new BannerDetails(banner.Visible__c, banner.Banner_Message__c);
    }
    
    //Custom Data Structure to encapsulate Banner visibility and Message
    public Class BannerDetails{
        @AuraEnabled public Boolean showBanner;
        @AuraEnabled public String bannerMessage;
        
        public BannerDetails(Boolean showBanner, String bannerMessage){
            String plainMessage = bannerMessage.stripHtmlTags();
            if(String.isBlank(plainMessage)){
                this.showBanner = false;
                this.bannerMessage = '';
            }else{
                this.showBanner = showBanner;
                this.bannerMessage = bannerMessage;
            }
        }
    }

}