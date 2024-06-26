/**
 * @description This class contains an Apex method that updates the status of ServiceAppointments for candidates whose job applications have been rejected.
 * @author 
 */
public inherited sharing class IA_ServiceAppointmentDecomission {
    /**
     * @description This method updates the status of ServiceAppointments for candidates whose job applications have been rejected.
     *
     * @param candidateIds A list of IDs of candidates whose job applications have been rejected.
     * @throws System.QueryException If there is an error in the SOQL query.
     * @throws System.DmlException If there is an error updating the ServiceAppointment records.
     * @throws System.EmailException If there is an error sending the exception mail.
     */
    @InvocableMethod
    public static void updateServiceAppointmentForRejectedCandidate(List<id> candidateIds) {
        if(Schema.getGlobalDescribe().get('ServiceAppointment').getDescribe().isAccessible() && Schema.getGlobalDescribe().get('ServiceAppointment').getDescribe().isUpdateable()
          && Schema.getGlobalDescribe().get('WDR_Application__c').getDescribe().isAccessible() && Schema.getGlobalDescribe().get('WDR_Application__c').getDescribe().isUpdateable()){
            if(Schema.sObjectType.ServiceAppointment.fields.Status.isAccessible() && Schema.sObjectType.ServiceAppointment.fields.Status.isUpdateable()
              && Schema.sObjectType.WDR_Application__c.fields.Candidate__c.isAccessible() && Schema.sObjectType.WDR_Application__c.fields.Candidate__c.isUpdateable()
              && Schema.sObjectType.WDR_Application__c.fields.Internal_Candidate__c.isAccessible() && Schema.sObjectType.WDR_Application__c.fields.Internal_Candidate__c.isUpdateable()
              && Schema.sObjectType.WDR_Application__c.fields.Candidate_Stage__c.isAccessible() && Schema.sObjectType.WDR_Application__c.fields.Candidate_Stage__c.isUpdateable()){
                
                //Query Job App
                //Map<id,List<WDR_Application__c>> mapOfCandidateJobApp = new Map<id,List<WDR_Application__c>>();
                Map<id,List<WDR_Application__c>> mapOfCandidateJobApp = new Map<id,List<WDR_Application__c>>();
                List<String> internalCanStages = IA_Util.eligibleCandidateStagesForInternal;
                List<String> externalCanStages = IA_Util.eligibleCandidateStages;
                List<WDR_Application__c> jobApp = [Select id,Candidate__c,Internal_Candidate__c,Candidate_Stage__c from WDR_Application__c where Candidate__c =:candidateIds 
                AND (Candidate_Stage__c != 'Rejected' AND Candidate_Stage__c != 'Declined by Candidate')];

                for(WDR_Application__c wd:jobApp){
                    if((wd.Internal_Candidate__c && internalCanStages.contains(wd.Candidate_Stage__c)) || (!wd.Internal_Candidate__c && externalCanStages.contains(wd.Candidate_Stage__c))){
                        if(mapOfCandidateJobApp.containsKey(wd.Candidate__c)){
                            List<WDR_Application__c> wdList = mapOfCandidateJobApp.get(wd.Candidate__c);
                            wdList.add(wd);
                            mapOfCandidateJobApp.put(wd.Candidate__c,wdList);
                        }
                        else if(!mapOfCandidateJobApp.containsKey(wd.Candidate__c)){
                            mapOfCandidateJobApp.put(wd.Candidate__c,new List<WDR_Application__c>{wd});
                        }
                    }
                }
                Id contactId = [Select Candidate_Contact__r.Id from WDR_Candidate__c where id=:candidateIds].Candidate_Contact__r.Id;
                if(mapOfCandidateJobApp.size() == 0){
                    List<ServiceAppointment> srvAppointments = [SELECT id,Status From ServiceAppointment WHERE ContactId=:contactId And Status In('Scheduled','Rescheduled')];
                    List<String> errorMessages = new List<String>();
                    if(srvAppointments.size() > 0){
                        for(ServiceAppointment srvapp : srvAppointments){
                            srvapp.Status = 'Dispositioned';
                        }
                        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, srvAppointments);
                        Database.SaveResult[] srList ;
                        if(!securityDecision.getRecords().isEmpty()){
                            srList = Database.update( securityDecision.getRecords(),false) ;
                        }
                        //Database.SaveResult[] srList = Database.update(srvAppointments,false) ;
                        for (Database.SaveResult sr : srList) {
                            if (!sr.isSuccess()){
                                for(Database.Error objErr : sr.getErrors()) {
                                    errorMessages.add('An Error Happened when we are inserting the service appointment Share record the' +objErr.getMessage());	
                                }
                            }
                        }
                        if(errorMessages.Size() > 0){
                            IA_Util.sendExceptionMail(errorMessages);
                        }
                    }
                }
            }
        }
    }
}