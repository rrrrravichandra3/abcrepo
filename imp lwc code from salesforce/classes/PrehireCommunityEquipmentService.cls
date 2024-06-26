public with sharing class PrehireCommunityEquipmentService {


    
   @AuraEnabled
    public static Map<String,Object> getShippingBUAddress(Id caseId) {
        system.debug(caseId);
        Case provCase = [select id,NH_Business_Site__c from case where id =: caseId];
        return PF_NHW_HardwareAuraServices.getBSRelatedFieldsInfo(provCase.NH_Business_Site__c,caseId);
    }
    
    @AuraEnabled
    public static void updateEquipmentSelections(EquipmentWrapper wrapper,Id caseId) {
        Case provCase = [select Id,Shipping_City__c, Shipping_Address__c, Shipping_State__c,Shipping_Country__c, Shipping_Zip_Postal__c ,NH_Shipping_Local_Contact_Info__c,Laptop_Type__c ,
                         Mobile_Phone_Required__c ,NH_Mobile_Phone_Type__c from  Case where id=:caseId];
        
        System.debug(wrapper);
        System.debug(provCase);
        if(wrapper!=null && provCase!=null) {
            provCase.Shipping_City__c = wrapper.shippingCity;
            provCase.Shipping_Country__c = wrapper.shippingCountry;
            provCase.Shipping_Address__c = wrapper.shippingStreet;
            provCase.Shipping_State__c = wrapper.shippingState;
            provCase.Shipping_Zip_Postal__c = wrapper.shippingZipCode;
            String localContactInfo = 'Name: '+wrapper.shippingName +'\n' + 'Email: '+ wrapper.shippingEmail + '\n' + 'Phone: '+wrapper.shippingPhone;
            provCase.NH_Shipping_Local_Contact_Info__c = localContactInfo;
            provCase.Laptop_Type__c = wrapper.selectedLaptop;
            provCase.Mobile_Phone_Required__c = 'Yes';
            provCase.NH_Mobile_Phone_Type__c = wrapper.selectedMobile;
        }
        
        update provCase;
    }
    @AuraEnabled
    public static void updateSoftwareSelections(string accessibilityReq ,string swSelection, Id caseId){
        try {
            Case provitioningCase = [select Id,Is_Accessibility_required__c,NH_Accessibility_Softwares__c from  Case where id=:caseId];
            System.debug(swSelection);
            System.debug(provitioningCase);
            
            if(provitioningCase!=null && accessibilityReq != null){
                provitioningCase.Is_Accessibility_required__c = accessibilityReq;
                if(swSelection!=null){
                    provitioningCase.NH_Accessibility_Softwares__c = swSelection;
                }
            }
            update provitioningCase;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     public class EquipmentWrapper {
        @AuraEnabled
        public String shippingCity { get; set; }
        @AuraEnabled
        public String shippingStreet { get; set; }
        @AuraEnabled
        public String shippingState { get; set; }
        @AuraEnabled
        public String shippingCountry { get; set; }
        @AuraEnabled
        public String shippingZipCode { get; set; }
        @AuraEnabled
        public String shippingName { get; set; }
        @AuraEnabled
        public String shippingEmail { get; set; }
        @AuraEnabled
        public String shippingPhone { get; set; }
        @AuraEnabled
        public String selectedLaptop { get; set; }
        @AuraEnabled
        public String selectedMobile { get; set; }
        
    }
    
    
}