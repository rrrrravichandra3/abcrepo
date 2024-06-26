@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public without sharing class PF_NHW_PastSubmissionEditServices {
    @AuraEnabled
    public static void updateCase(String ActionType,String UserInput,String userInputName, Case ProvisioningCase, String currentReviewItem, String additionalInformation){
        if(ActionType == 'TRAILGUIDE'){
            Contact trailguideContact =[Select id,name,email from contact where id=:UserInput];
            provisioningcase.Onboarding_Buddy_Name__c =trailguideContact.name;
            provisioningcase.Onboarding_Buddy_Email__c=trailguideContact.email;
            provisioningcase.NHW_trail_Guide__c = UserInput;
            if(provisioningcase.NHW_trail_Guide__c == provisioningcase.Manager_Name__c){
                throw new AuraHandledException(System.Label.NHW_trailguide_and_manager_same_error);
            }
            update provisioningcase;

            //Log any exceptions from org62 update in NHW PF debug logs
            try{
                NHW_Org62Service.org62CallOut(
                    'UpdateTrailGuideContactInfo',null,provisioningcase.Email_address__c,trailguideContact.email);
            } 
            catch(Exception ex){
                System.debug('Error in updateTrailguideContact Info to Web Service'+ex.getMessage());
                //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the UpdateTrailGuideContactInfo method for email  = ' + provisioningcase.Email_address__c, 'PF_NHW_PastSubmissionEditServices',provisioningcase.Email_address__c);
                EventBus.publish(
                            new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'PF_NHW_PastSubmissioonEditServices',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the UpdateTrailGuideContactInfo method for email  = ' + provisioningcase.Email_address__c
                                )
                        ); 
            }
            finally{
                NHW_Util.insertNHWLogs();  
            }
        }
        if(ActionType == 'RescheduleTraining'){
            //As part of reschedule training, we need to perform 3 tasks
            //Task 1: Update the field NHW_Training__c and NH_Training_Email_Merge__c on Case in peopleforce. It stores current trainings in JSON format. Update the ID corresponding to training being rescheduled with new ID
            //Task 2: Update the status of old campaign in Org62 to "Sent"
            //Task 3: Create new campaign member in Org62 for the new training
            
            try{
                //***********Task 1******************//
                //Tricky part is getting the training name of the training being updated
                //On the field NHW_Training__c, trainingtype is equal to Name of NHW Provisioning record (or the "Type" of the Campaign in Org62)
                //However, the data structure "Review Item" being passed to server, stores "Display Name" of the NHW Provisioning record
                //So we need to take the Display Name and backtrack it to Name of the NHW Provisioning record, then update that part of JSON
                //Get old campaign Id from prov case and store it in variable currentReviewItemId
                PF_NHW_PageService.ReviewItem currentTrainingReviewItem = (PF_NHW_PageService.ReviewItem)json.deserialize(currentReviewItem, PF_NHW_PageService.ReviewItem.class);
                map<string,string> mSelectedCampaigns = new map<string,string>();
                List<PF_NHW_TrainingsPageService.SelectedTraining> selectedtrainings = (List<PF_NHW_TrainingsPageService.SelectedTraining>)json.deserialize(provisioningcase.NHW_Training__c, List<PF_NHW_TrainingsPageService.SelectedTraining>.class);
                for(PF_NHW_TrainingsPageService.SelectedTraining SelectedTraining:SelectedTrainings){
                    mSelectedCampaigns.put(SelectedTraining.TrainingType,SelectedTraining.CampaignId);                  
                }
                List<NHW_Provisioning__c> selectedTrainingProvisioningRecords = [Select Name, Display_Name__c from NHW_Provisioning__c where Name IN :mSelectedCampaigns.keySet()];
                String currentReviewItemId;
                for(NHW_Provisioning__c currentProvisioning: selectedTrainingProvisioningRecords){
                    if(currentProvisioning.Display_Name__c == currentTrainingReviewItem.label){
                        currentReviewItemId = mSelectedCampaigns.get(currentProvisioning.Name);
                    }
                }
                //if new selection is same as old selection, do not perform any operation
                if(currentReviewItemId == UserInput){
                    return;
                }
                //go back and update the list selectedtrainings, put it in JSON format and update it into the case
                //we only need to update "campaign ID" part of the training we are updating
                for(PF_NHW_TrainingsPageService.SelectedTraining currentTraining:SelectedTrainings){
                    if(currentTraining.CampaignId == currentReviewItemId){
                        currentTraining.CampaignId = UserInput;
                    }
                }
                String updatedSelectedTrainings = JSON.serialize(SelectedTrainings);
                provisioningCase.NHW_Training__c = updatedSelectedTrainings;
                //update the merge field
                //UserInputName is the new substring we want in field NH_Training_Email_Merge__c instead of currentTrainingReviewItem.value
                String TrainingEmail = provisioningCase.NH_Training_Email_Merge__c;
                String newMergeFieldValue = TrainingEmail.replace(currentTrainingReviewItem.value,UserInputName);
                provisioningCase.NH_Training_Email_Merge__c = newMergeFieldValue;
                update provisioningCase;
                //Task 2 and Task 3 are handled in org62.
                String oldCampaignId = String.isBlank(currentReviewItemId) ? null:currentReviewItemId;
                String newCampaignId = UserInput;
                String org62ContactId = String.isBlank(additionalInformation) ?null:additionalInformation ;

                NHW_Org62Service.org62CallOut('rescheduleTraining', new List<String>{oldCampaignId,newCampaignId}, org62ContactId,'' );
                
             } 
            catch(Exception ex){
                System.debug('Error in rescheduling training to Web Service'+ex.getMessage());
                //PF_Logger.log('NHW','ERROR',ex.getMessage(),ex.getTypeName(), ex.getLineNumber()+' Error in the rescheduleTraining method for email  = ' + provisioningcase.Email_address__c, 'PF_NHW_PastSubmissionEditServices',provisioningcase.Email_address__c);
                EventBus.publish(
                            new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = ex.getTypeName(),
                                Stack_Trace__c = 'PF_NHW_PastSubmissioonEditServices',
                                Message__c = ex.getMessage(),
                                Error__c = ex.getLineNumber()+' Error in the rescheduleTraining method for email  = ' + provisioningcase.Email_address__c
                                )
                        );  
            }
            finally{
                NHW_Util.insertNHWLogs();  
            }
        }
    }
    
}