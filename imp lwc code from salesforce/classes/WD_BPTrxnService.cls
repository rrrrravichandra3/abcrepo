/* This service class houses helper logic to worker events processing
 - Determine and associate the event to PF Contacts
 - Determine and map the event to the respective PF sobject.
 - Update the respective PF sobjects
 - Given this is Platform event subscriber,Used without sharing as it runs in context of Automated user and not end user.
*/
public Without Sharing class WD_BPTrxnService {
    
    public static Map<String,Contact> getContactBasedOnEmployeeId(Set<String> employeeIds){
        Map<String,Contact> employeeIdByContact = new Map<String,Contact>();
        List<contact> workerContacts = [SELECT Id,EmployeeNumber__c,Name FROM Contact
                                        WHERE EmployeeNumber__c =:employeeIds
                                        and recordType.Name ='Employee'];
        for(contact workerContact : workerContacts){
            employeeIdByContact.put(workerContact.EmployeeNumber__c,workerContact);
        }
       return employeeIdByContact;
    }
    
    public static  sobject populateSobjectRecs(String sobjType,Contact workerContact,Contact initiatorContact,SCC_Worker_Event__e workerEvent){
        sObject sobj;
        if(sobjType == 'WD_Worker_Event__c'){
            sobj = new WD_Worker_Event__c();
            sobj = populateWorkerEventCustomObjRecs(sobj,workerContact,initiatorContact,workerEvent);
        }

        return sobj;
    }
    public static sobject populateWorkerEventCustomObjRecs(Sobject sobj,Contact workerContact,Contact initiatorContact,SCC_Worker_Event__e workerEvent){
            
            String BPName= '';
            if(workerEvent.WD_BusProc__c != null){
                BPName = workerEvent.WD_BusProc__c;
                BPName = BPName.length()>80? BPName.substring(0,78):BPName ;//Name length is 80 max.       
                if(!String.isBlank(workerEvent.WD_BusProc_Trx_IsCorrected__c)){
                    BPName = BPName +'*'; 
                }
            }

            sobj.put('Name',BPName);
            sobj.put('Contact__c',workerContact.id);
            if(initiatorContact!=null){
               sobj.put('Initiator_Name__c',initiatorContact.Name + '(' + initiatorContact.EmployeeNumber__c + ')');//WD_BusProc_Trx_Initiator_EmpID__c

            }
            sobj.put('WD_BusProc__c',workerEvent.WD_BusProc__c);
            sobj.put('WD_BusProc_Trx_WID__c',workerEvent.WD_BusProc_Trx_WID__c);
            sobj.put('Tenant__c',workerEvent.Tenant__c);
            sobj.put('WD_BusProc_Trx_Initiator_WID__c',workerEvent.WD_BusProc_Trx_Initiator_WID__c);
			sobj.put('WD_BusProc_Trx_Worker_WID__c',workerEvent.WD_BusProc_Trx_Worker_WID__c);
			sobj.put('WD_BusProc_Trx_IsCorrected__c',workerEvent.WD_BusProc_Trx_IsCorrected__c);
			sobj.put('WD_BusProc_TrxName__c',workerEvent.WD_BusProc_TrxName__c);
      
            sobj.put('WD_BusProc_Trx_aboutWorker_EmpID_Text_CF__c',workerEvent.WD_BusProc_Trx_aboutWorker_EmpID_Text_CF__c);
            sobj.put('WD_BusProc_Trx_Datetime_Initiated__c',workerEvent.WD_BusProc_Trx_Datetime_Initiated__c == null? null :Datetime.valueOf((workerEvent.WD_BusProc_Trx_Datetime_Initiated__c).remove('Z').replace('T',' ')));
            sobj.put('WD_BusProc_Trx_EffectiveDate__c',workerEvent.WD_BusProc_Trx_EffectiveDate__c == null? null:Date.valueOf((workerEvent.WD_BusProc_Trx_EffectiveDate__c)));
            sobj.put('WD_BusProc_Trx_Initiator_EmpID__c',workerEvent.WD_BusProc_Trx_Initiator_EmpID__c);
            sobj.put('WD_BusProc_Trx_Status__c',workerEvent.WD_BusProc_Trx_Status__c );
            sobj.put('WD_BusProc_Trx_Reason__c',workerEvent.WD_BusProc_Trx_Reason__c );
            sobj.put('WD_BusProc_Trx_Category__c',workerEvent.WD_BusProc_Trx_Category__c );
            sobj.put('WD_BusProc_Trx_WID_Corr__c',workerEvent.WD_BusProc_Trx_WID_Corr__c );
            return sobj;
    }
     public static void upsertSobjectRecords(List<sobject> sobjectsToInsert){
        string errMessage;
        Schema.SObjectField workdayId = WD_Worker_Event__c.Fields.WD_BusProc_Trx_WID__c;
        List<string> errorMessages = new List<String>();
        if(!sobjectsToInsert.isEmpty()) {
            List<Database.UpsertResult > upsertResults = database.upsert(sobjectsToInsert,workdayId);
            for (Database.UpsertResult  sr : upsertResults){
                if (!sr.isSuccess()) {
                    errMessage = 'DML Error While inserting the record';
                    for (Database.Error err : sr.getErrors()) {
                        errMessage += 'and Status code is ' +err.getStatusCode()+ ' message is '+err.getMessage()+ ' fields are '+err.getfields();
                        errorMessages.add(errMessage);
                    }
                    PF_Logger.log('ESDJC','ERROR',errMessage,'DML Error',errMessage,'WD_CaseTrxnService');
                }
            }
        }
        if(!PF_Logger.logs.isEmpty()){
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }

}