public with sharing class WDCommunications_To_Task_BatchHandler {
  Id contactCandidateRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('WDR_Candidate')
    .getRecordTypeId();
  /**
   * Determines the emails of users that have the Executive Recruiter Permission Set.
   */
  public static Set<String> execRecruiterEmails {
    get {
      if (execRecruiterEmails == null || execRecruiterEmails.size() == 0) {
        execRecruiterEmails = new Set<String>();

        for (User u : CEMCI_Util.getUsersWithCustomPermission('CEMCI_Executive_Recuiter')) {
          execRecruiterEmails.add(u.Email);
        }
      }
      return execRecruiterEmails;
    }
    set;
  }

  public void processRecords(list<WD_Communication__c> scope, Confidential_WD_Candidate_Fields__mdt batchSetting) {
    List<Task> taskList = new List<Task>();
    set<string> senderEmailSet = new Set<string>();
    set<string> recipientEmailset = new Set<string>();
    Map<string, User> usermap = new Map<String, User>();
    Map<string, List<Contact>> conmap = new Map<String, List<Contact>>();
    Map<string, List<Lead>> leadmap = new Map<String, List<Lead>>();
    List<WD_Communication__c> actualCommunicationRecords = new List<WD_Communication__c>();
    List<Field_Mapping__mdt> fieldMappingList = [
      SELECT
        From_Field__c,
        From_Object__c,
        To_Field__c,
        To_Object__c,
        Is_Active__c,
        Mapping_Category__c,
        To_Length_Limit__c
      FROM Field_Mapping__mdt
      WHERE
        From_Object__c = :Schema.SObjectType.WD_Communication__c.getName()
        AND To_Object__c = :Schema.SObjectType.Task.getName()
        AND Mapping_Category__c = 'CEMCI'
        AND Is_Active__c = TRUE
    ];
    List<WDCommunications_Field_Mapping__mdt> wdcommMappingList = [
      SELECT MasterLabel, Mapping_Value__c
      FROM WDCommunications_Field_Mapping__mdt
      WHERE Active__c = TRUE
    ];
    for (WD_Communication__c wdc : scope) {
      if (string.isNotBlank(wdc.Reply_To__c) && string.isNotBlank(wdc.Recipients_Email__c)) {
        List<String> replyToEmails = wdc.Reply_To__c.split(';');
        senderEmailSet.add(replyToEmails[0]);
        recipientEmailset.add(wdc.Recipients_Email__c);
        actualCommunicationRecords.add(wdc);
      }
    }
    try {
      if (!recipientEmailset.isEmpty()) {
        //Order Query by Confidential DESC so the records where confidential = true come first
        for (Contact con : [
          SELECT Id, Email, Confidential__c
          FROM Contact
          WHERE Email IN :recipientEmailset AND RecordTypeID = :contactCandidateRecordTypeId
          ORDER BY Confidential__c DESC
        ]) {
          if (!conmap.containsKey(con.Email))
            conmap.put(con.Email, new List<Contact>{ con });
          else if (conmap.get(con.Email) != null)
            conmap.get(con.Email).add(con);
        }
        //Order Query by Confidential DESC so the records where confidential = true come first
        for (Lead led : [
          SELECT id, Email, Confidential__c
          FROM Lead
          WHERE Email IN :recipientEmailset
          ORDER BY Confidential__c DESC
        ]) {
          if (!leadmap.containsKey(led.Email))
            leadmap.put(led.Email, new List<Lead>{ led });
          else if (leadmap.get(led.Email) != null)
            leadmap.get(led.Email).add(led);
        }
      }
      if (!senderEmailSet.isEmpty()) {
        String userQuery = batchSetting.List_of_Fields__c;
        for (User us : Database.Query(userQuery)) {
          if (!usermap.containsKey(us.Email))
            usermap.put(us.Email, us);
        }
      }
      if (!usermap.isEmpty()) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Task');

        for (WD_Communication__c wdc : actualCommunicationRecords) {
          sObject comm = wdc;
          string replyToValue = string.valueOf(comm.get(Label.WdComms_Reply_To_Field_Name_Label));
          List<String> replyToEmails = replyToValue.split(';');
          String replyTo = replyToEmails[0];
          string recipientEmail = string.valueOf(comm.get(Label.WDComms_Recipients_Email_Field_Name_Label));
          if (
            (usermap.containsKey(replyTo) && usermap.get(replyTo) <> null) &&
            ((!conmap.isEmpty() && conmap.containsKey(recipientEmail)) ||
            (!leadmap.isEmpty() && leadmap.containsKey(recipientEmail)))
          ) {
            Task tsk = (Task) targetType.newSObject();
            for (Field_Mapping__mdt mapping : fieldMappingList) {
              Object data = comm.get(mapping.From_Field__c);
              //Truncate if value longer than CRM field length
              if (mapping.To_Length_Limit__c != null && data != null) {
                String dataValue = String.valueOf(data);
                dataValue = dataValue.length() > mapping.To_Length_Limit__c
                  ? dataValue.left(Integer.valueOf(mapping.To_Length_Limit__c))
                  : dataValue;
                data = dataValue;
              }
              tsk.put(mapping.To_Field__c, data);
            }
            for (WDCommunications_Field_Mapping__mdt commmapping : wdcommMappingList) {
              tsk.put(commmapping.MasterLabel, commmapping.Mapping_Value__c);
            }
            tsk.put('OwnerId', usermap.get(replyTo).Id);
            if (conmap.containsKey(recipientEmail)) {
              populateWhoId(tsk, conmap, usermap, replyTo, recipientEmail);
            } else {
              populateWhoId(tsk, leadmap, usermap, replyTo, recipientEmail);
            }
            if (tsk.WhoId != null) {
              taskList.add(tsk);
            }
          }
        }
      }
      if (taskList <> null && !taskList.isEmpty()) {
        Database.SaveResult[] srList = Database.insert(taskList, false);
        set<Id> successIds = new Set<Id>();
        Map<Id, WD_Communication__c> mapIdtoWDC = new Map<Id, WD_Communication__c>();
        for (Database.SaveResult sr : srList) {
          if (sr.isSuccess()) {
            successIds.add(sr.getId());
          } else {
            for (Database.Error err : sr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'Error while creating Task from WdCommunication Batch',
                err.getMessage(),
                '' + err.getFields(),
                '' + sr.getId(),
                ''
              );
            }
          }
        }
        PF_Logger.createLogs(PF_Logger.logs);

        if (!successIds.isEmpty()) {
          for (Task t : taskList) {
            if (successIds.contains(t.Id) && !mapIdtoWDC.containsKey(t.WD_Communication__c)) {
              WD_Communication__c wd = new WD_Communication__c(Id = t.WD_Communication__c);
              wd.Task__c = t.Id;
              mapIdtoWDC.put(t.WD_Communication__c, wd);
            }
          }
          if (!mapIdtoWDC.isEmpty()) {
            Database.SaveResult[] wdcSaveResult = Database.update(mapIdtoWDC.values(), false);
            for (Database.SaveResult sResult : wdcSaveResult) {
              if (!sResult.isSuccess()) {
                for (Database.Error err : sResult.getErrors()) {
                  PF_Logger.log(
                    'CEMCI',
                    'Error while updating Task field on WDComm from WdCommunication Batch',
                    err.getMessage(),
                    '' + err.getFields(),
                    '',
                    ''
                  );
                }
              }
            }
            PF_Logger.createLogs(PF_Logger.logs);
          }
        }
      }
    } catch (system.dmlexception e) {
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        e.getMessage(),
        e.getTypeName(),
        e.getLineNumber() +
        'Error while creating Task from WdCommunication Batch' +
        UserInfo.getUserId(),
        'CEMCI_WDCommunications_To_Task_Batch'
      );
      PF_Logger.createLogs(PF_Logger.logs);
    }
  }

  public Task populateWhoId(
    Task tsk,
    Map<String, List<sObject>> sobjectMap,
    Map<string, User> usermap,
    String replyTo,
    String recipientEmail
  ) {
    List<sObject> recordList = sobjectMap.get(recipientEmail);
    /*Since the iteration is going over records ordered by confidential desc,
        it will do assignnments of confidential first (if user is ER) and then breaks the loop 
         */
    for (sObject rec : recordList) {
      //If the lead is confidential and the ReplyTo is an Exec Recruiter assign the lead
      if (rec.get('Confidential__c') == true && execRecruiterEmails.contains(replyTo)) {
        tsk.put('WhoId', rec.Id);
        break;
        //If we are non confidential just assign the record regardless
      } else if (rec.get('Confidential__c') == false) {
        tsk.put('WhoId', rec.Id);
        break;
        //All others set WhoId to null so we can not create tasks for these scnarios.
        //This would be a Confidental Record where ReplyTo is NOT an Executive Recruiter
      } else {
        tsk.put('WhoId', null);
      }
    }
    return tsk;
  }
}