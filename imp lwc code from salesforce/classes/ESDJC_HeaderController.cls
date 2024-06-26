public without sharing class ESDJC_HeaderController{

    public String imageHeader{get;set;}

    public string getStartURL(){
        return ESDJC_Util.getSSOURL();
    }

    public ESDJC_HeaderController(){
        imageHeader = getImageHeader(); 
    }
    
    public String getConciergeUrl(){
        ESDJC_Settings__c setting = ESDJC_Settings__c.getInstance();
        return setting.Concierge_URL__c;
    }

    public String getImageHeader(){
        Map<String,ES_DJC_Image__c> imageMap = ES_DJC_Image__c.getAll();
        User currentUser = [select ContactId,contact.ES_DJC_Contact_Country__c,contact.division__c,contact.ES_DJC_Portal_User_Language__c,contact.RecordTypeId,Name,Email,Phone,Division from User where id =: UserInfo.getUserId()];
        RecordType contractorRecType = [Select Id From RecordType  Where SobjectType = 'Contact' and DeveloperName = 'Contractor'];
        
        if ((currentUser.contact.RecordTypeId == contractorRecType.Id) || (currentUser.contact.division__c == 'Japan' && currentUser.contact.ES_DJC_Portal_User_Language__c == 'en_US') ||
            (currentUser.contact.division__c == 'APAC - All Countries')){
            // return concierge banner with no contact numbers
            if (imageMap.get('DJC_Banner_Concierge_Desktop') != null){
                return imageMap.get('DJC_Banner_Concierge_Desktop').Image_Url__c;
            }
        } 
        // if the user is in japan and selected japanese as their language, show the japanese banner
        else if (currentUser.contact.division__c == 'Japan' && currentUser.contact.ES_DJC_Portal_User_Language__c == 'ja') {
            if (imageMap.get('DJC_Banner_Concierge_Japan') != null) {
                return imageMap.get('DJC_Banner_Concierge_Japan').Image_Url__c; 
            }
        }
        else if (currentUser.contact.ES_DJC_Contact_Country__c != null && imageMap != null) {
            List<ESDJC_Country__c> countryContent = [select id, ES_DJC_Header_Image__c from ESDJC_Country__c where name =:currentUser.contact.ES_DJC_Contact_Country__c];
            if (countryContent != null && countryContent.size() > 0 && countryContent[0].ES_DJC_Header_Image__c != null) {
                if (imageMap.get(countryContent[0].ES_DJC_Header_Image__c) != null)
                    return imageMap.get(countryContent[0].ES_DJC_Header_Image__c).Image_Url__c; 
            }
        }

       if(imageMap.get('DJC_Banner_w_numbers_Concierge_Desktop') != null) {
           return imageMap.get('DJC_Banner_w_numbers_Concierge_Desktop').Image_Url__c; 
       }

       return null;
    }
}