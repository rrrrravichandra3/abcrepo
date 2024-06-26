/**
 * ******************************************** W-15492687 : Controller class for Personal Information Update ********************************************
 *
 * This is LWC Controller class for Personal Information Update 
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         22/04/2024      Ashutosh Belwal        W-15492687 - <Career Connect> Employee Profile Design
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class Cc_Emp_PersonalInformationController {
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the current user Employee preference record
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    
    * @return   CcEmp_Preferences__c     DESCRIPTION (return CcEmp_Preferences__c instance)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static CcEmp_Preferences__c getOnloadData(){
        try {
            return [SELECT Id, User__r.Name, User__r.FullPhotoUrl, User__r.FirstName, User__r.LastName, 
                    User__r.Email, User__r.Username, User__r.Title, LinkedIn_Url__c, Personal_Website__c, User__r.AboutMe
                    FROM CcEmp_Preferences__c 
                    WHERE User__c =: UserInfo.getUserId()];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+':User'+UserInfo.getUserId());
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update user profile image
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    imageBase64              DESCRIPTION (Base64 string of image)
    * @return   
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void uploadCroppedImage(String imageBase64) {
        try{
            Blob image = EncodingUtil.base64Decode(imageBase64);
            ConnectApi.UserProfiles.setPhoto(null, UserInfo.getUserId(), new ConnectApi.BinaryInput(image, 'image/jpg', 'userImage.jpg'));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+':User'+UserInfo.getUserId());
        }
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update User and Preference data
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    data              DESCRIPTION (JSON string of user data)
    * @return   
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void updateUserInfo(String data) {
        try{
            Map<String, String> userData = (Map<String,String>) JSON.deserialize(data, Map<String,String>.class);
            update new CcEmp_Preferences__c(
                LinkedIn_Url__c = userData.get('LinkedInUrl'),
                Personal_Website__c = userData.get('PersonalWebsite'),
                User__c = UserInfo.getUserId(),
                Id = userData.get('EmpPrefId')
            );
            
            update new User(
                AboutMe = userData.get('AboutMe'),
                Id = UserInfo.getUserId()
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+':User'+UserInfo.getUserId());
        }
    }
    
}