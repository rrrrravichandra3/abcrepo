public class NHW_CW_ContactToCase_MappingContactInfo implements NH_DataMapping_CustomMapping {
    public static List<String> getAdditionalSourceFieldsString(){
        List<String> additionalContactQueryFields = new List<String>{'Name', 'Secondary_Email__c', 'Phone'};
        return additionalContactQueryFields;
    }

    public static void performSourceToTargetCustomMapping(SObject source, SObject target){
        Contact con = (Contact)source;
        Case c = (Case)target;

        String LocalContactInfo;

        LocalContactInfo =  'Name : '+con.Name+'\n';
        LocalContactInfo = LocalContactInfo + 'Email : '+con.Secondary_Email__c+'\n';
        LocalContactInfo = LocalContactInfo + 'Phone : '+con.Phone+'\n'; 

        c.NH_Shipping_Local_Contact_Info__c = LocalContactInfo;
    }
}