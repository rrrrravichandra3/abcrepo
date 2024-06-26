public with sharing class WDRCandidate_To_Lead_BatchHandler {
  static final Id cntctRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosbyName()
    .get('WDR Candidate')
    .getRecordTypeId();

  public String candidateType;
  static final List<Field_Mapping__mdt> fieldMappingList;
  Map<String, Lead> upsertLeadMap = new Map<String, Lead>();
  Map<String, Lead> allLeadMap = new Map<String, Lead>();
  List<String> setOfEmails = new List<String>();
  Map<String, Id> mapLinkedIntoID = new Map<String, Id>();
  List<CEMCI_LinkedInMerge__e> linkedInMerges = new List<CEMCI_LinkedInMerge__e>();

  public static List<Field_Mapping__mdt> populatefieldMappingList() {
    return [
      SELECT From_Field__c, From_Object__c, To_Field__c, To_Object__c, Mapping_Category__c, To_Length_Limit__c
      FROM Field_Mapping__mdt
      WHERE
        From_Object__c = :Schema.SObjectType.WDR_Candidate__c.getName()
        AND To_Object__c = :Schema.SObjectType.Lead.getName()
        AND Mapping_Category__c = 'CEMCI'
        AND Is_Active__c = TRUE
    ];
  }

  static {
    fieldMappingList = populatefieldMappingList();
  }

  public void processBatchRecords(List<sObject> WDCandidates) {
    Map<String, List<WDR_Candidate__c>> nonConfidentialCandidateMapWithEmail = new Map<String, List<WDR_Candidate__c>>();
    Map<String, List<WDR_Candidate__c>> confidentialCandidateMapWithEmail = new Map<String, List<WDR_Candidate__c>>();
    Map<String, List<WDR_Candidate__c>> nonConfidentialCandidateMapWithoutEmail = new Map<String, List<WDR_Candidate__c>>();
    Map<String, List<WDR_Candidate__c>> confidentialCandidateMapWithoutEmail = new Map<String, List<WDR_Candidate__c>>();

    for (sObject sObj : WDCandidates) {
      WDR_Candidate__c cand = (WDR_Candidate__c) sObj;
      if (cand.Confidential__c) {
        if (cand.Email__c != null) {
          if (!confidentialCandidateMapWithEmail.containskey(cand.Email__c))
            confidentialCandidateMapWithEmail.put(cand.Email__c, new List<WDR_Candidate__c>{ cand });
          else
            confidentialCandidateMapWithEmail.get(cand.Email__c).add(cand);
        } else {
          String combKey;
          if (cand.Current_Company__c == null)
            combKey = cand.Last_Name__c + System.Label.CEMCI_Lead_Company_Not_Provided_Label;
          else
            combKey = cand.Last_Name__c + cand.Current_Company__c;
          if (!confidentialCandidateMapWithoutEmail.containskey(combKey))
            confidentialCandidateMapWithoutEmail.put(combKey, new List<WDR_Candidate__c>{ cand });
          else
            confidentialCandidateMapWithoutEmail.get(combKey).add(cand);
        }
      } else {
        if (cand.Email__c != null) {
          if (!nonConfidentialCandidateMapWithEmail.containskey(cand.Email__c))
            nonConfidentialCandidateMapWithEmail.put(cand.Email__c, new List<WDR_Candidate__c>{ cand });
          else
            nonConfidentialCandidateMapWithEmail.get(cand.Email__c).add(cand);
        } else {
          String combKey;
          if (cand.Current_Company__c == null)
            combKey = cand.Last_Name__c + System.Label.CEMCI_Lead_Company_Not_Provided_Label;
          else
            combKey = cand.Last_Name__c + cand.Current_Company__c;
          if (!nonConfidentialCandidateMapWithoutEmail.containskey(combKey))
            nonConfidentialCandidateMapWithoutEmail.put(combKey, new List<WDR_Candidate__c>{ cand });
          else
            nonConfidentialCandidateMapWithoutEmail.get(combKey).add(cand);
        }
      }
    }
    //Process non-confidential Candidates
    if (!nonConfidentialCandidateMapWithEmail.isEmpty() || !nonConfidentialCandidateMapWithoutEmail.isEmpty())
      processRecords(nonConfidentialCandidateMapWithEmail, nonConfidentialCandidateMapWithoutEmail, false);

    //Process confidential Candidates
    if (!confidentialCandidateMapWithEmail.isEmpty() || !confidentialCandidateMapWithoutEmail.isEmpty())
      processRecords(confidentialCandidateMapWithEmail, confidentialCandidateMapWithoutEmail, true);
  }

  public void processRecords(
    Map<String, List<WDR_Candidate__c>> wdCandidatesWithEmailMap,
    Map<String, List<WDR_Candidate__c>> wdCandidatesWithoutEmailMap,
    Boolean confidential
  ) {
    Map<String, Lead> keyToLeadMap = new Map<String, Lead>();
    Map<String, List<WDR_Candidate__c>> emailToCandidateMap = new Map<String, List<WDR_Candidate__c>>();

    keyToLeadMap = fetchExistingLeadsforUpdate(wdCandidatesWithEmailMap, confidential);

    createOrUpdateLeads(wdCandidatesWithEmailMap, wdCandidatesWithoutEmailMap, keyToLeadMap);

    emailToCandidateMap.putAll(wdCandidatesWithEmailMap);
    emailToCandidateMap.putAll(wdCandidatesWithoutEmailMap);
    upsertRecordsInDatabase(emailToCandidateMap);
  }

  private Map<String, Lead> fetchExistingLeadsforUpdate(
    Map<String, List<WDR_Candidate__c>> wdCandidatesWithEmailMap,
    Boolean confidential
  ) {
    Map<String, Lead> emailToLeadMap = new Map<String, Lead>();

    if (!wdCandidatesWithEmailMap.isEmpty()) {
      String queryStr = 'Select ';
      String fieldList = '';

      for (Field_Mapping__mdt mapping : fieldMappingList)
        fieldList += mapping.To_Field__c + ',';

      queryStr += fieldList + 'Id,LeadSource,OwnerId,Duplicate_Candidates__c,LinkedIn_Substring__c';

      for (String str : wdCandidatesWithEmailMap.keyset()) {
        if (!setOfEmails.contains(str))
          setOfEmails.add(str);
      }

      queryStr += ' from lead where email IN :setOfEmails and Confidential__c =:confidential and isConverted = false';

      for (Lead ld : Database.query(queryStr)) {
        emailToLeadMap.put(ld.Email, ld);
      }
    }

    return emailToLeadMap;
  }

  private void createOrUpdateLeads(
    Map<String, List<WDR_Candidate__c>> wdCandidatesWithEmailMap,
    Map<String, List<WDR_Candidate__c>> wdCandidatesWithoutEmailMap,
    Map<String, Lead> leadKeyToLeadMap
  ) {
    for (String str : wdCandidatesWithEmailMap.keySet()) {
      if (leadKeyToLeadMap.containsKey(str)) {
        Lead ld = leadKeyToLeadMap.get(str);
        populateValuesforLead(str, ld, wdCandidatesWithEmailMap);
      } else
        populateValuesforLead(str, new Lead(), wdCandidatesWithEmailMap);
    }

    for (String str : wdCandidatesWithoutEmailMap.keySet()) {
      populateValuesforLead(str, new Lead(), wdCandidatesWithoutEmailMap);
    }
  }

  private void populateValuesforLead(String str, Lead ld, Map<String, List<WDR_Candidate__c>> emailToCandidateMap) {
    for (WDR_Candidate__c candidate : emailToCandidateMap.get(str)) {
      for (Field_Mapping__mdt mapping : fieldMappingList) {
        if (
          mapping.From_Field__c == System.Label.CEMCI_Mailing_Country_Field_Name_Label &&
          candidate.get(mapping.From_Field__c) == null
        )
          continue;
        else {
          Object data = candidate.get(mapping.From_Field__c);
          //Truncate if value longer than CRM field length
          if (mapping.To_Length_Limit__c != null && data != null) {
            String dataValue = String.valueOf(data);
            dataValue = dataValue.length() > mapping.To_Length_Limit__c
              ? dataValue.left(Integer.valueOf(mapping.To_Length_Limit__c))
              : dataValue;
            data = dataValue;
          }
          if (ld.get(mapping.To_Field__c) == null)
            ld.put(mapping.To_Field__c, data);
        }
      }
      if (ld.Company == null && candidate.Current_Company__c == null) {
        ld.Company = System.Label.CEMCI_Lead_Company_Not_Provided_Label;
      } else if (
        ld.Company == System.Label.CEMCI_Lead_Company_Not_Provided_Label &&
        candidate.Current_Company__c != null
      )
        ld.Company = candidate.Current_Company__c;

      if (ld.LeadSource == null)
        ld.LeadSource = System.Label.CEMCI_Lead_Source_Label;

      if (ld.OwnerId == null) {
        if (ld.Confidential__c)
          ld.OwnerId = Id.valueOf(
            CEMCI_Settings__c.getInstance(UserInfo.getProfileId()).Executive_Recruiting_Queue_Id__c
          );
        else
          ld.OwnerId = Id.valueOf(CEMCI_Settings__c.getInstance(UserInfo.getProfileId()).OSR_Global_Queue_Id__c);
      }

      /*
                if(ld.WDR_Prospect__c != null && ld.WDR_Prospect__c !=candidate.Id)
                {
                    if(ld.Duplicate_Candidates__c==null)
                    ld.Duplicate_Candidates__c=candidate.Id;
                    else
                    ld.Duplicate_Candidates__c =ld.Duplicate_Candidates__c +':'+candidate.Id;
                }
                 */

      if (!candidate.Is_Lead_Created_for_this_WD_Candidate__c)
        candidate.Is_Lead_Created_for_this_WD_Candidate__c = true;

      String key;
      if (ld.email != null)
        key = ld.email;
      else
        key = ld.Lastname + ld.Company;
      upsertLeadMap.put(key, ld);
      allLeadMap.putAll(upsertLeadMap);
    }
  }

  private void upsertRecordsInDatabase(Map<String, List<WDR_Candidate__c>> emailToCandidateMap) {
    List<Lead> updateLeadList = new List<Lead>();
    List<Lead> insertLeadList = new List<Lead>();
    List<WDR_Candidate__c> updateCandidateList = new List<WDR_Candidate__c>();
    Map<Lead, List<WDR_Candidate__c>> leadToCandidateMap = new Map<Lead, List<WDR_Candidate__c>>();

    if (!upsertLeadMap.isEmpty()) {
      for (String str : upsertLeadMap.keySet()) {
        if (upsertLeadMap.get(str) != null && upsertLeadMap.get(str).Id == null) {
          insertLeadList.add(upsertLeadMap.get(str));
          upsertLeadMap.remove(str);
        }
      }

      updateLeadList = upsertLeadMap.values();
      if (insertLeadList.size() > 0) {
        CEMCI_CheckGDPRRecursion.setdoNotRunLeadMergeFlow();
        CEMCI_Leads.newLeads = insertLeadList;
        CEMCI_Leads.oldLeadMap = null;
        CEMCI_Leads.updateDisqualifiedLeads();
        CEMCI_Leads.setIsValidLinkedInURL();
        CEMCI_Leads.setLinkedInSubstring();
        CEMCI_Leads.setOriginalLeadSource();
        CEMCI_Leads.setConfidentialTextField();
        CEMCI_Leads.createIndividualRecordsforLeads();
        insertLeadList = CEMCI_Leads.newLeads;

        //Insert new leads
        Database.SaveResult[] insertResultList = Database.insert(insertLeadList, false);
        emailToCandidateMap = processResults(
          insertResultList,
          emailToCandidateMap,
          insertLeadList,
          'Lead',
          'Error upserting Lead from Prospect batch '
        );

        CEMCI_Leads.newLeads = insertLeadList;
        CEMCI_Leads.createContactPointRecordsforLeads();
      }

      //Update existing leads
      if (updateLeadList.size() > 0) {
        CEMCI_Leads.newLeads = updateLeadList;
        CEMCI_Leads.oldLeadMap = null;
        CEMCI_Leads.setIsValidLinkedInURL();
        CEMCI_Leads.setLinkedInSubstring();
        Database.SaveResult[] updateResultList = Database.update(updateLeadList, false);

        emailToCandidateMap = processResults(
          updateResultList,
          emailToCandidateMap,
          updateLeadList,
          'Lead',
          'Error upserting Lead from Prospect batch '
        );
      }

      for (Contact dupeContact : [
        SELECT Id, Email
        FROM Contact
        WHERE Email IN :setOfEmails AND RecordtypeId = :cntctRecTypeId
      ]) {
        if (emailToCandidateMap.containsKey(dupeContact.Email)) {
          List<WDR_Candidate__c> tempList = emailToCandidateMap.get(dupeContact.Email);
          for (WDR_Candidate__c cand : tempList)
            cand.Awaiting_Lead_Conversion__c = true;
          emailToCandidateMap.put(dupeContact.Email, tempList);

          String leadLinkedinSubstring = allLeadMap.get(dupeContact.Email).LinkedIn_Substring__c;
          if (leadLinkedInSubstring != null && mapLinkedIntoID.containsKey(leadLinkedinSubstring))
            mapLinkedIntoID.remove(leadLinkedinSubstring);
        }
      }
      for (String str : emailToCandidateMap.keySet())
        updateCandidateList.addAll(emailToCandidateMap.get(str));

      //Update Candidates
      if (updateCandidateList.size() > 0) {
        Database.SaveResult[] updateCandResultList = Database.update(updateCandidateList, false);
        processResults(
          updateCandResultList,
          null,
          updateCandidateList,
          'Candidate',
          'Error updating Candidates post Lead upsert '
        );
      }

      markLeadsforDeDupebasedonLinkedIn();

      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
  }

  private Map<String, List<WDR_Candidate__c>> processResults(
    Database.SaveResult[] srList,
    Map<String, List<WDR_Candidate__c>> emailToCandidateMap,
    List<sObject> sobjectList,
    String objectType,
    String errMessage
  ) {
    for (Integer i = 0; i < sobjectList.size(); i++) {
      Database.SaveResult ur = srList[i];
      if (!ur.isSuccess()) {
        if (objectType == 'Lead') {
          String key;
          if (sobjectList[i].get('email') != null)
            key = String.valueOf(sobjectList[i].get('email'));
          else
            key = String.valueOf(sobjectList[i].get('Lastname')) + String.valueOf(sobjectList[i].get('Company'));
          emailToCandidateMap.remove(key);
        }
        for (Database.Error err : ur.getErrors())
          PF_Logger.log(
            'CEMCI',
            'ERROR',
            err.getMessage(),
            '' + err.getFields(),
            errMessage,
            'WDR Candidate to Lead Batch'
          );
      } else {
        if (objectType == 'Lead') {
          String emailValue = String.valueOf(sobjectList[i].get('Email'));
          String leadId = String.valueOf(sobjectList[i].get('Id'));
          String nonEmailKey =
            String.valueOf(sobjectList[i].get('Lastname')) + String.valueOf(sobjectList[i].get('Company'));
          if (emailToCandidateMap.containsKey(emailValue)) {
            WDR_Candidate__c[] cands = emailToCandidateMap.get(emailValue);
            for (WDR_Candidate__c c : cands) {
              c.put('Matching_Lead_Id__c', leadId);
            }
            emailToCandidateMap.put(emailValue, cands);
          } else if (emailToCandidateMap.containsKey(nonEmailKey)) {
            WDR_Candidate__c[] cands = emailToCandidateMap.get(nonEmailKey);
            for (WDR_Candidate__c c : cands) {
              c.put('Matching_Lead_Id__c', leadId);

              emailToCandidateMap.put(nonEmailKey, cands);
            }
          }
          if (sobjectList[i].get('LinkedIn_Substring__c') != null) {
            mapLinkedIntoID.put(
              String.valueOf(sobjectList[i].get('LinkedIn_Substring__c')),
              String.valueOf(sobjectList[i].get('Id'))
            );
          }
        }
      }
    }
    return emailToCandidateMap;
  }

  private void markLeadsforDeDupebasedonLinkedIn() {
    Map<Id, Lead> leadsForDeDupe = new Map<Id, Lead>();

    List<Contact> listOfCon = [
      SELECT id, LinkedIn_Substring__c
      FROM contact
      WHERE LinkedIn_Substring__c IN :mapLinkedIntoID.keySet()
    ];
    for (Contact c : listOfCon) {
      String linkedinSub = c.LinkedIn_Substring__c;
      if (mapLinkedIntoID.containsKey(linkedinSub)) {
        Id leadId = mapLinkedIntoID.get(linkedinSub);
        if (!leadsForDeDupe.containsKey(leadId)) {
          leadsForDeDupe.put(leadId, new Lead(Id = leadId, Awaiting_Lead_De_duplication__c = true));
          mapLinkedIntoID.remove(linkedinSub);
        }
      }
    }

    AggregateResult[] duplicateLeads = [
      SELECT LinkedIn_Substring__c, COUNT(Id) cnt
      FROM Lead
      WHERE LinkedIn_Substring__c IN :mapLinkedIntoID.keySet()
      GROUP BY LinkedIn_Substring__c
    ];

    for (AggregateResult ar : duplicateLeads) {
      String linkedinSub = String.valueOf(ar.get('LinkedIn_Substring__c'));
      Integer cnt = Integer.valueOf(ar.get('cnt'));

      if (cnt > 1 && mapLinkedIntoID.containsKey(linkedinSub)) {
        Id leadId = mapLinkedIntoID.get(linkedinSub);
        if (!leadsForDeDupe.containsKey(leadId))
          leadsForDeDupe.put(leadId, new Lead(Id = leadId, Awaiting_Lead_De_duplication__c = true));
      }
    }

    CEMCI_CheckGDPRRecursion.setdoNotRunLeadTriggers();
    Database.SaveResult[] updateLeads = Database.update(leadsForDeDupe.values(), false);
  }
}