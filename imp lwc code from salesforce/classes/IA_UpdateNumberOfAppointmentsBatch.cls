/**
 * @description       : Batch job to count the number of appointments for a Service Resource in a month 
 * @author            : skolagani@salesforce.com
 * @last modified on  : 08-04-2021
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-03-2021   Sri Kolagani                         Batch job creation
 * 2.0   03-31-2021   Sri Kolagani                         Batch job update to consider next month
**/
public with sharing class IA_UpdateNumberOfAppointmentsBatch implements Database.Batchable<sObject>,  Database.Stateful {
    public Map <Id, List<ServiceAppointment>> serviceResourcetoAppointmentsThisMonth = new Map <Id, List<ServiceAppointment>>();
    public Map <Id, List<ServiceAppointment>> serviceResourcetoAppointmentsNextMonth = new Map <Id, List<ServiceAppointment>>();
    public Map <Id, List<ServiceAppointment>> serviceResourcetoAppointmentsLastMonth = new Map <Id, List<ServiceAppointment>>();
    public List<ServiceResource> listOfServiceResourcesToUpdate = new List<ServiceResource>();
    public List<ServiceResource> listOfServiceResourcesToReset = new List<ServiceResource>();
    public Map<Id, String> failedUpdateRecords = new Map<Id, String>();
    public Insiders_App_Config__mdt appConfig = [SELECT Email_Addresses_for_Exceptions__c  from Insiders_App_Config__mdt LIMIT 1];
    public Date currentDate=Date.today();
    public Integer currentMonthOfDays = Date.daysInMonth(currentDate.year(), currentDate.month());
    public Date endDayOfMonth = Date.newInstance(currentdate.year(), currentdate.month(), currentMonthOfDays);
    public Integer daysLeftInThisMonth=currentDate.daysBetween(endDayOfMonth);

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Insider_Volunteer__c,StartDate__c, Status from ServiceAppointment where (StartDate__c = THIS_MONTH OR StartDate__c = NEXT_MONTH OR StartDate__c = LAST_MONTH) AND (Insider_Volunteer__r.RelatedRecord.isActive= true)';
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext BC, List<ServiceAppointment> scope) {
      for (ServiceAppointment sa: scope) {
          // Adding THIS MONTH Appointments  
          if(sa.StartDate__c.Month() == Date.Today().Month()){
              if(serviceResourcetoAppointmentsThisMonth.containsKey(sa.Insider_Volunteer__c)){
                  List<ServiceAppointment> saListThisMonth = serviceResourcetoAppointmentsThisMonth.get(sa.Insider_Volunteer__c);
                  saListThisMonth.add(sa);
                  serviceResourcetoAppointmentsThisMonth.put(sa.Insider_Volunteer__c, saListThisMonth);
                }
              else {
                  serviceResourcetoAppointmentsThisMonth.put(sa.Insider_Volunteer__c, new List<ServiceAppointment>{sa});
              } 
          }
          // Adding NEXT MONTH Appointments  
          if(sa.StartDate__c.Month() == Date.Today().addMonths(1).Month()){
              if(serviceResourcetoAppointmentsNextMonth.containsKey(sa.Insider_Volunteer__c)){
                  List<ServiceAppointment> saListNextMonth = serviceResourcetoAppointmentsNextMonth.get(sa.Insider_Volunteer__c);
                  saListNextMonth.add(sa);
                  serviceResourcetoAppointmentsNextMonth.put(sa.Insider_Volunteer__c, saListNextMonth);
                }
              else {
                  serviceResourcetoAppointmentsNextMonth.put(sa.Insider_Volunteer__c, new List<ServiceAppointment>{sa});
              } 
          }
          // Adding LAST MONTH Appointments  
          if(sa.StartDate__c.Month() == Date.Today().addMonths(-1).Month()){
            if(serviceResourcetoAppointmentsLastMonth.containsKey(sa.Insider_Volunteer__c)){
                List<ServiceAppointment> saListLastMonth = serviceResourcetoAppointmentsLastMonth.get(sa.Insider_Volunteer__c);
                saListLastMonth.add(sa);
                serviceResourcetoAppointmentsLastMonth.put(sa.Insider_Volunteer__c, saListLastMonth);
              }
            else {
                serviceResourcetoAppointmentsLastMonth.put(sa.Insider_Volunteer__c, new List<ServiceAppointment>{sa});
            } 
        }
      }
      
      if(serviceResourcetoAppointmentsLastMonth.keyset().size() > 0){
        for(Id srlm: serviceResourcetoAppointmentsLastMonth.keyset()){
            if(!serviceResourcetoAppointmentsThisMonth.containsKey(srlm) && !serviceResourcetoAppointmentsNextMonth.containsKey(srlm)){
                ServiceResource serviceResourceToUpdateLastMonth = new ServiceResource();
                serviceResourceToUpdateLastMonth.Id = srlm; 
                serviceResourceToUpdateLastMonth.Number_Of_Meetings_This_Month__c = 0;
                serviceResourceToUpdateLastMonth.Number_Of_Meetings_Next_Month__c = 0;
                listOfServiceResourcesToUpdate.add(serviceResourceToUpdateLastMonth);
            }
        }
      }

        if(serviceResourcetoAppointmentsNextMonth.keyset().size() > 0){
            for(Id sr: serviceResourcetoAppointmentsNextMonth.keyset()){
                if(!serviceResourcetoAppointmentsThisMonth.containsKey(sr)){
                    ServiceResource serviceResourcetoAppointmentNextMonth = new ServiceResource();
                    List<ServiceAppointment> serviceAppointmentsWithValidStatusNextMonth = new List<ServiceAppointment>();
                    serviceResourcetoAppointmentNextMonth.Id = sr; 
                    if(serviceResourcetoAppointmentsNextMonth.get(sr).size() > 0){
                        for(ServiceAppointment saNm: serviceResourcetoAppointmentsNextMonth.get(sr)) {
                            if(saNm.Status == 'Scheduled' || saNm.Status == 'Completed' || saNm.Status == 'Rescheduled'){
                                serviceAppointmentsWithValidStatusNextMonth.add(saNM);
                            }
                        }
                        if(serviceAppointmentsWithValidStatusNextMonth.size() > 0) {
                            serviceResourcetoAppointmentNextMonth.Number_Of_Meetings_Next_Month__c = serviceAppointmentsWithValidStatusNextMonth.size();
                        } else{
                            serviceResourcetoAppointmentNextMonth.Number_Of_Meetings_Next_Month__c = 0;
                        }
                    } else {
                        serviceResourcetoAppointmentNextMonth.Number_Of_Meetings_Next_Month__c = 0; 
                    }   
                    listOfServiceResourcesToUpdate.add(serviceResourcetoAppointmentNextMonth);
                }
            }
        }
        
        if(serviceResourcetoAppointmentsThisMonth.keyset().size() > 0){
            for(Id sr: serviceResourcetoAppointmentsThisMonth.keyset()){
                ServiceResource serviceResourceToUpdateThisMonth = new ServiceResource();
                List<ServiceAppointment> serviceAppointmentsWithValidStatusThisMonth = new List<ServiceAppointment>();
                List<ServiceAppointment> serviceAppointmentsWithValidStatusNxtMonth = new List<ServiceAppointment>();
                serviceResourceToUpdateThisMonth.Id = sr; 
                if(serviceResourcetoAppointmentsThisMonth.get(sr).size() > 0){
                    for(ServiceAppointment saTm: serviceResourcetoAppointmentsThisMonth.get(sr)) {
                        if(saTm.Status == 'Scheduled' || saTm.Status == 'Completed' || saTm.Status == 'Rescheduled') {
                            serviceAppointmentsWithValidStatusThisMonth.add(saTm);
                        }
                    }
                    if(serviceAppointmentsWithValidStatusThisMonth.size() > 0) {
                        serviceResourceToUpdateThisMonth.Number_Of_Meetings_This_Month__c = serviceAppointmentsWithValidStatusThisMonth.size();
                    } else{
                        serviceResourceToUpdateThisMonth.Number_Of_Meetings_This_Month__c = 0;
                    }
                } else {
                    serviceResourceToUpdateThisMonth.Number_Of_Meetings_This_Month__c = 0;
                }
                if(serviceResourcetoAppointmentsNextMonth.containsKey(sr)){
                    if(serviceResourcetoAppointmentsNextMonth.get(sr).size() > 0){
                        for(ServiceAppointment saNxtm: serviceResourcetoAppointmentsNextMonth.get(sr)) {
                            if(saNxtm.Status == 'Scheduled' || saNxtm.Status == 'Completed' || saNxtm.Status == 'Rescheduled') {
                                serviceAppointmentsWithValidStatusNxtMonth.add(saNxtm);
                            }
                        }
                        if(serviceAppointmentsWithValidStatusNxtMonth.size() > 0) {
                            serviceResourceToUpdateThisMonth.Number_Of_Meetings_Next_Month__c = serviceAppointmentsWithValidStatusNxtMonth.size();
                        } else{
                            serviceResourceToUpdateThisMonth.Number_Of_Meetings_Next_Month__c = 0;
                        }
                    } else {
                        serviceResourceToUpdateThisMonth.Number_Of_Meetings_Next_Month__c = 0; 
                    }   
                }
                if(daysLeftInThisMonth >= 10 && serviceResourceToUpdateThisMonth.Number_Of_Meetings_This_Month__c >=4){
                    serviceResourceToUpdateThisMonth.Ghost_Mode_Car__c = true; 
                } else if( daysLeftInThisMonth < 10 && serviceResourceToUpdateThisMonth.Number_Of_Meetings_This_Month__c >=4 && serviceResourceToUpdateThisMonth.Number_Of_Meetings_Next_Month__c >=4){
                    serviceResourceToUpdateThisMonth.Ghost_Mode_Car__c = true; 
                } else {
                    serviceResourceToUpdateThisMonth.Ghost_Mode_Car__c = false; 
                } 
                listOfServiceResourcesToUpdate.add(serviceResourceToUpdateThisMonth);
            }
        }
        
        if(listOfServiceResourcesToUpdate.size()>0 && Schema.sObjectType.ServiceAppointment.isUpdateable()){
          Map<Id,ServiceResource> mapOfServiceResourcesToUpdate = new Map<Id,ServiceResource>();
          mapOfServiceResourcesToUpdate.putAll(listOfServiceResourcesToUpdate);
          Database.SaveResult[] updateResults = Database.update(mapOfServiceResourcesToUpdate.values(), false);
          for(Integer i=0;i<updateResults.size();i++){
              if (!updateResults.get(i).isSuccess()){
                  Database.Error error = updateResults.get(i).getErrors().get(0);
                  failedUpdateRecords.put(listOfServiceResourcesToUpdate.get(i).Id, error.getStatusCode() + ': ' + error.getMessage());
              }  
            }
        }    
    }
    
    public void finish(Database.BatchableContext BC) { 
        
         List<String> emailIds = new List<String>();
        if(!String.isEmpty(appConfig.Email_Addresses_for_Exceptions__c)){
            emailIds.addAll(appConfig.Email_Addresses_for_Exceptions__c.split(','));
        }
    
        if(!failedUpdateRecords.keySet().isEmpty()){
        Messaging.SingleEmailMessage mailFailedUpdates = new Messaging.SingleEmailMessage();
        
        mailFailedUpdates.setToAddresses(emailIds);
        mailFailedUpdates.setSenderDisplayName('Insiders App Ghost Mode');
        mailFailedUpdates.setSubject('OrgID:'+ UserInfo.getOrganizationId() + ' Ghost Mode failed results');
        String message = '';
        
            message = message + '\nFollowing ' + failedUpdateRecords.size() +'  Ghost Mode Failed to Update :\n';
            for(String fdr : failedUpdateRecords.keySet()){
                message = message +'\n'+ fdr + ' : '+ failedUpdateRecords.get(fdr);
            }
            mailFailedUpdates.setPlainTextBody(message);
            if(!test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailFailedUpdates});
            }
        }
    }
  }