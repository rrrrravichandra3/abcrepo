public  with sharing class  ESDJC_Reimbursement_Integrations_Service {
    public static PF_Batch_Job_Tune_Config__mdt claimConfig = [Select Retry_Soql_Query__c,Email_Addresses_for_Exceptions__c,Batch_Size__c,SOQL_Query__c,Time_Out__c from PF_Batch_Job_Tune_Config__mdt Limit 1];
    public static PF_Batch_Job_Tune_Config__mdt caseConfig = [Select Batch_Size__c, SOQL_Query__c from PF_Batch_Job_Tune_Config__mdt Limit 1];
    public static final String APPLICATION_NAME = 'ESDJC';
    public static final String COMPONENT_NAME = 'Reimbursement Integration';
    public static List<PF_Debug_Log__c> pflogs = new List<PF_Debug_Log__c>();

    public Static Set<Id> processClaims(List<DJC_Wellness_Reimbursement_Claim__c> claims){
        Set<Id> processedClaimIds = new Set<Id>();
        List<DJC_Wellness_Reimbursement_Claim__c> claimsAfterRemovalofProcessedIds = removeProcessedClaims(claims);
        List<ESDJC_WDPayroll_Service.ReimbursementPapiRequestClaimWrapper> claimWrappers = prepareRequestsToWDReimbursementPAPI(claimsAfterRemovalofProcessedIds);
        List<ESDJC_WDPayroll_Service.ReimbursementPapiResponseClaimWrapper> responseWrappers = ESDJC_WDPayroll_Service.calloutToWDReimbursementPAPI(claimWrappers);
        if(!responseWrappers.isEmpty()){
           processedClaimIds = updateReimbursementClaims(responseWrappers);
        }
        return processedClaimIds;
    } 
    public static List<ESDJC_WDPayroll_Service.ReimbursementPapiRequestClaimWrapper> prepareRequestsToWDReimbursementPAPI(List<DJC_Wellness_Reimbursement_Claim__c> claims){
        Map<String,String> mPolicyCatToWDCode = ESDJC_Reimbursement_Integrations_Service.getWorkdayCode();
        List<ESDJC_WDPayroll_Service.ReimbursementPapiRequestClaimWrapper> ReimbursementPapiRequestClaimWrappers = new List<ESDJC_WDPayroll_Service.ReimbursementPapiRequestClaimWrapper>();
        for (DJC_Wellness_Reimbursement_Claim__c claim : claims) {
            ESDJC_WDPayroll_Service.ReimbursementPapiRequestClaimWrapper claimWrapperObj = new ESDJC_WDPayroll_Service.ReimbursementPapiRequestClaimWrapper();
            claimWrapperObj.uniqueId = claim.id;
            claimWrapperObj.employeeId  = claim.DJC_Wellness_Case__r.contact.EmployeeNumber__c;
            claimWrapperObj.effectiveDate = claim.DJC_Wellness_Case__r.Type == 'Education Reimbursement Request'?claim.DJC_Education_Date_Completed__c:claim.DJC_Wellness_Start_Date_of_Activity__c;
            claimWrapperObj.amount = (claim.CurrencyISOCode!= claim.DJC_Wellness_Case__r.CurrencyISOCode)?DJC_Wellness_Util.getConvertedCurrency(claim, claim.DJC_Wellness_Case__r.CurrencyIsoCode): claim.DJC_Wellness_Amount_Requested__c;
            claimWrapperObj.claimCurrency = claim.DJC_Wellness_Case__r.CurrencyIsoCode;
            claimWrapperObj.isTaxable = claim.DJC_Education_Taxable__c;
            claimWrapperObj.region = (claim.DJC_Wellness_Case__r.contact.Geo_Region__c == 'Japan' && claim.DJC_Wellness_Case__r.contact.MailingCountry == 'KR') ? 'APAC':claim.DJC_Wellness_Case__r.contact.Geo_Region__c;
            claimWrapperObj.reimbursementName  = mPolicyCatToWDCode.get(claim.DJC_Wellness_Case__r.Reimbursement_Category_Id__c.intValue() + '#' +claim.DJC_Wellness_Case__r.Reimbursement_Policy_Id__c.intValue());
            if(claimWrapperObj.employeeId!=null && claimWrapperObj.effectiveDate !=null && claimWrapperObj.amount!=null && claimWrapperObj.claimCurrency!=null && claimWrapperObj.region!=null && claimWrapperObj.reimbursementName!=null){
                ReimbursementPapiRequestClaimWrappers.add(claimWrapperObj);
            }else{
                PF_Logger.logWithRecIdAndOrCompKey(APPLICATION_NAME,'ERROR','PayLoad Data had null values Please Check the claim records','PayLoad With Null values','PayLoad Data had null values Please Check the claim records',COMPONENT_NAME,claim.id,claim.id);
            }
        }
        return ReimbursementPapiRequestClaimWrappers;
    }
    public static Set<Id> updateReimbursementClaims(List<ESDJC_WDPayroll_Service.ReimbursementPapiResponseClaimWrapper> responseWrappers){
        String errDesc;
        Set<Id> processedClaimIds = new Set<Id>();
        List<DJC_Wellness_Reimbursement_Claim__c> lstUpdateClaims = new List<DJC_Wellness_Reimbursement_Claim__c>();
        List<string> errDescs = new List<String>();
        for(ESDJC_WDPayroll_Service.ReimbursementPapiResponseClaimWrapper rec : responseWrappers) {
            String claimId = String.escapeSingleQuotes(rec.uniqueId);
            errDesc = '';
            if(claimId != null){
                DJC_Wellness_Reimbursement_Claim__c  claimRec = new DJC_Wellness_Reimbursement_Claim__c (Id = claimId);
                if(rec.code == 201) {
                    claimRec.Integration_Status__c = 'Closed';
                    lstUpdateClaims.add(claimRec);
                } else {
                    errDesc += 'Claim Id ' +claimId+ 'please check the error status ' +rec.status+ 'Retry this claims';
                    //Claim errored on WD side.Upserting the log rec as we do not want the error to duplicate until fixed.
                    String CompositeKey = claimId + ' - ' + String.valueOf(rec.code);
                    PF_Logger.logWithRecIdAndOrCompKey(APPLICATION_NAME,'ERROR',rec.status,String.valueOf(rec.code),errDesc,COMPONENT_NAME,claimId,CompositeKey);
                }
            }
        }
        if(!lstUpdateClaims.isEmpty()) {
            List<Database.SaveResult> updateResults = database.update(lstUpdateClaims,false);
            for (Database.SaveResult sr : updateResults){
                if (sr.isSuccess()) {
                    processedClaimIds.add(sr.getId());    
                }else{
                    errDesc = System.Label.ReimburseClaimDMLerror;
                    for (Database.Error err : sr.getErrors()) {
                        errDesc += 'and Status code is ' +err.getStatusCode()+ ' message is '+err.getMessage()+ ' fields are '+err.getfields();
                        errDescs.add(errDesc);
                         //Something happened to this claim on PF claim triggers side.This error will not duplicate as it will be skipped after one run.So Only Insert.
                        PF_Logger.logWithRecIdAndOrCompKey(APPLICATION_NAME,'ERROR',err.getMessage(),'DML Error',errDesc,COMPONENT_NAME,sr.getId(),null);
                    }
                }
            }
            if(!errDescs.isEmpty()){
                sendExceptionMail(errDescs);      
            }
        } 
        return  processedClaimIds;
    }
    public static void sendExceptionMail(List<String> errorMessages) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = claimConfig.Email_Addresses_for_Exceptions__c.split(',');
        mail.setToAddresses(toAddresses);
        mail.setSubject('Error from ' + UserInfo.getOrganizationName() + ' with Org Id ' + UserInfo.getOrganizationId());
        String emailBody = String.join(errorMessages, '\n');
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        
    }  
    public static Set<Id> getCaseIdsToClose(Set<Id> processedClaimIds){
        Set<id> caseIdsForTheClaims = new Set<id>();
        Set<Id> caseIdsForUpdate = new Set<Id>();
        Integer count = 0;
        List<DJC_Wellness_Reimbursement_Claim__c> claimsWithCaseids = [Select Id,DJC_Wellness_Case__r.Id
                                                                       FROM DJC_Wellness_Reimbursement_Claim__c 
                                                                       WHERE id=:processedClaimIds];
        for(DJC_Wellness_Reimbursement_Claim__c claim :claimsWithCaseids){
            caseIdsForTheClaims.add(claim.DJC_Wellness_Case__r.Id);

        }
        Map<id,List<DJC_Wellness_Reimbursement_Claim__c>> caseidByClaims = new  Map<id,List<DJC_Wellness_Reimbursement_Claim__c>>();
        //Get all the claims  for the cases
        List<DJC_Wellness_Reimbursement_Claim__c> claimsForAllTheCasesThatProcessed = [Select Id,DJC_Wellness_Case__r.Id,Integration_Status__c,DJC_Wellness_Request_Status__c
                                                                                       FROM DJC_Wellness_Reimbursement_Claim__c 
                                                                                       WHERE DJC_Wellness_Case__r.Id =:caseIdsForTheClaims];
        for(DJC_Wellness_Reimbursement_Claim__c claim :claimsForAllTheCasesThatProcessed){
            if(caseidByClaims.containsKey(claim.DJC_Wellness_Case__r.Id)){
                caseidByClaims.get(claim.DJC_Wellness_Case__r.Id).add(claim);
            }else{
                caseidByClaims.put(claim.DJC_Wellness_Case__r.Id,new List<DJC_Wellness_Reimbursement_Claim__c>{ claim });
            }

        } 
        for(id caseid : caseIdsForTheClaims){
            count = 0;
            for(DJC_Wellness_Reimbursement_Claim__c reimbursementClaim : caseidByclaims.get(caseid)) {
                //We are looking for the rejected status because there will be scenario where one claim is rejected and other claims approved so we need to close that case
                if(reimbursementClaim.Integration_Status__c == 'Closed' || reimbursementClaim.DJC_Wellness_Request_Status__c == 'Rejected' ){
                    count++;
                }
            }
            if(count == caseidByclaims.get(caseid).size()){
                caseIdsForUpdate.add(caseid);
            }
        }
        return caseIdsForUpdate;
    }

    Public static void updateCaseStatus(List<case> casesToBeUpdated){
        string errDesc;
        for (Case caseToBeUpdated : casesToBeUpdated) {
		            caseToBeUpdated.Status = 'Closed';
		        }
        if(!casesToBeUpdated.isEmpty()) {
            List<Database.SaveResult> updateResults = database.update(casesToBeUpdated,false);
            for (Database.SaveResult sr : updateResults){
                if (!sr.isSuccess()) {
                    errDesc = 'Update to Closed status on the reimbursement case record' + sr.getId()+  'failed';
                    for (Database.Error err : sr.getErrors()) {
                        errDesc += 'and the Status code is'+err.getStatusCode() +' message is '+err.getMessage()+ ' fields are '+err.getfields();
                         //Something happened to this claim on PF case triggers side.This error will not duplicate as it will be skipped from next run.So Only Insert.
                        PF_Logger.logWithRecIdAndOrCompKey(APPLICATION_NAME,'ERROR',err.getMessage(),'DML Error',errDesc,COMPONENT_NAME,sr.getId(),null);
                    }
                }
            }
           
        }
    }
    public static List<DJC_Wellness_Reimbursement_Claim__c> removeProcessedClaims(List<DJC_Wellness_Reimbursement_Claim__c> claims){
        Set<id> claimIds = new Set<id>();
        List<DJC_Wellness_Reimbursement_Claim__c> claimRecords = new List<DJC_Wellness_Reimbursement_Claim__c>();
        String errorCode= System.Label.ReimburseClaimAPIerror;
        List<PF_Debug_Log__c> caseIdFromLogs = [SELECT Id,Record_Id__c FROM PF_Debug_Log__c WHERE Application__c=:APPLICATION_NAME and Component__c=:COMPONENT_NAME and  Error_Type__c=:errorCode];
        if(!caseIdFromLogs.isEmpty()){
            for(PF_Debug_Log__c pflog : caseIdFromLogs){
                claimIds.add(pflog.Record_Id__c);
            }
        }
        if(!claims.isEmpty() && !claimIds.isEmpty()){
            for(DJC_Wellness_Reimbursement_Claim__c claimRecord :claims ){
                if(!claimIds.contains(claimRecord.Id)){
                    claimRecords.add(claimRecord);
                }
            }
           return claimRecords; 
        }else{
           return claims; 
        }
    }
    public static Map<String,String> getWorkdayCode() {
        Map<String,String> mPolicyCatToWDCode = new Map<String,String>();
        for (Reimbursement_Category_Policy_Assoc__mdt assn : [Select Workday_PCI__c, Category_Id__c, Policy_Id__c
                                                              from Reimbursement_Category_Policy_Assoc__mdt]) {
                                                                 
                                                                  mPolicyCatToWDCode.put(assn.Category_Id__c.intValue() + '#' +assn.Policy_Id__c.intValue(),assn.Workday_PCI__c);

                                                              }
        return mPolicyCatToWDCode;
    }
    
    
    
}