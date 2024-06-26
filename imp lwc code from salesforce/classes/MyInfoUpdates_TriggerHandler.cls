public without sharing class MyInfoUpdates_TriggerHandler {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * W-11019082 (07/07/2022) : Holds the Set of Keys formed using Object API Name & Field API Name eligible for auto-approval in My Info page.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> autoApprovedObjectFieldKeys {
        get {
            if(autoApprovedObjectFieldKeys == null) {
                autoApprovedObjectFieldKeys = new Set<String>();
                for(MA_My_Info_Auto_Approved_Fields__mdt metadataRec : [SELECT Object_API_Name__c, Field_Name__c
                                                                        FROM MA_My_Info_Auto_Approved_Fields__mdt]) {
                    autoApprovedObjectFieldKeys.add((metadataRec.Object_API_Name__c + metadataRec.Field_Name__c).toLowerCase());
                }
            }
            return autoApprovedObjectFieldKeys;
        }set;
    }

    public void handler(List<MA_My_Info_Updates__c> newRecords, List<MA_My_Info_Updates__c> oldRecords, Map<Id, MA_My_Info_Updates__c> newMap, Map<Id, MA_My_Info_Updates__c> oldMap, TriggerOperation operation){
        
        switch on operation {
            when BEFORE_INSERT {
                beforeInsert(newRecords, oldRecords, newMap, oldMap);
            }
            when BEFORE_UPDATE {
                beforeUpdate(newRecords, oldRecords, newMap, oldMap);
            }
            when AFTER_INSERT{
                afterInsert(newRecords, oldRecords, newMap, oldMap);
            }
            when AFTER_UPDATE{
                afterUpdate(newRecords, oldRecords, newMap, oldMap);
            }
        }

    }

    public void beforeInsert(List<MA_My_Info_Updates__c> newRecords, List<MA_My_Info_Updates__c> oldRecords, Map<Id, MA_My_Info_Updates__c> newMap, Map<Id, MA_My_Info_Updates__c> oldMap){

        Set<String> idRecordsMyInfoPage = new Set<String>();
        Map<String, Id> idRecordMyInfoPageToIdMyInfoUpdate = new Map<String, Id>();
        List<Id> idUsersFromGroup = new List<Id>();

        for(MA_My_Info_Updates__c myInfo : newRecords){
            idRecordsMyInfoPage.add(myInfo.Record_Id__c);
            if(isAutoApprovedField(myInfo)) {
                myInfo.Status__c = 'Accepted';
            }
        }

        idUsersFromGroup = getIdUsersFromMAApproversGroup();
        idRecordMyInfoPageToIdMyInfoUpdate = getIdRecordFromInfoPageToIdOwner(idRecordsMyInfoPage);
        assignOwnerToMyInfoUpdateRecord(newRecords, idRecordMyInfoPageToIdMyInfoUpdate, idUsersFromGroup);

    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * @author - Chakshu Malhotra
	* ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
	* W-11019082 (07/07/2022) : Method to check if My Info Updates record contains an auto-approved field.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    myInfo      (Data type MA_My_Info_Updates__c, My Info Updates record)
    * @return   Boolean     DESCRIPTION (return true if the myInfo contains an auto approved field)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isAutoApprovedField(MA_My_Info_Updates__c myInfo) {
        system.debug('isAutoApprovedField****'); 
        system.debug('Object_API_Name__c****'+myInfo.Object_API_Name__c);
        system.debug('Field_Name__c****'+myInfo.Field_Name__c);
        Boolean hasObjectAndField = (myInfo.Object_API_Name__c != null && myInfo.Field_Name__c != null);
        return hasObjectAndField && autoApprovedObjectFieldKeys.contains((myInfo.Object_API_Name__c + myInfo.Field_Name__c).toLowerCase());
    }

    public void beforeUpdate(List<MA_My_Info_Updates__c> newRecords, List<MA_My_Info_Updates__c> oldRecords, Map<Id, MA_My_Info_Updates__c> newMap, Map<Id, MA_My_Info_Updates__c> oldMap){
        checkApprovalCommentsField(newMap, oldMap);
    }

    public static void checkApprovalCommentsField(Map<Id, MA_My_Info_Updates__c> newMap, Map<Id, MA_My_Info_Updates__c> oldMap) {
        List<Id> processInstanceIds = new List<Id>{};
        
        for (MA_My_Info_Updates__c myInfos : [SELECT (SELECT ID
                                                FROM ProcessInstances
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1)
                                        FROM MA_My_Info_Updates__c
                                        WHERE ID IN :newMap.keySet()]) {
            if(myInfos.ProcessInstances.size() > 0) {
                processInstanceIds.add(myInfos.ProcessInstances[0].Id);
            }
        }
        for (ProcessInstance pi : [SELECT TargetObjectId,
                                    (SELECT Id, StepStatus, Comments 
                                        FROM Steps
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1 )
                                FROM ProcessInstance
                                WHERE Id IN :processInstanceIds
                                ORDER BY CreatedDate DESC]) {                   
            if (String.isBlank(pi.Steps[0].Comments) && newMap.get(pi.TargetObjectId).Status__c == 'Rejected' && oldMap.get(pi.TargetObjectId).Status__c != 'Rejected') {
                newMap.get(pi.TargetObjectId).addError(System.Label.MA_Msg_Please_Enter_a_Comment);
            } else if(String.isNotBlank(pi.Steps[0].Comments) && !newMap.get(pi.TargetObjectId).Mass_Approval__c && !newMap.get(pi.TargetObjectId).Mass_Rejection__c) {
                newMap.get(pi.TargetObjectId).Approver_Comments__c = pi.Steps[0].Comments;
            }
        }  
    }

    public void afterInsert(List<MA_My_Info_Updates__c> newRecords, List<MA_My_Info_Updates__c> oldRecords, Map<Id, MA_My_Info_Updates__c> newMap, Map<Id, MA_My_Info_Updates__c> oldMap){
        List<MA_My_Info_Updates__c> requestsToSubmit = new List<MA_My_Info_Updates__c>();
        List<MA_My_Info_Updates__c> autoApprovedRecords = new List<MA_My_Info_Updates__c>();

        for(MA_My_Info_Updates__c myInfo : newRecords){
            Boolean isAutoApprovedField = isAutoApprovedField(myInfo);
            
            if(myInfo.Status__c == 'Submit' && (myInfo.New_Value__c != myInfo.Old_Value__c) && !isAutoApprovedField){
                requestsToSubmit.add(myInfo);
            }
            system.debug('requestsToSubmit**** '+requestsToSubmit);
            if(isAutoApprovedField) {
                autoApprovedRecords.add(myInfo);
            }
            system.debug('autoApprovedRecords**** '+autoApprovedRecords);
        }
        if(requestsToSubmit.size() > 0){
            submitForApproval(requestsToSubmit);
        }

        /*
        * W-10217413
        * Add flexibility to auto-approve data change requests that flow through the My Info Updates object
        * 
        * Version      Date            Author                  Description
        * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        * v1.0         18/12/2021      Priyanka Kanani       Auto Approved Home Address Fields for Myinfo Page
        * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        */

        if(!autoApprovedRecords.isEmpty()) {
            Map<String, sObject> idRecordWithRecordToUpdate = getIdRecordWithRecordToUpdate(autoApprovedRecords);
            if(!idRecordWithRecordToUpdate.isEmpty()) {
                update idRecordWithRecordToUpdate.values(); 
             }
             notifyAutoApprovedUpdatesToUser(autoApprovedRecords);
        }
    }

    private void notifyAutoApprovedUpdatesToUser(List<MA_My_Info_Updates__c> infoUpdates) {
        String notificationMsg = '';
        for(MA_My_Info_Updates__c infoUpdate : infoUpdates) {
            notificationMsg += String.isBlank(notificationMsg) ? '' : ', ';
            notificationMsg += infoUpdate.Field_Label__c;
        }

        notificationMsg += ' ' + System.Label.MA_Msg_has_been_updated;
        notifyUser(infoUpdates[0].CreatedById, 'Approve', notificationMsg);
    }

    public void afterUpdate(List<MA_My_Info_Updates__c> newRecords, List<MA_My_Info_Updates__c> oldRecords, Map<Id, MA_My_Info_Updates__c> newMap, Map<Id, MA_My_Info_Updates__c> oldMap){
        approveRecord(newRecords, oldMap);
        checkPendingApprovalProcess(newRecords, oldMap);
        
    }

    public static void submitForApproval(List<MA_My_Info_Updates__c> records){
        List<Approval.ProcessSubmitRequest> processRequests = new List<Approval.ProcessSubmitRequest>();
        String oldValue;
        String newValue;
        for(MA_My_Info_Updates__c myInfo : records){
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            oldValue = myInfo.Old_Value__c != null ? myInfo.Old_Value__c : 'NO VALUE';
            newValue = myInfo.New_Value__c != null ? myInfo.New_Value__c : 'NO VALUE';
            request.setComments(myInfo.Field_Label__c + ' ' + System.Label.MA_Msg_has_been_updated);
            request.setObjectId(myInfo.Id);
            request.setProcessDefinitionNameOrId('MyInfoUpdateApprovalProcess');
            request.setNextApproverIds(new Id[] {myInfo.OwnerId});
            processRequests.add(request);

        }

        Approval.process(processRequests);
    }

    public static void approveRecord(List<MA_My_Info_Updates__c> newRecords, Map<Id, MA_My_Info_Updates__c> oldMap){
        List<MA_My_Info_Updates__c> approvedRecords = getApprovedMyInfoUpdateRecords(newRecords, oldMap);        
        Map<String, sObject> idRecordWithRecordToUpdate = getIdRecordWithRecordToUpdate(approvedRecords);
        if(idRecordWithRecordToUpdate.size() > 0) {
           update idRecordWithRecordToUpdate.values(); 
        }
    }

    public static void checkPendingApprovalProcess(List<MA_My_Info_Updates__c> newRecords, Map<Id, MA_My_Info_Updates__c> oldMap){
        Map<Id, MA_My_Info_Updates__c> mapOfIdVsMyInfoUpdatesReadyToReject = new Map<Id, MA_My_Info_Updates__c>();
        Map<Id, MA_My_Info_Updates__c> mapOfIdVsMyInfoUpdatesReadyToApprove = new Map<Id, MA_My_Info_Updates__c>();

        for(MA_My_Info_Updates__c myInfoUpdates : newRecords){
            MA_My_Info_Updates__c oldInfo = oldMap?.get(myInfoUpdates.Id);
            String comments;
            
            if(myInfoUpdates.Mass_Approval__c && (myInfoUpdates.Mass_Approval__c != oldInfo?.Mass_Approval__c)){
                
                mapOfIdVsMyInfoUpdatesReadyToApprove.put(myInfoUpdates.Id, myInfoUpdates);
            } else if (myInfoUpdates.Status__c != oldMap?.get(myInfoUpdates.Id).Status__c && myInfoUpdates.Status__c == 'Accepted' && !myInfoUpdates.Mass_Approval__c) {
                comments = String.isNotBlank(myInfoUpdates.Approver_Comments__c) ? myInfoUpdates.Approver_Comments__c : myInfoUpdates.Field_Label__c + ' ' + System.Label.MA_Msg_has_been_updated;
                notifyUser(myInfoUpdates.CreatedById, 'Approve', comments);
            }
            if(myInfoUpdates.Mass_Rejection__c == true && (myInfoUpdates.Mass_Rejection__c != oldInfo?.Mass_Rejection__c)){
                mapOfIdVsMyInfoUpdatesReadyToReject.put(myInfoUpdates.Id, myInfoUpdates);
            } else if (myInfoUpdates.Status__c != oldMap?.get(myInfoUpdates.Id).Status__c && myInfoUpdates.Status__c == 'Rejected' && !myInfoUpdates.Mass_Rejection__c) {
                comments = String.isNotBlank(myInfoUpdates.Approver_Comments__c) ? myInfoUpdates.Approver_Comments__c : myInfoUpdates.Field_Label__c + ' ' + System.Label.MA_Msg_has_been_updated;
                notifyUser(myInfoUpdates.CreatedById, 'Reject', comments);
            }
        }
        if(!mapOfIdVsMyInfoUpdatesReadyToApprove.isEmpty()){
            closeApprovalProcesses(mapOfIdVsMyInfoUpdatesReadyToApprove, 'Approve');
        }
        if(!mapOfIdVsMyInfoUpdatesReadyToReject.isEmpty()){
            closeApprovalProcesses(mapOfIdVsMyInfoUpdatesReadyToReject, 'Reject');
        }
    }

    public static void closeApprovalProcesses(Map<Id, MA_My_Info_Updates__c> mapOfIdVsMyInfoUpdatesRecords, String response){
        Map<Id, MA_My_Info_Updates__c> mapOfProcessWorkItemIdVsMyInfoUpdates = new Map<Id, MA_My_Info_Updates__c>();

        Map<Id, ProcessInstance> mapOfIdVsProcessInstance = getPendingProcessInstancesById(mapOfIdVsMyInfoUpdatesRecords.keySet());
        List<ProcessInstanceWorkitem> processInstanceWorkItemRequests = getProcessWorkitemRequests(mapOfIdVsProcessInstance.keySet());

        for(ProcessInstanceWorkitem processInstanceWorkitem : processInstanceWorkItemRequests) {
            mapOfProcessWorkItemIdVsMyInfoUpdates.put(processInstanceWorkitem.Id, mapOfIdVsMyInfoUpdatesRecords.get(mapOfIdVsProcessInstance.get(processInstanceWorkitem.ProcessInstanceId).TargetObjectId));
        }
        responseApprovalProcess(mapOfProcessWorkItemIdVsMyInfoUpdates, response, mapOfIdVsProcessInstance);
        
    }

    public static List<Id> getIdUsersFromMAApproversGroup(){
        List<Id> idUsersFromGroup = new List<Id>();
        for(GroupMember member : [SELECT GroupId, Id, UserOrGroupId FROM GroupMember where Group.DeveloperName = 'MA_Approvers']){
            idUsersFromGroup.add(member.UserOrGroupId);
        }
        return idUsersFromGroup;
    }

    public static Map<String, Id> getIdRecordFromInfoPageToIdOwner(Set<String> idRecordsMyInfoPage){
        Map<String, Id> idRecordMyInfoPageToIdMyInfoUpdate = new Map<String, Id>();

        for(MA_My_Info_Updates__c myInfo : [SELECT Id, Name, Status__c, Record_Id__c, OwnerId FROM MA_My_Info_Updates__c WHERE Status__c = 'Submit' AND Record_Id__c IN :idRecordsMyInfoPage]){
            idRecordMyInfoPageToIdMyInfoUpdate.put(myInfo.Record_Id__c, myInfo.OwnerId);
        }

        return idRecordMyInfoPageToIdMyInfoUpdate;
    }

    public static void assignOwnerToMyInfoUpdateRecord(List<MA_My_Info_Updates__c> newRecords, Map<String, Id> idRecordMyInfoPageToIdMyInfoUpdate, List<Id> idUsersFromGroup){

        try {
            Integer randomNumber = Integer.valueof((math.random()*1000));
            Integer indexList = math.mod(randomNumber,idUsersFromGroup.size());
            system.debug('idRecordMyInfoPageToIdMyInfoUpdate*** '+idRecordMyInfoPageToIdMyInfoUpdate);
            for(MA_My_Info_Updates__c myInfo : newRecords){
                if(idRecordMyInfoPageToIdMyInfoUpdate.containsKey(myInfo.Record_Id__c) && idUsersFromGroup.contains(myInfo.OwnerId)){
                    myInfo.OwnerId = idRecordMyInfoPageToIdMyInfoUpdate.get(myInfo.Record_Id__c);
                }else{      
                    myInfo.OwnerId = idUsersFromGroup.get(indexList); 
                }
                system.debug('idUsersFromGroup*** '+idUsersFromGroup);
                system.debug('myInfo.OwnerId*** '+myInfo.OwnerId);
            }
        }catch(Exception e) {
            System.debug('Exception caught: ' + e.getMessage() + ' Stack trace: '+e.getStackTraceString());
        }
    }

    public static List<MA_My_Info_Updates__c> getApprovedMyInfoUpdateRecords(List<MA_My_Info_Updates__c> newRecords, Map<Id, MA_My_Info_Updates__c> oldMap){
        List<MA_My_Info_Updates__c> approvedRecords = new List<MA_My_Info_Updates__c>();
        for(MA_My_Info_Updates__c myInfo : newRecords){
            MA_My_Info_Updates__c oldInfo = oldMap.get(myInfo.Id);
            if(myInfo.Status__c == 'Accepted' && oldInfo.Status__c != 'Accepted'){
                approvedRecords.add(myInfo);
            }
        }
        return approvedRecords;
    }

    public static Map<String, sObject> getIdRecordWithRecordToUpdate(List<MA_My_Info_Updates__c> approvedRecords){
        
        Map<String, sObject> idRecordWithRecordToUpdate = new Map<String, sObject>();
        try {
            for(MA_My_Info_Updates__c myInfo : approvedRecords) {

                if(!idRecordWithRecordToUpdate.containsKey(myInfo.Record_Id__c)){
                    sObject recordToUpdate = Schema.getGlobalDescribe().get(myInfo.Object_API_Name__c).newSObject();
                    recordToUpdate.Id = myInfo.Record_Id__c;
                    recordToUpdate = castingValuesForSobject(recordToUpdate, myInfo);
                    idRecordWithRecordToUpdate.put(myInfo.Record_Id__c, recordToUpdate);
                }else{
                    sObject recordToUpdate = idRecordWithRecordToUpdate.get(myInfo.Record_Id__c);
                    recordToUpdate = castingValuesForSobject(recordToUpdate, myInfo);
                    idRecordWithRecordToUpdate.put(myInfo.Record_Id__c, recordToUpdate);
                    
                }
            }
        }catch(Exception e) {
            System.debug('Exception caught: ' + e.getMessage() + ' Stack trace: '+e.getStackTraceString());
        }
        return idRecordWithRecordToUpdate;
    }

    public static Map<Id, ProcessInstance> getPendingProcessInstancesById(Set<Id> idRecords){
        return new Map<Id, ProcessInstance>([SELECT Id, Status, TargetObjectId FROM ProcessInstance WHERE Status='Pending' AND TargetObjectId IN :idRecords]);
    }

    public static List<ProcessInstanceWorkitem> getProcessWorkitemRequests(Set<Id> idProcessInstance){
        return [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN :idProcessInstance];
    }

    public static void responseApprovalProcess(Map<Id, MA_My_Info_Updates__c> mapOfProcessWorkItemIdVsMyInfoUpdates, String response,  Map<Id, ProcessInstance> mapOfIdVsProcessInstance){
        Map<String, List<MA_My_Info_Updates__c>> mapOfRecipientIdVsListMyInfoUpdates = new Map<String, List<MA_My_Info_Updates__c>>();
        String comments = '';
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>(); 
 
        for (Id processInstanceWI : mapOfProcessWorkItemIdVsMyInfoUpdates.keySet()){
            if (mapOfRecipientIdVsListMyInfoUpdates.containsKey(mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI).CreatedById)) {
                mapOfRecipientIdVsListMyInfoUpdates.get(mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI).CreatedById).add(mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI));
            } else {
                mapOfRecipientIdVsListMyInfoUpdates.put(mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI).CreatedById, new List<MA_My_Info_Updates__c>{mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI)});
            }
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            if (String.isNotBlank(mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI).Approver_Comments__c)) {
                comments = mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI).Approver_Comments__c;
                request.setComments(mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI).Approver_Comments__c);
            } else {
                comments = mapOfProcessWorkItemIdVsMyInfoUpdates.get(processInstanceWI).Field_Label__c + ' ' + System.Label.MA_Msg_has_been_updated;
            }
            
            request.setAction(response); 
            request.setWorkitemId(processInstanceWI);
            approvalRequestList.add(request);
        }

        if(!approvalRequestList.isEmpty()){
            Approval.ProcessResult[] result =  Approval.process(approvalRequestList);
        }
        if (!mapOfRecipientIdVsListMyInfoUpdates.isEmpty()) {
            for (String recipientId : mapOfRecipientIdVsListMyInfoUpdates.keySet()) {
                String massComments = '';
                for (MA_My_Info_Updates__c myInfos : mapOfRecipientIdVsListMyInfoUpdates.get(recipientId)) {
                    if (String.isNotBlank(myInfos.Approver_Comments__c)) {
                        massComments = myInfos.Approver_Comments__c;
                        break;
                    } else {
                        massComments = massComments == '' ? myInfos.Field_Label__c + ' ' + System.Label.MA_Msg_has_been_updated : myInfos.Field_Label__c + ', ' + massComments;
                    }
                }
                notifyUser(recipientId, response, massComments);
            }
        }
    }

    public static void notifyUser(String recipientId, String response, String comments) {

        String titleStatus = response == 'Approve' ? 'Approved' : 'Rejected';
 
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='My_Info_Updates_Approval_Notification'];
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
 
        notification.setTitle(String.format(System.Label.MA_Msg_Your_info_change_request_has_been, new String[]{titleStatus}));
        notification.setBody(String.isNotBlank(comments) ? comments : String.format(System.Label.MA_Msg_Your_info_change_request_has_been, new String[]{titleStatus}));
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetPageRef(
            '{type: \'comm__namedPage\',attributes: {name: \'myinfo__c\'}}'
        );
        
        try {
            notification.send(new Set<String>{recipientId});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
        
    }

    public static sObject castingValuesForSobject(sObject recordToUpdate, MA_My_Info_Updates__c myInfoRecord){

        String objectType = myInfoRecord.Object_API_Name__c;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        Schema.DisplayType fieldDataType = fieldMap.get(myInfoRecord.Field_Name__c).getDescribe().getType();

        switch on fieldDataType {
            when CURRENCY, DOUBLE, PERCENT {
                recordToUpdate.put(myInfoRecord.Field_Name__c, Double.valueOf(myInfoRecord.New_Value__c));
            }
            when BOOLEAN {
                recordToUpdate.put(myInfoRecord.Field_Name__c, Boolean.valueOf(myInfoRecord.New_Value__c));
            }
            when DATE {
                recordToUpdate.put(myInfoRecord.Field_Name__c, Date.valueOf(myInfoRecord.New_Value__c));
            }
            when DATETIME {
                recordToUpdate.put(myInfoRecord.Field_Name__c, Datetime.valueOf(myInfoRecord.New_Value__c));
            }
            when INTEGER {
                recordToUpdate.put(myInfoRecord.Field_Name__c, Integer.valueOf(myInfoRecord.New_Value__c));
            }
            when LONG {
                recordToUpdate.put(myInfoRecord.Field_Name__c, Long.valueOf(myInfoRecord.New_Value__c));
            }
            when TIME {
                String[] stringTimeSplit = myInfoRecord.New_Value__c.split(':');
                Time timeValue = Time.newInstance( Integer.valueOf(stringTimeSplit[0]) ,Integer.valueOf(stringTimeSplit[1]),0 ,0);  
                recordToUpdate.put(myInfoRecord.Field_Name__c, timeValue);
            }
            when else{
                recordToUpdate.put(myInfoRecord.Field_Name__c, myInfoRecord.New_Value__c);
            }
        }

        return recordToUpdate;
    }
}