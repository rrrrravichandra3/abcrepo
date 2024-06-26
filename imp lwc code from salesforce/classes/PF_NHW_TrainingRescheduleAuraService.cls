public without sharing class PF_NHW_TrainingRescheduleAuraService {
	
    @AuraEnabled
    public static InitialTrainingResources getTrainingOptions(String provisioningCaseString, String currentReviewTrainingDisplayName){
        Case provisioningCase = (Case)JSON.deserialize(provisioningCaseString, Case.class);
       	//leverage the code behind trainings page to get all trainings
        PF_NHW_TrainingProvisioningTypeService trainingService = new PF_NHW_TrainingProvisioningTypeService();
        trainingService.provisioningCase = provisioningCase;
        trainingService.provisioningType = PF_NHW_ProvisioningType.getProvisioningTypeByName('Training');
         
		//filter and return only the ones we need
		//variable currentReviewTrainingDisplayName is the label of review item against which edit was clicked
        List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning> allTrainingsBeforeFilter = (List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning>)trainingService.getProvisionings();
        List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning> filteredTrainings = new List<PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning>();
        for(PF_NHW_TrainingProvisioningTypeService.TrainingProvisioning currentTraining: allTrainingsBeforeFilter){
            if(currentTraining.TrainingTypeDisplayName == currentReviewTrainingDisplayName){
                filteredTrainings.add(currentTraining);
            }
        }
        return new InitialTrainingResources(trainingService.org62Contact,filteredTrainings);
    }
    
    public class InitialTrainingResources{
        @AuraEnabled
        public string org62ContactId;
        
        @AuraEnabled
        public List<Object> filteredTrainings;
        
        public InitialTrainingResources(String org62ContactId, List<Object> filteredTrainings){
            this.org62ContactId = org62ContactId;
            this.filteredTrainings = filteredTrainings;
        }
    }
    
    
}