@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public without sharing virtual class PF_NHW_ReviewService extends PF_NHW_PageService{
        
    private final String NO_USER_NEEDED =  'No User Needed';

    protected override List<PF_NHW_LightningComponentConfiguration> getComponentsConfig(){
        return PF_NHW_LightningComponentsService.getComponentsConfigForCaseAndPage(provisioningCase, PF_NHW_Page.REVIEW);
    }

    protected virtual override Map<String, Object> getPageConfig(){
        
        List<ReviewItemGroup> config = new List<ReviewItemGroup>();
        PF_NHW_Process process = PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c);
        
        if(process != null){
            
            provisioningCase.NHW_Page_Number__c = 0;
            provisioningCase.NHW_Page_Number__c = PF_NHW_Process.getNextStep(provisioningCase);
            
            while(provisioningCase.NHW_Page_Number__c <= process.steps.size()){
                PF_NHW_Page page = process.steps[(Integer)provisioningCase.NHW_Page_Number__c - 1];
                if(page.reviewInfo.includedInReview){
                    PF_NHW_PageService service = page.createService();
                    config.add(new ReviewItemGroup(page.reviewInfo.title, page.reviewInfo.icon, service.getReviewList(provisioningCase, process)));
                }
                provisioningCase.NHW_Page_Number__c = PF_NHW_Process.getNextStep(provisioningCase);
            }
        }
        
        return new Map<String, Object>{'REVIEW_ITEMS' => config};
    }
    
    public virtual override String processPageInformation(){
        
        formerCase.Agreement_Received__c = this.provisioningCase.Agreement_Received__c;
        this.provisioningCase = formerCase;
        
        PF_NHW_Process process = PF_NHW_Process.getProcessByName(provisioningCase.NHW_Employee_Type__c);
        
        if (String.isBlank(provisioningCase.Floor_Location_Cube_Location__c)) {
            provisioningCase.Floor_Location_Cube_Location__c = 'TBD';
        }
        //Set Laptop type/ to empty if none selected - as supportforce NHWCase triggers explicitly check for nulls to not spawn case.
        //TODO: Revisit this as part of VPN Access deprecation.
        if(provisioningCase.Laptop_Type__c == 'None'){
            provisioningCase.Laptop_Type__c = '';
        }
        if(String.isBlank(provisioningCase.Computer_Type__c)){
            provisioningCase.Computer_Type__c = 'Not Required';
        }
        provisioningCase.Status = 'Sent to Supportforce';
        provisioningCase.Origin = 'NHW';
        provisioningCase.Created_with_NHW_2_0__c = true;
        provisioningCase.NHW_Submitter__c = UserInfo.getUserEmail();

        calculateAccessCode();

        if (process == PF_NHW_Process.FTE) {
            provisioningCase.HR_Approved__c = true;
            provisioningCase.NHW_Employee_Type__c = 'Regular Employee';//Supportforce processes check for this literal to set purchasingApproved checkbox      
            provisioningCase.Internal_Support_Category__c = 'New Hire Onboarding Request - Employee';
            createCampaignMember();
        }else{
            provisioningCase.Internal_Support_Category__c = 'New Hire Onboarding Request - Contractor';
        }
         if(process == PF_NHW_Process.CONTRACTOR){
            provisioningCase.NHW_Employee_Type__c = 'Contractor';
        }
        if(process == PF_NHW_Process.RELOCATION){
            provisioningCase.NHW_Employee_Type__c = 'Relocation';
        }
        
        
        return null;
    }
    
    private void createCampaignMember() {
        
            //Enrolled - should have org62contact id
            //If org62contactid is null - then not enrolled
            //If available for any - then we good.
            List<String> selectedCampaignIds = new List<String>();      
            String org62ContactId;        
            if(provisioningcase.NHW_Training__c != null){
                List<PF_NHW_TrainingsPageService.SelectedTraining> selectedtrainings = (List<PF_NHW_TrainingsPageService.SelectedTraining>)json.deserialize(provisioningcase.NHW_Training__c, List<PF_NHW_TrainingsPageService.SelectedTraining>.class);
                system.debug(LoggingLevel.INFO,selectedtrainings);
                for(PF_NHW_TrainingsPageService.SelectedTraining SelectedTraining:SelectedTrainings){
                    if(!String.isBlank(SelectedTraining.org62ContactId)){
                        org62ContactId=SelectedTraining.org62ContactId;
                    }
                    if(!SelectedTraining.isEnrolled){
                        selectedCampaignIds.add(SelectedTraining.campaignId);
                    }
                }           
            }

            if(String.isBlank(org62ContactId)){//If blank we need to create org62 contact and then create campaign member.
                    
                    String officeAddress,officeCity,officeState,officeZip,officeCountry;

                    TF2_Company__c comp = [Select Id, Name From TF2_Company__c Where Id =: provisioningCase.Company__c];
                    String companyNameOrg62String = comp.Name;      
                    String trailGuideContactId = '';
                    if(provisioningCase.Onboarding_Buddy_Email__c != null){
                        List<Contact> org62Contacts = NHW_Org62Service.org62Contacts(provisioningCase.Onboarding_Buddy_Email__c);
                        //Above NHW_Org62Service.org62Contacts returns null when  the status code !=200.
                        if(org62Contacts != null && !org62Contacts.isEmpty()){
                            trailGuideContactId = org62Contacts[0].Id;
                        }else{
                            //PF_Logger.log('NHW','WARNING','Org62 query for Employee contact with Email ' +provisioningCase.Onboarding_Buddy_Email__c+' returned no contacts.', 'Trail Guide Query', 'Org62 query for Employee contact with Email ' +provisioningCase.Onboarding_Buddy_Email__c+' returned no contacts. Queried contact for salesforce.com account', 'NewHireWizardController', provisioningCase.First_Name__c + ' '+provisioningCase.Last_Name__c);
                            //PF_Logger.createLogs(PF_Logger.logs);
                            EventBus.publish(
                            new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'Warning',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = 'Warning',
                                Stack_Trace__c = 'PF_NHW_ReviewServicer',
                                Message__c = 'Org62 query for Employee contact with Email ' +provisioningCase.Onboarding_Buddy_Email__c+' returned no contacts.',
                                Error__c = 'Org62 query for Employee contact with Email ' +provisioningCase.Onboarding_Buddy_Email__c+' returned no contacts. Queried contact for salesforce.com account'
                                )
                        );
                        }
                    }

                    if(provisioningCase.Office_Address__c != NULL){

                        officeAddress = provisioningCase.Office_Address__c;

                    }

                    if(provisioningCase.Office_City__c != NULL){

                        officeCity = provisioningCase.Office_City__c;

                    }

                    if(provisioningCase.Office_State_Province__c != NULL){

                        officeState = provisioningCase.Office_State_Province__c;

                    }

                    if(provisioningCase.Office_Zip_Postal_Code__c != NULL){

                        officeZip = provisioningCase.Office_Zip_Postal_Code__c;

                    }
                    
                    if(provisioningCase.Office_Country__c != NULL){

                        officeCountry = NHW_Util.getCountryISOCode(provisioningCase.Office_Country__c);

                    } 

                    org62ContactId = provisioningCase.First_Name__c + ';' + 
                    provisioningCase.Last_Name__c + ';' +
                    provisioningCase.Email_address__c + ';' +
                    provisioningCase.Manager_s_Email__c + ';' +
                    provisioningCase.NHW_Start_Date__c + ';' +
                    provisioningCase.NHW_Role__c + ';' +
                    provisioningCase.Business_Title__c + ';' +
                    companyNameOrg62String + ';' + provisioningCase.Business_Unit_NHW__c + ';' +
                    provisioningCase.NH_Is_Exact_Target__c+';'+
                    trailGuideContactId +';'+
                    officeAddress +';'+
                    officeCity +';'+
                    officeState +';'+
                    officeZip +';'+
                    officeCountry;  

            }
            if(selectedCampaignIds.size()>0){
                NHW_Org62Service.org62CallOut(
                    'createCampaignMember',selectedCampaignIds, 
                    org62ContactId,provisioningCase.First_Name__c + ' ' + provisioningCase.Last_Name__c);    
             } 
             system.debug(LoggingLevel.INFO,'selectedCampaignIds:'+selectedCampaignIds);
             system.debug(LoggingLevel.INFO,'org62ContactId:'+org62ContactId);
        }
       
    
    
    private void calculateAccessCode(){
        
        List<NHW_AccessCode> accessCodeList = new List<NHW_AccessCode>();

        //Generate Access code for Software
        List<NHW_Software_Access_Provisioning__c> softwareAccessProvsList = new List<NHW_Software_Access_Provisioning__c>();
        map<Id,NHW_Provisioning__c> mNHWProvs = new map<Id,NHW_Provisioning__c>();
        set<Id> ProvIds = new set<Id>();

        //Select all software access items where selected is true.
        softwareAccessProvsList = [SELECT id,name,Provisioning_Name__c,Provisioning_Id__c,Configuration__c,Selected__c
                                   FROM NHW_Software_Access_Provisioning__c where Provisioning_Case__c = :ProvisioningCase.id];

        for(NHW_Software_Access_Provisioning__c accessProv:softwareAccessProvsList){
            ProvIds.add(accessProv.Provisioning_Id__c);
        }
        mNHWProvs = new map<Id,NHW_Provisioning__c>([SELECT id,name,Metadata__c,Onboarding_Type__c,Onboarding_Category__c,Supportforce_ISC__c
                        FROM NHW_Provisioning__c WHERE type__c='Application' and id in :ProvIds]);
        
        map<string,List<NHW_AccessDetails>> mAccessTypeToAccessDetails = new map<string,List<NHW_AccessDetails>>();

        for(NHW_Software_Access_Provisioning__c SoftwareProv:softwareAccessProvsList){
            //Grab the NHW Prov Rec corresponding to SoftwareProv.
            NHW_Provisioning__c NHWProvRec = mNHWProvs.get(SoftwareProv.Provisioning_Id__c);
            
            if(NHWProvRec!= null){
                //Generating List of Access details as single Software Prov could correspond to multiple Access details - Eg:Business Objects.
                 List<NHW_AccessDetails> accessDetailsList = new List<NHW_AccessDetails>();
                //TODO:As NHW 1.0 Access code generated AccesType with empty access DetailList - mimicking same By iterating over Applxn provs not selected as well.
                //Need to think if we can avoid this.
                 if(SoftwareProv.Selected__c){        
                        //If there additional config values - Generate from NHW prov+ Software Prov.
                        if(NHWProvRec.Metadata__c!= null){
                            PF_NHW_ReviewService.ProvisioningMetadata Metadata = (PF_NHW_ReviewService.ProvisioningMetadata)JSON.Deserialize(NHWProvRec.Metadata__c,PF_NHW_ReviewService.ProvisioningMetadata.CLASS);
                            
                            NHW_AccessDetails details = new NHW_AccessDetails();
                        //Generate access detail
                            if(Metadata.configTitle.contains(System.Label.PF_NHW_User_To_Clone)){
                                if(NHWProvRec.name== System.Label.NHW_GUS_SST ){
                                    details.gusSST = SoftwareProv.Configuration__c; 
                                }else if(NHWProvRec.name== System.Label.NHW_Org62_SST ){
                                    details.org62SST = SoftwareProv.Configuration__c; 
                                }else if(NHWProvRec.name== System.Label.NHW_Supportforce_SST){
                                    details.sfSSt = SoftwareProv.Configuration__c; 
                                }
                                if(NHWProvRec.name== System.Label.NHW_GUS_SST || NHWProvRec.name== System.Label.NHW_Org62_SST || NHWProvRec.name== System.Label.NHW_Supportforce_SST){
                                    details.userToClone =  UserInfo.getName();//This gets replaced in trigger with User Name Based on respective SSTName captured above.
                                }else{
                                    details.userToClone =  SoftwareProv.Configuration__c;
                                }
                                details.name = NHWProvRec.name;
                                details.isc = NHWProvRec.Supportforce_ISC__c;
                                details.category = NHWProvRec.Onboarding_Category__c;
                                accessDetailsList.add(details);

                            }else if (Metadata.configTitle.contains('Business Objects')){
                                List<String> businessObjectOptions = SoftwareProv.Configuration__c.split(';');
                                for(String option: businessObjectOptions){
                                    NHW_AccessDetails BOdetails = new NHW_AccessDetails();
                                    BOdetails.name = NHWProvRec.Name + ' - ' + option;
                                    BOdetails.isc = NHWProvRec.Supportforce_ISC__c;
                                    BOdetails.category = NHWProvRec.Onboarding_Category__c;
                                    BOdetails.userToClone =  NO_USER_NEEDED;
                                    accessDetailsList.add(BOdetails);
                                }               
                            }else if(Metadata.configTitle.contains('Type of Accessibility Software')){
                                details.name = NHWProvRec.name + ' - ' +SoftwareProv.Configuration__c;
                                details.userToClone = NO_USER_NEEDED;
                                details.isc = NHWProvRec.Supportforce_ISC__c;
                                details.category = NHWProvRec.Onboarding_Category__c;
                                accessDetailsList.add(details);
                            }else{ //Other userToClone and Business Objects we don't have any special Metdata.Reserved for future.
                            details.userToClone =  NO_USER_NEEDED;
                            details.name = NHWProvRec.name;
                            details.isc = NHWProvRec.Supportforce_ISC__c;
                            details.category = NHWProvRec.Onboarding_Category__c;
                            accessDetailsList.add(details);  
                            }
                        }//Straightforward AccessDetail generation from NHW prov.
                        else {
                            NHW_AccessDetails details = new NHW_AccessDetails();
                            details.userToClone =  NO_USER_NEEDED;
                            details.name = NHWProvRec.name;
                            details.isc = NHWProvRec.Supportforce_ISC__c;
                            details.category = NHWProvRec.Onboarding_Category__c;
                            accessDetailsList.add(details); 
                        }
               }
               if(mAccessTypeToAccessDetails.containskey(NHWProvRec.Onboarding_Type__c)){
                 mAccessTypeToAccessDetails.get(NHWProvRec.Onboarding_Type__c).addAll(accessDetailsList);
               }else{
                 mAccessTypeToAccessDetails.put(NHWProvRec.Onboarding_Type__c,new List<NHW_AccessDetails>(accessDetailsList));             
               }
            }

        }
        if(mAccessTypeToAccessDetails.size()>0){
            for(String AccessType:mAccessTypeToAccessDetails.keyset()){
                accessCodeList.add(new NHW_AccessCode(AccessType,mAccessTypeToAccessDetails.get(AccessType)));
            }
        }

        //Generate Access code for DeskPhone
        TF2_Business_Site__c BizSite= [select Id, Name from TF2_Business_Site__c WHERE Id = :provisioningCase.NH_Business_Site__c];
        if(BizSite!= null && !BizSite.name.containsIgnoreCase('Remote')){
            List<NHW_Provisioning__c> ApplicableDeskphones = NHW_ProvisioningStore.getProvisionings(provisioningCase,'Mobile');
            ApplicableDeskphones = [Select Id, Name, Onboarding_Category__c, 
                                    Need_User_to_Clone__c, Filter_Criteria__c,Filter_Required__c,Is_Auto_Provisioned__c,
                                    Supportforce_ISC__c, Include_for_ET_Employees__c,Auto_Display__c,
                                    Type__c, Onboarding_Type__c,Organization__r.Name,Organization__c
                                    From NHW_Provisioning__c
                                    Where Type__c = 'Mobile' and id in :ApplicableDeskphones];
            List<NHW_AccessDetails> accessDetailsListDeskphone = new List<NHW_AccessDetails>();

            for(NHW_Provisioning__c provRec:ApplicableDeskphones){
                SYSTEM.DEBUG(LOGGINGLEVEL.INFO,'Is_Auto_Provisioned__c '+provRec.is_Auto_Provisioned__c);
                SYSTEM.DEBUG(LOGGINGLEVEL.INFO,'User selected'+provisioningCase.Desk_and_VoiceMail__c);

                //Check if provisioning qualifies for Auto Provisioning or if user selected as Yes.
                if(provRec.Is_Auto_Provisioned__c || (!provRec.is_Auto_Provisioned__c && (provisioningCase.Desk_and_VoiceMail__c == 'Yes'))){
                    NHW_AccessDetails detailsForJson = new NHW_AccessDetails();
                    detailsForJson.name = provRec.Name;
                    detailsForJson.isc = provRec.Supportforce_ISC__c;
                    detailsForJson.category = provRec.Onboarding_Category__c;
                    accessDetailsListDeskphone.add(detailsForJson);
                }
            }

            accessCodeList.add(new NHW_AccessCode('Mobile',accessDetailsListDeskphone));      
        }
        String AccessCode = JSON.serialize(accessCodeList);
        System.debug(LoggingLevel.INFO,AccessCode);
        ProvisioningCase.NHW_Access_Code__c=AccessCode;          
        
    }
    
    public override List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process){
        return null;
    }
    
    public class ReviewItemGroup{
        
        @AuraEnabled
        public String title{get; private set;}
        @AuraEnabled
        public String icon{get; private set;}
        @AuraEnabled
        public List<ReviewItem> reviewItems{get; private set;}


        
        public ReviewItemGroup(String title, String icon, List<ReviewItem> reviewItems){
            this.title = title;
            this.icon = icon;
            this.reviewItems = reviewItems;
        }
    }
    public class ProvisioningMetadata{
        String configComponent;
        String configTitle;
        String field;
    }
}