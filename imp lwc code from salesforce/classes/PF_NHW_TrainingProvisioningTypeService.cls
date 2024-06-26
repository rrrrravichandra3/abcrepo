@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class PF_NHW_TrainingProvisioningTypeService extends PF_NHW_ProvisioningTypeService{
    map<String, list<NHW_Org62Service.CampaignResult>> mTypeToCampaigns = new map<String, list<NHW_Org62Service.CampaignResult>>();
    public map<String, NHW_Org62Service.CampaignResult> mIdToCampaigns = new map<String, NHW_Org62Service.CampaignResult>();
    map<string,string> mSelectedCampaigns = new map<string,string>();
    
    public map<String, NHW_Org62Service.CampaignMemberResult> mCampaignIdToCampaignMemberResult = new map<String, NHW_Org62Service.CampaignMemberResult>();
    public string org62Contact='';
    
    set<id> enrolledCampaignSet = new set<id>();
    
    public override List<Object> getProvisionings(){ 
        
        List<NHW_Provisioning__c> TrainingProvisionings = getNHWProvisionings();
        List<TrainingProvisioning> result = new List<TrainingProvisioning>();
        //GetCampaigns - provisioningCase
        populateCampaignInfo();
        populatePastSelectionFromCase();
        
        system.debug('mSelectedCampaigns'+mSelectedCampaigns);
        
        if(TrainingProvisionings != null){
            for(NHW_Provisioning__c provisioning:TrainingProvisionings){
                String campaigntype = provisioning.name;
                List<TrainingOptions> Availableoptions = new list<TrainingOptions>();
                String SelectedValue;
                Boolean isEnrolled = false;
                String org62ContactId ='';
                Boolean showRemoteOptions = !String.isBlank(provisioning.Show_Remote_Options__c);
                Set<String> remoteLocations = getRemoteLocationNames(provisioning.Show_Remote_Options__c);
                Boolean atleastOneRemoteOptionExists = false;
                List<NHW_Org62Service.CampaignResult> campaignsBeyondUpperCutOff = new List<NHW_Org62Service.CampaignResult>();
                if(mTypeToCampaigns.containsKey(provisioning.name)){
                    
                    
                    for(NHW_Org62Service.CampaignResult sp: mTypeToCampaigns.get(provisioning.name)){
                        //Apply training cutoff
                        if((provisioning.Lower_Cutoff__c != null)&&(sp.campaignStartDate < provisioningcase.NHW_Start_Date__c.addDays(provisioning.Lower_Cutoff__c.intValue()))){
                                continue; //Skip this training  as it is before lower cutoff.
                        } 
                        if((provisioning.Upper_Cutoff__c != null)&&(sp.campaignStartDate > provisioningcase.NHW_Start_Date__c.addDays(provisioning.Upper_Cutoff__c.intValue()))){
                                campaignsBeyondUpperCutOff.add(sp);
                                continue; //Skip this training  as it is after upper cutoff.
                        }
                        Datetime dt = datetime.newInstance(sp.campaignstartDate.year(), sp.campaignstartDate.month(),sp.campaignstartDate.day());
                        String Label = Datetime.valueof(dt).format('MMM dd, yyyy') + ' - ' +sp.Location;
                        Availableoptions.add(new TrainingOptions(Label,sp.campaignId));
                        if((!String.isBlank(sp.Location)) && remoteLocations.contains((sp.Location).toLowerCase())){
                            atleastOneRemoteOptionExists = true;
                        }
                        if(enrolledCampaignSet.contains(sp.campaignId)){
                            isEnrolled = true; 
                            SelectedValue= sp.campaignId; 
                            //Populate org62 contact info for trainings which are already enrolled.This would skip campaign member creation on submit.
                            org62ContactId= org62Contact;
                        }
                    }
                    if(mSelectedCampaigns.containskey(campaigntype)){
                        NHW_Org62Service.CampaignResult sp = mIdToCampaigns.get(mSelectedCampaigns.get(campaigntype));
                        if(sp!= null){
                            SelectedValue= sp.campaignId;                       
                        }                    
                    }
                    //explore campaigns beyond cut off date to find a trailhead option
                    if((showRemoteOptions==true) && (atleastOneRemoteOptionExists==false)){
                        for(NHW_Org62Service.CampaignResult sp:campaignsBeyondUpperCutOff){
                            if((!String.isBlank(sp.Location)) && remoteLocations.contains((sp.Location).toLowerCase())){
                                Datetime dt = datetime.newInstance(sp.campaignstartDate.year(), sp.campaignstartDate.month(),sp.campaignstartDate.day());
                                String Label = Datetime.valueof(dt).format('MMM dd, yyyy') + ' - ' +sp.Location;
                                Availableoptions.add(new TrainingOptions(Label,sp.campaignId));
                                if(enrolledCampaignSet.contains(sp.campaignId)){
                                    isEnrolled = true; 
                                    SelectedValue= sp.campaignId; 
                                    //Populate org62 contact info for trainings which are already enrolled.This would skip campaign member creation on submit.
                                    org62ContactId= org62Contact;
                                }
                                break;
                            }
                        } 
                    }
                    
                }
                
                result.add(new TrainingProvisioning(Availableoptions,provisioning.Name,isEnrolled,SelectedValue,provisioning.Required__c,provisioning.Display_Name__c,org62ContactId, getTrainingMetadata(provisioning) ));
                
            }
        }
        system.debug('result'+result);
        result.sort();
        system.debug('result after sort'+result);

        return result;
    }

    public PF_NHW_TrainingProvisioningTypeService.TrainingMetadata getTrainingMetadata(NHW_Provisioning__c provRec){
        if(provRec.Metadata__c!= null){
            PF_NHW_TrainingProvisioningTypeService.TrainingMetadata Metadata = (PF_NHW_TrainingProvisioningTypeService.TrainingMetadata)JSON.deserialize(provRec.Metadata__c, PF_NHW_TrainingProvisioningTypeService.TrainingMetadata.class);
            System.debug(LOGGINGLEVEL.info,'Metadata - '+Metadata);
            return Metadata;            
        }else{
            return null;
        }
    }

    

    public void populateCampaignInfo(){
        mTypeToCampaigns = new map<String, list<NHW_Org62Service.CampaignResult>>();
        mIdToCampaigns = new map<String, NHW_Org62Service.CampaignResult>();
        NHW_Org62Service.Org62Data o6d = NHW_Org62Service.getCampaignResults(provisioningcase.Email_Address__c, provisioningcase.First_Name__c + ' ' + provisioningcase.Last_Name__c);
        if (o6d != null) {
            if (o6d.campaignList != null && !o6d.campaignList.isEmpty()) {
                for (NHW_Org62Service.CampaignResult sp : o6d.campaignList) {
                    system.debug(sp.campaignType);
                    system.debug(sp.campaignName);
                    if(mTypeToCampaigns.containsKey(sp.campaignType)){
                        mTypeToCampaigns.get(sp.campaignType).add(sp);                      
                    }else{
                        mTypeToCampaigns.put(sp.campaignType, new list<NHW_Org62Service.CampaignResult>{sp});                     
                    }
                    mIdToCampaigns.put(sp.campaignId,sp);
                    
                }
            }
            
            org62Contact = o6d.contactId;
            if (o6d.campaignMemberList != null && !o6d.campaignMemberList.isEmpty()) {
                for (NHW_Org62Service.CampaignMemberResult sp : 
                     o6d.campaignMemberList) {
                         if (sp.contactId == org62Contact) {
                             enrolledCampaignSet.add(sp.campaignId);
                             mCampaignIdToCampaignMemberResult.put(sp.campaignId, sp);
                         }
                     }
            }
        }
    }
    
    public void populatePastSelectionFromCase(){
        if(provisioningcase.NHW_Training__c != null){
            List<PF_NHW_TrainingsPageService.SelectedTraining> selectedtrainings = (List<PF_NHW_TrainingsPageService.SelectedTraining>)json.deserialize(provisioningcase.NHW_Training__c, List<PF_NHW_TrainingsPageService.SelectedTraining>.class);
            for(PF_NHW_TrainingsPageService.SelectedTraining SelectedTraining:SelectedTrainings){
                mSelectedCampaigns.put(SelectedTraining.TrainingType,SelectedTraining.CampaignId);                  
            }           
        }
    }
    public override Set<String> getDependencies(){
        return getProvisioningsDependencies();
    }
    //read locations from semicolon separated string. Handle possible human errors like spaces, extra semicolon etc
    public Set<String> getRemoteLocationNames(String locationNames){
        if(String.isBlank(locationNames)){
            return new Set<String>();
        }
        Set<String> remoteLocationNamesSet = new Set<String>();
        List<String> remoteLocationNamesList = locationNames.split(';');
        for(String currentLocation : remoteLocationNamesList){
            String trimmedCurrentLocation = currentLocation.trim();
            if(!String.isBlank(trimmedCurrentLocation)){
                remoteLocationNamesSet.add(trimmedCurrentLocation.toLowerCase());
            }
        }
        return remoteLocationNamesSet;
    }

    public class TrainingOptions{
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
        public TrainingOptions(String label,String value){
            this.label=label;
            this.value=value;
        }
    }
    public class TrainingProvisioning implements comparable{
        
        @AuraEnabled
        public list<PF_NHW_TrainingProvisioningTypeService.TrainingOptions> AllTrainingOptions{get; private set;}
        @AuraEnabled
        public String TrainingType{get; private set;}   
        @AuraEnabled
        public String TrainingTypeDisplayName{get; private set;}  
        @AuraEnabled
        public Boolean isEnrolled{get; private set;} 
        @AuraEnabled
        public String SelectedValue{get; set;}
        @AuraEnabled
        public boolean isRequired{get; set;}
        @AuraEnabled
        public string org62ContactId{get; set;}
        @AuraEnabled
        public Integer sortOrder{get;set;}
        @AuraEnabled
        public String helpText{get;set;}
        @AuraEnabled
        public String helpTextURL{get;set;}

        public TrainingProvisioning(List<PF_NHW_TrainingProvisioningTypeService.TrainingOptions> TrainingOptions, String TrainingType,Boolean isEnrolled,
                                    string SelectedValue,Boolean isRequired,String TrainingDisplayName,string org62ContactId, PF_NHW_TrainingProvisioningTypeService.TrainingMetadata Metadata){
                                        this.AllTrainingOptions = TrainingOptions;
                                        this.TrainingType = TrainingType;
                                        this.isEnrolled = isEnrolled;
                                        this.SelectedValue=SelectedValue;
                                        this.isRequired = isRequired;
                                        this.TrainingTypeDisplayName = TrainingDisplayName;
                                        this.org62ContactId=org62ContactId;
                                        this.sortOrder = getSortOrder(Metadata);
                                        this.helpText = getHelpText(Metadata);
                                        this.helpTextURL = getHelpTextURL(Metadata);
                                    }

        public Integer compareTo(Object compareTo){
            
            TrainingProvisioning tp = (TrainingProvisioning)compareTo;
            if(this.sortOrder < tp.sortOrder){
                return -1;
            }
            else if(this.sortOrder > tp.sortOrder){
                return 1;
            }
            return 0; 
                
        }

        public Integer getSortOrder(PF_NHW_TrainingProvisioningTypeService.TrainingMetadata Metadata){
            if((Metadata == null) || (Metadata.sortOrder == null)) {return 0;}
            else{return Metadata.sortOrder;}
        }

        public String getHelpText(PF_NHW_TrainingProvisioningTypeService.TrainingMetadata Metadata){
            if((Metadata == null) || (Metadata.helpText == null)) {return null;}
            else{return Metadata.helpText;}
        }

        public String getHelpTextURL(PF_NHW_TrainingProvisioningTypeService.TrainingMetadata Metadata){
            if((Metadata == null) || (Metadata.helpTextURL == null)) {return null;}
            else{return Metadata.helpTextURL;}
        }
    }

    public class TrainingMetadata{
        public Integer sortOrder;
        public String helpText;
        public String helpTextURL;
    }
    
    
}