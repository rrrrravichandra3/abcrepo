global with sharing class CEMCI_MRDT_CleanupBatch implements Database.Batchable<sObject> {
  global database.queryLocator start(Database.BatchableContext BC) {
    String query = 'Select id,Campaign.Name,ContactId,Contact.IndividualId,Email,LeadId,Lead.IndividualId, Phone, Member_Responded_Datetime__c from CampaignMember where Member_Responded_Datetime__c !=null ';

    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, list<CampaignMember> scope) {
    Map<String, AuthorizationFormConsent> mapOfIndIdCategoryUpdatedAFC = new Map<String, AuthorizationFormConsent>();
    Map<String, DateTime> mapOfIndIdCampMRDT = new Map<String, DateTime>();
    List<Id> listOfIndividualIds = new List<Id>();
    List<ContactPointConsent> listOfActiveCPC = new List<ContactPointConsent>();
    List<String> listOfCampaign = new List<String>();

    for (CampaignMember cm : scope) {
      if (cm.ContactId != null) {
        mapOfIndIdCampMRDT.put(cm.Contact.IndividualId + '' + cm.Campaign.Name, cm.Member_Responded_Datetime__c);
        listOfIndividualIds.add(cm.Contact.IndividualId);
        listOfCampaign.add(cm.Campaign.Name);
      }
      if (cm.LeadId != null) {
        mapOfIndIdCampMRDT.put(cm.Lead.IndividualId + '' + cm.Campaign.Name, cm.Member_Responded_Datetime__c);
        listOfIndividualIds.add(cm.Lead.IndividualId);
        listOfCampaign.add(cm.Campaign.Name);
      }
    }

    if (!listOfCampaign.isEmpty() && !listOfIndividualIds.isEmpty()) {
      List<AuthorizationFormConsent> listOfActiveAFC = [
        SELECT
          id,
          IsActive__c,
          ConsentCapturedSource,
          Name,
          ConsentGiverId,
          Member_Responded_Datetime__c,
          AuthorizationFormText.Consent_Category__c,
          AuthorizationFormText.Consent_Type__c
        FROM AuthorizationFormConsent
        WHERE
          ConsentGiverId IN :listOfIndividualIds
          AND ConsentCapturedSource IN :listOfCampaign
          AND IsActive__c = TRUE
          AND Member_Responded_Datetime__c = NULL
      ];
      listOfIndividualIds.clear();

      if (!listOfActiveAFC.isEmpty()) {
        for (AuthorizationFormConsent afc : listOfActiveAFC) {
          String val = afc.ConsentGiverId + '' + afc.ConsentCapturedSource;
          if (mapOfIndIdCampMRDT.containsKey(val)) {
            afc.Member_Responded_Datetime__c = mapOfIndIdCampMRDT.get(val);
            mapOfIndIdCategoryUpdatedAFC.put(
              afc.ConsentGiverId +
              '' +
              afc.AuthorizationFormText.Consent_Category__c +
              '' +
              afc.AuthorizationFormText.Consent_Type__c,
              afc
            );
            listOfIndividualIds.add(afc.ConsentGiverId);
          }
        }

        Map<Id, ContactPointEmail> mapOfCPECPC = new Map<Id, ContactPointEmail>(
          [
            SELECT
              id,
              ParentId,
              (
                SELECT id, Name, Member_Responded_Datetime__c, CaptureContactPointType, EffectiveTo
                FROM ContactPointConsents
                WHERE EffectiveTo = NULL AND Member_Responded_Datetime__c = NULL
              )
            FROM ContactPointEmail
            WHERE ParentId IN :listOfIndividualIds
          ]
        );
        Map<Id, ContactPointPhone> mapOfCPPCPC = new Map<Id, ContactPointPhone>(
          [
            SELECT
              id,
              ParentId,
              (
                SELECT id, Name, Member_Responded_Datetime__c, CaptureContactPointType, EffectiveTo
                FROM ContactPointConsents
                WHERE EffectiveTo = NULL AND Member_Responded_Datetime__c = NULL
              )
            FROM ContactPointPhone
            WHERE ParentId IN :listOfIndividualIds
          ]
        );

        for (Id cpeid : mapOfCPECPC.keyset()) {
          for (ContactPointConsent cpc : mapOfCPECPC.get(cpeid).ContactPointConsents) {
            String category = cpc.Name.substringAfter(' ');
            String vla = mapOfCPECPC.get(cpeid).ParentId + '' + category + '' + cpc.CaptureContactPointType;
            if (mapOfIndIdCategoryUpdatedAFC.containsKey(vla)) {
              cpc.Member_Responded_Datetime__c = mapOfIndIdCategoryUpdatedAFC.get(vla).Member_Responded_Datetime__c;
              listOfActiveCPC.add(cpc);
            }
          }
        }

        for (Id cppid : mapOfCPPCPC.keyset()) {
          for (ContactPointConsent cpc : mapOfCPPCPC.get(cppid).ContactPointConsents) {
            String category = cpc.Name.substringAfter(' ');
            String vla = mapOfCPPCPC.get(cppid).ParentId + '' + category + '' + cpc.CaptureContactPointType;
            if (mapOfIndIdCategoryUpdatedAFC.containsKey(vla)) {
              cpc.Member_Responded_Datetime__c = mapOfIndIdCategoryUpdatedAFC.get(vla).Member_Responded_Datetime__c;
              listOfActiveCPC.add(cpc);
            }
          }
        }

        if (!mapOfIndIdCategoryUpdatedAFC.values().isEmpty()) {
          Database.SaveResult[] srList = Database.update(mapOfIndIdCategoryUpdatedAFC.values(), false);
          for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
              for (Database.Error objErr : sr.getErrors()) {
                PF_Logger.log(
                  'CEMCI',
                  'ERROR',
                  objErr.getMessage(),
                  String.valueof(objErr.getStatusCode()),
                  ' Error during updating AFC with MRDT ' + sr.getId(),
                  'CEMCI_MRDT_CleanupBatch'
                );
              }
            }
          }
        }
        if (!listOfActiveCPC.isEmpty()) {
          Database.SaveResult[] srList = Database.update(listOfActiveCPC, false);
          for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
              for (Database.Error objErr : sr.getErrors()) {
                PF_Logger.log(
                  'CEMCI',
                  'ERROR',
                  objErr.getMessage(),
                  String.valueof(objErr.getStatusCode()),
                  ' Error during updating CPC with MRDT ' + sr.getId(),
                  'CEMCI_MRDT_CleanupBatch'
                );
              }
            }
          }
        }
      }
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}