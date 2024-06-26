/*This controller designates appropriate fieldset name to email Template 
 * based on form type and user location.
 */
public with sharing class ESDJC_Webforms_EmailPDF_CompCtrller {
    public string compFieldSetName{get;set;}
    public string compObjectName{get;set;}
    public string compRecordId{get;set;}
    public string compfilename{get;set;}
    
    
    public ESDJC_Webforms_EmailPDF_CompCtrller(){
        User thisUser = [select contactid, contact.Division__c, contact.ES_DJC_Work_Location__c, contact.ES_DJC_Contact_Country__c,
                            contact.DJC_Contact_Floor__c,contact.DJC_Contact_Building__c, contact.DJC_Contact_Cube_Workstation__c, Contact.Name, Contact.recordType.name,
                            Contact.Email, Contact.Phone
                            from user where id = :UserInfo.getUserId()];  
        
        system.debug('thisUser'+thisUser);
        
        //Fieldset for attachment content is determined by user(requester)  location details.
        if(thisUser.contact != null){
            if ((thisUser.contact.Division__c).containsIgnoreCase('Americas - USA')){
                if (thisUser.contact.ES_DJC_Work_Location__c !=null){
                    if ((thisUser.contact.ES_DJC_Work_Location__c.containsIgnoreCase('San Francisco')) || 
                        (thisUser.contact.ES_DJC_Work_Location__c.containsIgnoreCase('San Mateo'))){
                            compFieldSetName  = 'ESDJC_Webform_OnsiteEvent_HQ';
                    }else{                                                          
                            compFieldSetName = 'ESDJC_Webform_OnsiteEvent_NonHQ';
                    }                                               
                }
                else{
                  compFieldSetName = 'ESDJC_Webform_OnsiteEvent_NonHQ';                       
                }
            }
            else{
                compFieldSetName = 'ESDJC_Webform_OnsiteEvent_NonHQ';         
            }
        }
        else{
           compFieldSetName = 'ESDJC_Webform_OnsiteEvent_HQ';  //Employee record                               
        }
	}
    
}