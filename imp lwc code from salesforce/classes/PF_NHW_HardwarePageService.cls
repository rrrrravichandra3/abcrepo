@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class PF_NHW_HardwarePageService extends PF_NHW_PageService{
    
    protected override List<PF_NHW_LightningComponentConfiguration> getComponentsConfig(){
        
        return PF_NHW_LightningComponentsService.getComponentsConfigForCaseAndPage(provisioningCase, PF_NHW_Page.HARDWARE);
    }
    
    protected override Case getProvisioningCase(){
        Boolean isDeskphoneVisible  = true;
        Boolean isDeskphoneEditable  = true;

        //Default Visible as true -since if attribute doesnt exist in the comp,In the UI it is visible.
        Boolean isDesktopVisible = true;
        Boolean isMobileVisible  = true;
        Boolean isLaptopVisible  = true;
      
        List<PF_NHW_LightningComponentConfiguration> comps = getComponentsConfig();
        //Check if Deskphone is autoprovisioned to default Yes.
        //Get the visibility criteria for All Hrdware comps
        for(PF_NHW_LightningComponentConfiguration comp:comps){
            if(comp.id == 'pf_nhw_hardware_deskphone'){
                for(PF_NHW_LightningComponentAttribute attribute:comp.attributes){
                    if(attribute.name == 'visible' && attribute.value == false){
                        isDeskphoneVisible = false ;                       
                    }
                    if(attribute.name == 'editable' && attribute.value == false){
                        isDeskphoneEditable = false ;                       
                    }
                }
            }
            if(comp.id == 'pf_nhw_hardware_phone'){
                for(PF_NHW_LightningComponentAttribute attribute:comp.attributes){
                    if(attribute.name == 'visible' && attribute.value == false){
                        isMobileVisible = false ;                       
                    }
                }
            }
            if(comp.id == 'pf_nhw_hardware_desktop_type'){
                for(PF_NHW_LightningComponentAttribute attribute:comp.attributes){
                    if(attribute.name == 'visible' && attribute.value == false){
                        isDesktopVisible = false ;                       
                    }
                }
            }
            if(comp.id == 'pf_nhw_hardware_laptop_type'){
                for(PF_NHW_LightningComponentAttribute attribute:comp.attributes){
                    if(attribute.name == 'visible' && attribute.value == false){
                        isLaptopVisible = false ;                       
                    }
                }
            }
        }
        

        //If the toggle had happened above then set case value to Yes.       
        if(isDeskphoneVisible == true && isDeskphoneEditable == false){
            provisioningCase.Desk_and_VoiceMail__c = 'Yes';
        }
        
        //Reset Clone defaults if option has changed on page 1 re-rendering the element visibility.
        if(isDeskphoneVisible == false){
            provisioningCase.Desk_and_VoiceMail__c = 'No';        
        }
        if(isMobileVisible == false){
            provisioningCase.Mobile_Phone_Required__c = 'No';        
        }
        if(isDesktopVisible == false){
            provisioningCase.Computer_Type__c = null;        
        }
        if(isLaptopVisible == false){ 
            provisioningCase.Laptop_Type__c= null;        
        }
        
        return provisioningCase;
    }
    public override void resetFieldsOnPageSkip(Case ProvisioningCase){ 
        provisioningCase.NH_Shipping_Local_Contact_Info__c = null;
        provisioningCase.Shipping_City__c = null;
        provisioningCase.Shipping_Address__c = null;
        provisioningCase.Shipping_Zip_Postal__c = null;
        provisioningCase.Shipping_State__c = null;
        provisioningCase.Shipping_Country__c = null;
        provisioningCase.NH_Shipping_Business_Site__c = null;
        provisioningCase.Computer_Type__c = null;
        provisioningCase.Laptop_Type__c= null;
        provisioningCase.Same_as_Office_Location__c = false; 
        provisioningCase.Mobile_Phone_Required__c = 'No';
        provisioningCase.Desk_and_VoiceMail__c = 'No';
        provisioningCase.Floor_Location_Cube_Location__c='';
        if(Case.sObjectType.getDescribe().isUpdateable()){
            try {
              Database.update(provisioningCase, false);
            }  catch (DmlException ex) { 
              system.debug('The following exception has occurred: ' + 
                          ex.getDmlStatusCode(0) + ex.getMessage());
            }
          }
    }
    public override String processPageInformation(){
        try{
            provisioningCase.NH_Shipping_Business_Site__r = null;
            String LocalContactInfo;
            if(this.additionalInformation != null){
                if(this.additionalInformation.containsKey('LOCALCONTACTNAME')){
                    LocalContactInfo =  'Name : '+this.additionalInformation.get('LOCALCONTACTNAME')+'\n';
                }
                if(this.additionalInformation.containsKey('LOCALCONTACTEMAIL')){
                    LocalContactInfo = LocalContactInfo + 'Email : '+this.additionalInformation.get('LOCALCONTACTEMAIL')+'\n';     
                }
                if(this.additionalInformation.containsKey('LOCALCONTACTPHONE')){
                    LocalContactInfo = LocalContactInfo + 'Phone : '+this.additionalInformation.get('LOCALCONTACTPHONE')+'\n';                   
                }
                   
               provisioningCase.NH_Shipping_Local_Contact_Info__c = LocalContactInfo;
  
             }
            else{
              provisioningCase.NH_Shipping_Local_Contact_Info__c = null;
         
            }
                   
                   
                   //if all hardware selections are no -
                   // * - Reset Shipping address  
                   // * -  -We are not doing reset in UI - As we decided to give option for user to change his without losing his UI edits when he toggles between Y/N
                   // * - Set Existing Equipment to true
                   if((String.isBlank(provisioningCase.Laptop_Type__c) || provisioningCase.Laptop_Type__c =='Not Required' 
                       || provisioningCase.Laptop_Type__c =='None')
                      && (String.isBlank(provisioningCase.Computer_Type__c) ||provisioningCase.Computer_Type__c =='Not Required'
                          || provisioningCase.Computer_Type__c == 'None')
                      && ( String.isBlank(provisioningCase.Mobile_Phone_Required__c)  || provisioningCase.Mobile_Phone_Required__c == 'No')
                      &&  (String.isBlank(provisioningCase.Desk_and_VoiceMail__c) || provisioningCase.Desk_and_VoiceMail__c == 'No')
                     ){
                         provisioningCase.NH_Shipping_Local_Contact_Info__c = null;
                         provisioningCase.Shipping_City__c = null;
                         provisioningCase.Shipping_Address__c = null;
                         provisioningCase.Shipping_Zip_Postal__c = null;
                         provisioningCase.Shipping_State__c = null;
                         provisioningCase.Shipping_Country__c = null;
                         provisioningCase.NH_Shipping_Business_Site__c = null;
                         
                         provisioningCase.Existing_Equipment__c = true;
                         
                     }else{
                         provisioningCase.Existing_Equipment__c = false;
                         
                     }
                   if(provisioningCase.NH_Business_Site__c == provisioningCase.NH_Shipping_Business_Site__c ){
                       provisioningCase.Same_as_Office_Location__c = true;
                   }else{
                       provisioningCase.Same_as_Office_Location__c = false;            
                   }
                   system.debug('case '+provisioningCase);
                   
                   }catch(Exception e){
                       throw new AuraHandledException(e.getMessage());
                   }
                   return provisioningCase.Id;
                   }
                   
                   public override List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process){
                       
                       List<ReviewItem> reviewList = new List<ReviewItem>();
                       Onboarding_Setting__c onboardingSetting = Onboarding_Setting__c.getInstance();
                       reviewList.add(new ReviewItem('Laptop Type', String.isBlank(provisioningCase.Laptop_Type__c) ? 'Not needed' : provisioningCase.Laptop_Type__c));
                       reviewList.add(new ReviewItem('Desktop Type', String.isBlank(provisioningCase.Computer_Type__c) ? 'Not needed' : provisioningCase.Computer_Type__c));
                       if(!String.isBlank(provisioningCase.Mobile_Phone_Required__c)){
                           reviewList.add(new ReviewItem('Will They Need a Mobile Phone?',provisioningCase.Mobile_Phone_Required__c));         
                       }
                       if(!String.isBlank(provisioningCase.Desk_and_VoiceMail__c)){
                           reviewList.add(new ReviewItem('Will They Need a Desk Phone?',provisioningCase.Desk_and_VoiceMail__c));          
                       }     
                       
                       
                       
                       if(!String.isBlank(provisioningCase.NH_Shipping_Local_Contact_Info__c)){
                           reviewList.add(new ReviewItem('Local Contact Info', provisioningCase.NH_Shipping_Local_Contact_Info__c));
                       }                       
                       
                       if(!String.isBlank(provisioningCase.Shipping_Address__c)){
                           reviewList.add(new ReviewItem('Address', provisioningCase.Shipping_Address__c));
                       }
                       
                       if(!String.isBlank(provisioningCase.Shipping_City__c)){
                           reviewList.add(new ReviewItem('City', provisioningCase.Shipping_City__c));
                       }
                       
                       if(!String.isBlank(provisioningCase.Shipping_State__c)){
                           reviewList.add(new ReviewItem('State', provisioningCase.Shipping_State__c));
                       }
                       
                       if(!String.isBlank(provisioningCase.Shipping_Country__c)){
                           reviewList.add(new ReviewItem('Country', provisioningCase.Shipping_Country__c));
                       }
                       
                       if(!String.isBlank(provisioningCase.Shipping_Zip_Postal__c)){
                           reviewList.add(new ReviewItem('Zip Code', provisioningCase.Shipping_Zip_Postal__c));
                       }
                       
                       //Floor and Desk or Cubby number
                       if(!String.isBlank(provisioningCase.Floor_Location_Cube_Location__c)){
                           reviewList.add(new ReviewItem('Floor and Desk or Cubby number', provisioningCase.Floor_Location_Cube_Location__c));
                       }
                       
                      
                       
                       return reviewList;
                   }
                   }