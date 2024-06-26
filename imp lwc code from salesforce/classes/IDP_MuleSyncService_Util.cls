public class IDP_MuleSyncService_Util {

    private static final Integer DEFAULT_BATCH_SIZE = 2000;
    private static final String DEFAULT_EMPTY_QUERY = 'SELECT Id FROM IDP_Action__c WHERE IsDeleted__c = false AND IsDeleted__c = true';
    // This method used to hit the Mule service and update the IDP action with response
    // send the map back to batch class
    public static void processIDPActions(List<IDP_Action__c> records, Datetime batchStartTime) {
        List<IDP_Action__c> lstUpdActions = new List<IDP_Action__c>();
        Set<Id> unqIds = new Set<Id>();
        Set<Id> modifiedIds = new Set<Id>();
        
        try {
            //retrieve custom metadata values for status codes
            Map<String,String> statusMap = new Map<String,String>();
            for (WD_IDP_Status__mdt recStatus : [SELECT MasterLabel, WD_Status__c FROM WD_IDP_Status__mdt LIMIT 1000]) {
                statusMap.put(recStatus.MasterLabel, recStatus.WD_Status__c);
            }
            // retrieve the SOQL, Auth information metadata
            WD_IDP_Config__mdt configRec = [
                SELECT  EndPointUrl__c, 
                        SOQL_Query__c, 
                        client_id__c, 
                        client_secret__c 
                FROM WD_IDP_Config__mdt 
                LIMIT 1
            ];
            // prepare the json array
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            
            for (IDP_Action__c rec : records) {
                // Without a status not adding to the input json array
                if(statusMap != null && statusMap.containsKey(rec.Status__c)) {
                    String devItem = rec.IDP_Objective__r.IDP_Objective_Name__c + ' - '+rec.Action__c;
                    if(devItem.length() > 140) {
                        devItem = devItem.substring(0, 137) + '...';
                    }
                    unqIds.add(rec.Id);
                    gen.writeStartObject();
                    gen.writeStringField('salesforceID', rec.Id);
                    gen.writeStringField('employeeID', String.isBlank(rec.EmployeeNumber__c)?'':rec.EmployeeNumber__c);
                    gen.writeStringField('developmentItem', devItem);
                    if(String.isNotBlank(rec.Support__c)){
                        gen.writeStringField('additionalInformation', 'Support Needed:'+rec.Support__c);
                    }
                    gen.writeStringField('statusWID', statusMap.get(rec.Status__c));
                    if(String.isNotBlank(rec.WorkdayId__c)){
                        gen.writeStringField('developmentItemWID', rec.WorkdayId__c);
                    }
                    if(rec.Completed_Date__c != null) {
                        gen.writeDateField('completedDate', rec.Completed_Date__c);
                    }
                    gen.writeBooleanField('isDeleted', rec.isDeleted__c);
                    gen.writeEndObject();
                }
            }
            
            gen.writeEndArray();
            if(!unqIds.isEmpty()){
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setEndpoint('callout:PF_IDP');
                req.setHeader('Content-Type', 'application/json');
               /*req.setHeader('client_id', configRec.client_id__c);
                req.setHeader('client_secret', configRec.client_secret__c);
                req.setEndpoint(configRec.EndPointUrl__c);*/
                req.setTimeout(120000);
                req.setMethod('PUT');
                req.setBody(gen.getAsString());
                
                try {
                    res = http.send(req);
                } catch (Exception e) {
                    PF_Logger.log('IDP','ERROR',e.getMessage(),'Callout Error',e.getStackTraceString(),'IDP_MuleSyncService_Util');
                }
                //Check the response code first
                if(res.getStatusCode() == 200){
                    // update response back to idp action
                    List<IDP_MuleSyncService_ResponseWrapper> responseWrappers = (List<IDP_MuleSyncService_ResponseWrapper>)
                        System.JSON.deserialize(res.getBody(), List<IDP_MuleSyncService_ResponseWrapper>.class);
                    
                    for(IDP_Action__c recAct : [SELECT Id 
                                                FROM IDP_Action__c
                                                WHERE Id in :unqIds
                                                AND Lastmodifieddate >= :batchStartTime]){
                                                    modifiedIds.add(recAct.Id);
                                                }
                    
                    for(IDP_MuleSyncService_ResponseWrapper rec : responseWrappers) {
                        //If the status is Success from service then look for records which are modified after the batch
                        // Update workdayId for modified records and Update workdayId & Synced flag for all other records
                        // If the status is failure then update Sync flag to false and override error.
                        String recordId = String.escapeSingleQuotes(rec.salesforceID);
                        IDP_Action__c idpAction = new IDP_Action__c(Id = recordId);
                        
                        if(rec.status.equalsIgnoreCase('Success')) {
                            idpAction.WorkdayId__c = String.escapeSingleQuotes(rec.developmentItemWID);
                            
                            if(!modifiedIds.contains(recordId)) {
                                idpAction.Synced__c = true;
                                idpAction.SyncError__c = null;
                            }
                        } else {
                            idpAction.Synced__c = false;
                            if(String.isNotBlank(rec.message)){
                                idpAction.SyncError__c = rec.message.length() > 255
                                    ? rec.message.substring(0, 255) : rec.message;
                            }
                        }
                        
                        lstUpdActions.add(idpAction);
                    }
                    if(!lstUpdActions.isEmpty()) {
                        checkAccessToUpdate(new Map<SObjectType, List<String>> {
                            IDP_Action__c.SObjectType => new List<String> {'WorkdayId__c', 'Synced__c', 'SyncError__c'}
                        });

                        List<Database.SaveResult> updateResults = database.update(lstUpdActions);
                        for (Database.SaveResult sr : updateResults){
                            if (!sr.isSuccess()) {
                                String errMessage = '';
                                for (Database.Error err : sr.getErrors()) {
                                    errMessage += 'Status code is'+err.getStatusCode() +
                                        ' message is '+err.getMessage()+ ' fields are '+err.getfields();
                                }
                                PF_Logger.log('IDP','ERROR',errMessage,'DML Error',errMessage,'IDP_MuleSyncService_Util');
                            }
                        }
                    }
                }else{
                    PF_Logger.log('IDP','ERROR',res.getBody(),'Callout Error',String.valueOf(res.getStatusCode()),'IDP_MuleSyncService_Util');
                }
            }
        } catch (Exception e) {
            PF_Logger.log('IDP','ERROR',e.getMessage(),'Util Error',e.getStackTraceString(),'IDP_MuleSyncService_Util');
        }
        PF_Logger.createLogs(PF_Logger.logs);
    }

    public static Integer getBatchSize() {
        WD_IDP_Config__mdt config = [SELECT BatchSize__c FROM WD_IDP_Config__mdt LIMIT 1];

        return config?.BatchSize__c == null
            ? DEFAULT_BATCH_SIZE
            : Integer.valueOf(config.BatchSize__c);
    }

    public static String getQueryLocatorString() {
        WD_IDP_Config__mdt config = [SELECT SOQL_Query__c FROM WD_IDP_Config__mdt LIMIT 1];
        // In case when config is not exist; return query string with impossible condition
        return String.isBlank(config?.SOQL_Query__c)
            ? DEFAULT_EMPTY_QUERY
            : config.SOQL_Query__c;
    }

    public static void checkAccessToUpdate(Map<SObjectType, List<String>> targets) {
        for (SObjectType sot : targets.keySet()) hasUpdateAccess(sot, targets.get(sot));
    }

    private static void hasUpdateAccess(Schema.SObjectType targetType, List<String> targetFields) {
        Schema.DescribeSObjectResult sObjDesc = targetType?.getDescribe();

        if (!sObjDesc.isUpdateable()) {
            throw new AccessControlException('Context user does not have access to update "' + String.valueOf(targetType) + '" records');
        }

        Map<String, SObjectField> fieldsMap = sObjDesc.fields.getMap();

        for (String f : targetFields) {

            if (!fieldsMap.containsKey(f)) {
                throw new AccessControlException('Incorrect "'+ f +'" Field Name or it is not exists on the "' + String.valueOf(targetType) + '" SObject');
            }

            if (fieldsMap.get(f).getDescribe().isUpdateable()) continue;

            throw new AccessControlException('Context user does not have access to update "' + f + '" Field on the "' + String.valueOf(targetType) + '" SObject');
        }
    }

    public class AccessControlException extends Exception {

    }
}