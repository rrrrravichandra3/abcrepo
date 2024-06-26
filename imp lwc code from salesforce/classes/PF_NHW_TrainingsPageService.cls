@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class PF_NHW_TrainingsPageService extends PF_NHW_PageService{
    
    protected override List<PF_NHW_LightningComponentConfiguration> getComponentsConfig(){
        return PF_NHW_LightningComponentsService.getComponentsConfigForCaseAndPage(provisioningCase, PF_NHW_Page.TRAININGS);
    }
    protected override map<String,object> getPageConfig(){
        //Based on training visibility - determine PageTitle
        map<String,object> pageConfig = new map<String,object>();
		List<PF_NHW_LightningComponentConfiguration> configs = PF_NHW_LightningComponentsService.getComponentsConfigForCaseAndPage(provisioningCase, PF_NHW_Page.TRAININGS);
        if(configs.size()>0 ){
            for(PF_NHW_LightningComponentConfiguration config:configs){
                if(config.id=='pf_nhw_training' && config.attributes.size()>0){
                    for(PF_NHW_LightningComponentAttribute attribute:config.attributes){
                        system.debug('attribute'+attribute);
                        if(attribute.name == 'visible' && attribute.value== 'false'){
                           pageConfig.put('pageTitle', System.Label.NHW_Page_4_title_FTE_No_Trainings);
                        }else{
                          pageConfig.put('pageTitle', System.Label.NHW_Page_4_title_FTE);
                        }
                    }
                }
            }
        }
        return pageConfig;
    }
    
    public override String processPageInformation(){
        if(this.additionalInformation != null && this.additionalInformation.containsKey('TRAININGSELECTIONS')){
            List<Object> TrainingsOptions = (List<Object>)this.additionalInformation.get('TRAININGSELECTIONS');
            String options = JSON.serialize(TrainingsOptions);
            List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning> Trainingprovs = (List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning>)json.deserialize(options, List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning>.class);
            system.debug('Trainingprovs'+Trainingprovs);
            
            String TrainingText='';
            String TrainingEmail = '';
            List<PF_NHW_TrainingsPageService.SelectedTraining> selectedtrainings = new List<PF_NHW_TrainingsPageService.SelectedTraining>();
         
            for(PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning trainingProv : Trainingprovs){
                if(!String.isBlank(trainingProv.SelectedValue) ){
                    String selectedTrainingDisplayName='';
                     PF_NHW_TrainingsPageService.SelectedTraining selectedtraining = new PF_NHW_TrainingsPageService.SelectedTraining();

                    for(PF_NHW_TrainingProvisioningTypeService.TrainingOptions option: trainingProv.AllTrainingOptions){
                        if(option.value== trainingProv.SelectedValue){
                            selectedTrainingDisplayName=option.label;                          
                        }
                    }
                    selectedtraining.org62ContactId = trainingProv.org62ContactId;
                    selectedtraining.TrainingType = trainingProv.TrainingType;
                    selectedtraining.CampaignId  = trainingProv.SelectedValue;
                    selectedTraining.isEnrolled = trainingProv.isEnrolled;
                    selectedtrainings.add(selectedtraining);
                    TrainingEmail +=   trainingProv.TrainingTypeDisplayName+' : '+selectedTrainingDisplayName+'<br />' ;                                 
                }
                TrainingText = JSON.serialize(selectedtrainings);

            }
            provisioningcase.NHW_training__c =TrainingText;
            provisioningcase.NH_Training_Email_Merge__c=TrainingEmail;
            
            if (!provisioningCase.NHW_Job_Application__r.Job__r.Is_SVP_Level_Job__c) {
                Contact trailguideContact =[Select id,name,email from contact where id=:provisioningcase.NHW_trail_Guide__c];
                provisioningcase.Onboarding_Buddy_Name__c =trailguideContact.name;
                provisioningcase.Onboarding_Buddy_Email__c=trailguideContact.email;
                if(provisioningcase.NHW_trail_Guide__c == provisioningcase.Manager_Name__c){
                    throw new AuraHandledException(System.Label.NHW_trailguide_and_manager_same_error);
                }
            }
        }
        return provisioningCase.Id;
    }
    
    //Use NHW framwork to check if Training/TrailGuide is editable
    public static Boolean isPastSubAttrEditable(Case provisioningCase, PF_NHW_Process process, String componentId) {
        Boolean isAllowed = False;
        PF_NHW_LightningComponentConfiguration PastSubTrailguideConfiguration = PF_NHW_LightningComponentsService.getComponentConfiguration(provisioningCase, componentId);
        if(PastSubTrailguideConfiguration != null) {
            for(PF_NHW_LightningComponentAttribute attribute : PastSubTrailguideConfiguration.attributes) {
                if(attribute.name == 'pastSubEditable' && attribute.Value != null && String.valueOf(attribute.Value) == 'true') {
                    isAllowed = True;
                }
            }
        }
        return isAllowed;
    }

    /*Purpose : check if edit icon should be display
    If campaign is SENT and date is in past --> SHOW EDIT ICON
    If campaign is RESPONDED and date is in future --> SHOW EDIT ICON
     If campaign is in FUTURE, it is fair to ASSUME that status is RESPONDED
    
    Parameters Information : 
     campaignLabel --> the label of campaign displayed on the UI
     checkForPast --> boolean to determine if logic to check if campaign is in past and SENT should run
     displayNameToTrainingType --> map of campaign display name to campaign type
     campaignLabelToId --> map of campaign label (what is displayed on UI) to the campaign id
     campaignIdToMemberResult --> map of campaign id to member result object
    */
    public static Boolean isTrainingAttendedOrInFuture(NHW_Org62Service.CampaignMemberResult cmr) {
        //If it's past training that is NOT attended i.e no-show
        if(cmr.campaignStartDate < Date.today() && cmr.status == 'Sent') {
            return True;
        }
        else {
            if(cmr.campaignStartDate > Date.today()) {
                return True;
            }
        }
        return False;
    }

    /*
    Purpose: check if the edit icon should display
    If campaign start date is in the past and contains location name as 'Trailhead' or 'Virtual' -> Show EDIT Icon
    Virtual Trainings No shows are marked as 'Sent', so campaign member status check has been removed
    */

    public static Boolean isPastDatedTrailheadOrVirtualTraining(NHW_Org62Service.CampaignMemberResult cmr) {
       if(cmr.campaignStartDate <= Date.today() && (cmr.campaignLocation.toLowerCase().contains('trailhead') || cmr.campaignLocation.toLowerCase().contains('virtual'))) {
            return True;
        }
        return False;
    }  

    public Map<String,String> populatePastSelectionFromCase(Case provisioningCase){
        Map<String, String> mTrainingTypeToId = new Map<String, String>();
        if(provisioningcase.NHW_Training__c != null){
            List<PF_NHW_TrainingsPageService.SelectedTraining> selectedtrainings = (List<PF_NHW_TrainingsPageService.SelectedTraining>)json.deserialize(provisioningcase.NHW_Training__c, List<PF_NHW_TrainingsPageService.SelectedTraining>.class);
            for(PF_NHW_TrainingsPageService.SelectedTraining SelectedTraining:SelectedTrainings){
                mTrainingTypeToId.put(SelectedTraining.TrainingType,SelectedTraining.CampaignId);                  
            }
        }
        return mTrainingTypeToId;
    }

    public override List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process){
		Boolean IsPastSubTrailguideEditable = isPastSubAttrEditable(provisioningCase, process, 'pf_nhw_trail_guide');
        Boolean IsPastSubTrainingDateEditable = isPastSubAttrEditable(provisioningCase, process, 'pf_nhw_training');
        Map<String, String> mTrainingTypeToId = populatePastSelectionFromCase(provisioningCase);

        List<ReviewItem> reviewList = new List<ReviewItem>();
        //Sometimes we hide the Training block based on a criteria even though there might be matching prov recs there 
        //- [Eg Intern codes are not excluded in all Training Prov recs as it is lengthy.]
        // So NHW_training__c might be there bot email merge will be null as there is no user selection 
        if(provisioningcase.NHW_training__c != null && provisioningCase.NH_Training_Email_Merge__c!= null){
			Set<String> trainingNameSet = new Set<String>();
            Map<String,Boolean> trainingNameRescheduleMap = new Map<String,Boolean>();
            Map<String,Boolean> trainingNameReschedulableByEmployeeMap = new Map<String,Boolean>();
            Integer colPos;
            for(String s : provisioningCase.NH_Training_Email_Merge__c.split('<br />', 0)) {
                if (s != null && s != '') {
                    colPos = s.indexOf(':');
                    if (colPos > 0) {
                        String trainingName = s.substring(0, colPos).trim();
                        trainingNameSet.add(trainingName);
                        ReviewItem item = new ReviewItem(trainingName, s.substring(colPos + 1));
                        reviewList.add(item);                             
                    }
                }                
            }
            
            //Check NHW Provisioning record if Training is reschedulable
            if(trainingNameSet != null && !trainingNameSet.isEmpty()) {
                //Re-using PF_NHW_TrainingProvisioningTypeService class to grab all trainings
                PF_NHW_TrainingProvisioningTypeService trainingService = new PF_NHW_TrainingProvisioningTypeService();
                trainingService.provisioningCase = provisioningCase;
                trainingService.provisioningType = PF_NHW_ProvisioningType.getProvisioningTypeByName('Training');
                List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning> allTrainings = (List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning>)trainingService.getProvisionings();
                
                Map<String, String> displayNameToTrainingType = new Map<String, String>();
                //Create a map of display name to training type 
                //(ex. Sales Bootcamp --> Internal - Sales Bootcamp)
                
                for(PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning currentTraining : allTrainings) {
                    displayNameToTrainingType.put(currentTraining.TrainingTypeDisplayName, currentTraining.TrainingType);
                }

                for(NHW_Provisioning__c nhwProv : [select Display_Name__c, Reschedulable__c, Reschedulable_By_Employee__c from NHW_Provisioning__c where Display_Name__c IN: trainingNameSet]) {
                    trainingNameRescheduleMap.put(nhwProv.Display_Name__c, nhwProv.Reschedulable__c);
                    trainingNameReschedulableByEmployeeMap.put(nhwProv.Display_Name__c, nhwProv.Reschedulable_By_Employee__c );
                }
                //If process = employeeviewupdate then also check for reschedulable boolean which  indicates whether employee see this.
                for(ReviewItem item : reviewList) {
                    if(IsPastSubTrainingDateEditable 
                       && ((process.name != 'employeeviewandupdate'
                               && trainingNameRescheduleMap != null && trainingNameRescheduleMap.containsKey(item.label) 
                               && trainingNameRescheduleMap.get(item.label))
                          ||(process.name == 'employeeviewandupdate'
                               && trainingNameReschedulableByEmployeeMap != null && trainingNameReschedulableByEmployeeMap.containsKey(item.label) 
                               && trainingNameReschedulableByEmployeeMap.get(item.label)            
                           )
                          ) 
                      ) {
                        //Get training type using display name
                        String trainingType = displayNameToTrainingType.get(item.label);
                        //Get the display name for getting the campaign name
                        String trainingDisplayName = item.label;
                        //Get campaign id using training type
                        String campaignId = mTrainingTypeToId.get(trainingType);
                        //Get campaign member result
                        NHW_Org62Service.CampaignMemberResult cmr = trainingService.mCampaignIdToCampaignMemberResult.get(campaignId);
                        
                        //Check if training is editable i.e (in past and status == SENT) OR (in future)
                        if(cmr!= null && (isTrainingAttendedOrInFuture(cmr) || isPastDatedTrailheadOrVirtualTraining(cmr))) {
                            item.isEditable = True;
                        }
                        else {
                            //Else, training must NOT be editable i.e NO PENCIL ICON
                            item.isEditable = False;
                        }
                        Item.configComponentName = 'PF_NHW_PastSubmissionDetailTrainingReschedule';
                    }
                }
            }
        }
        
        if(provisioningcase.NHW_trail_Guide__c != null && process != PF_NHW_Process.EMPLOYEEVIEWANDUPDATE){
            ReviewItem Item = new ReviewItem('Trail Guide',provisioningcase.Onboarding_Buddy_Name__c);
            if( IsPastSubTrailguideEditable && (provisioningcase.status == 'Sent to Supportforce' ||  provisioningcase.status == 'Closed' )
               && provisioningcase.NHW_Start_Date__c != null
               &&  provisioningcase.NHW_Start_Date__c > system.today()+3  ){
                   Item.isEditable = true;
                   Item.configComponentName = 'PF_NHW_PastSubmissionDetailTrailGuideEdit';
               }
             reviewList.add(Item);                                                

        }
        
        if(process != PF_NHW_Process.EMPLOYEEVIEWANDUPDATE) {
            reviewList.add(new ReviewItem('Comments',provisioningcase.Description));       
        }
        
        return reviewList;
    }
    public class SelectedTraining{
        public String org62ContactId;
        public String TrainingType;
        public String CampaignId;     
        public Boolean isEnrolled;   
    }
}