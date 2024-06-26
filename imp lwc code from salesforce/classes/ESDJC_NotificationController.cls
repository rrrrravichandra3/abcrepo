/**
* #DreamJobCentral
* @date:        5/7/2013
* @description: Controller for ESDJC_Notification. Show Program and Announcement details.
**/
public with sharing class ESDJC_NotificationController {
    public string url{get;set;}
    public ESDJC_NotificationController(ApexPages.StandardController controller) {
        //Get SSO url
        url=ESDJC_Util.getSSOURL();
    }

}