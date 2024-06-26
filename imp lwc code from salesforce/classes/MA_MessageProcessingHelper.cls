/**
 * ****** MA Messaging Framework *******
 * Helper class for Messaging Framework.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         19/02/2022      Chakshu Malhotra        Holds utility methods to process email messages & custom notifications.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_MessageProcessingHelper {

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get messaging configuration metadata type base on configuration type.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_Messaging_Configuration__mdt  DESCRIPTION (return MA_Messaging_Configuration__mdt)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_Messaging_Configuration__mdt getMessagingConfigMetadata(String configType) {
        return [SELECT Id, Email_Template__c, OWD_Email_Address__c, Email_Threshold__c, Notification_Type__c, Notification_Threshold__c, Notification_Target_Page_Ref__c 
                FROM MA_Messaging_Configuration__mdt 
                WHERE DeveloperName = :configType LIMIT 1];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch email template id for a given email template name.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    emailTemplate 	   	    DESCRIPTION (Data type String, Email template name.)
    * @return   Id                      DESCRIPTION (return Id of email template)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Id getEmailTemplateId(String emailTemplate) {
        return [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplate LIMIT 1]?.Id;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch Org Wide Email Address Record Id for a given OWD Email Address.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    owdEmailAddress 	    DESCRIPTION (Data type String, OWD Email Address for email messaging.)
    * @return   Id                      DESCRIPTION (return Record Id of OWD Email Address)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Id getOrgWideEmailAddressId(String owdEmailAddress) {
        return [SELECT Id FROM OrgWideEmailAddress WHERE Address = :owdEmailAddress LIMIT 1]?.Id;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch notification type id for a given notification type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    notificationType 	   	DESCRIPTION (Data type String, Notification name.)
    * @return   Id                      DESCRIPTION (return Id of notification type)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Id getNotificationTypeId(String notificationType) {
        return [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :notificationType LIMIT 1]?.Id;
    }
}