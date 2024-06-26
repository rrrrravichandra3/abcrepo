public with sharing class CEMCI_CampaignMemberStatus {
  public static List<Campaign> campaigns;
  public static Map<String, List<CEMCI_CampaignMemberStatus__c>> cmpgnMemberStatusTypesByCampaignType = new Map<String, List<CEMCI_CampaignMemberStatus__c>>();
  public static List<CampaignMemberStatus> cmpgnMemberStatusList = new List<CampaignMemberStatus>();
  public static List<CampaignMemberStatus> cmpgnMemberStatusForDelete = new List<CampaignMemberStatus>();
  public static Map<Id, List<CampaignMemberStatus>> cmpgnMemberStatusByCampaignId = new Map<Id, List<CampaignMemberStatus>>();
  public static Map<String, CampaignMemberStatus> cmpgnMemberStatusBylabel = new Map<String, CampaignMemberStatus>();
  public static List<CampaignMemberStatus> cmpgnMemberStatusToBeDeleted = new List<CampaignMemberStatus>();

  public static void addCampaignMemberStatusBasedOnCampaignType() {
    getCampaignMemberStatus();
    getSystemGeneratedCampaignMemberStatus();
    populateCampaignMemberStatus();
    insertCampaignMemberStatus();
    deleteSystemGenaratedCampaignMemberStatus();
  }
  /**
   * @description  method to get the campaignMemberStatus From the Custom Metdata.
   **/

  public static void getCampaignMemberStatus() {
    List<CEMCI_CampaignMemberStatus__c> cmpgnMemberStatusTypes = CEMCI_CampaignMemberStatus__c.getall().values();
    for (CEMCI_CampaignMemberStatus__c cmpgnMemberStatus : cmpgnMemberStatusTypes) {
      if (cmpgnMemberStatusTypesByCampaignType.containsKey(cmpgnMemberStatus.CampaignType__c)) {
        cmpgnMemberStatusTypesByCampaignType.get(cmpgnMemberStatus.CampaignType__c).add(cmpgnMemberStatus);
      } else {
        cmpgnMemberStatusTypesByCampaignType.put(
          cmpgnMemberStatus.CampaignType__c,
          new List<CEMCI_CampaignMemberStatus__c>{ cmpgnMemberStatus }
        );
      }
    }
  }

  /**
   * @description  Method To get the defaultCampaignmemberstatus .
   **/

  public static void getSystemGeneratedCampaignMemberStatus() {
    Set<Id> campaignIds = new Set<Id>();
    for (campaign cmpgn : campaigns) {
      campaignIds.add(cmpgn.Id);
    }
    for (CampaignMemberStatus cmpgMemberStatusForCampaigns : [
      SELECT CampaignId, Label, HasResponded, IsDefault, SortOrder
      FROM CampaignMemberStatus
      WHERE CampaignId IN :campaignIds
    ]) {
      if (cmpgnMemberStatusByCampaignId.containsKey(cmpgMemberStatusForCampaigns.CampaignId)) {
        cmpgnMemberStatusByCampaignId.get(cmpgMemberStatusForCampaigns.CampaignId).add(cmpgMemberStatusForCampaigns);
      } else {
        cmpgnMemberStatusByCampaignId.put(
          cmpgMemberStatusForCampaigns.CampaignId,
          new List<CampaignMemberStatus>{ cmpgMemberStatusForCampaigns }
        );
      }
    }
  }

  /**
   * @description  method to Check the Camapaigntype and Record Type of the campaigns.
   **/

  public static void populateCampaignMemberStatus() {
    List<CEMCI_CampaignMemberStatus__c> cmpgnMemberStatusTypesForCmpaignType;
    campaignMemberStatus cmpgnMemberStatus;
    string recordTypeName = System.Label.CemciCampaignRecordType;
    Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName()
      .get(recordTypeName)
      .getRecordTypeId();
    for (campaign cmpgn : campaigns) {
      if (
        cmpgn.RecordTypeId == campaignRecordTypeId &&
        cmpgn.Type != null &&
        cmpgnMemberStatusTypesByCampaignType.get(cmpgn.Type) != null &&
        cmpgnMemberStatusByCampaignId.get(cmpgn.id) != null &&
        cmpgn.Total_Members__c <= 0
      ) {
        cmpgnMemberStatusTypesForCmpaignType = cmpgnMemberStatusTypesByCampaignType.get(cmpgn.Type);
        cmpgnMemberStatusForDelete = CmpgnMemberStatusByCampaignId.get(cmpgn.Id);
        for (campaignMemberStatus cmpgnMemberStatusforDeleted : cmpgnMemberStatusForDelete) {
          cmpgnMemberStatusBylabel.put(cmpgnMemberStatusforDeleted.Label, cmpgnMemberStatusforDeleted);
        }
        for (CEMCI_CampaignMemberStatus__c cmpgnMemberStatusFromCustomSetting : cmpgnMemberStatusTypesForCmpaignType) {
          if (!cmpgnMemberStatusBylabel.containsKey(cmpgnMemberStatusFromCustomSetting.Member_Status__c)) {
            cmpgnMemberStatus = insertCampaignMemberStatusBasedOnCampaignType(
              cmpgnMemberStatusFromCustomSetting,
              cmpgn
            );
            cmpgnMemberStatusList.add(cmpgnMemberStatus);
          } else {
            for (integer i = 0; i < cmpgnMemberStatusForDelete.size(); i++) {
              if (cmpgnMemberStatusForDelete[i].Label == cmpgnMemberStatusFromCustomSetting.Member_Status__c) {
                cmpgnMemberStatusForDelete.remove(i);
              }
            }
          }
        }
        cmpgnMemberStatusToBeDeleted.addall(cmpgnMemberStatusForDelete);
      }
    }
  }

  public static void deleteSystemGenaratedCampaignMemberStatus() {
    if (cmpgnMemberStatusToBeDeleted != null && !cmpgnMemberStatusToBeDeleted.isEmpty()) {
      Boolean areFieldsAccessible = PF_AccessibilityUtils.checkFLS(
        'CampaignMemberStatus',
        PF_AccessibilityUtils.PermissionType.CREATEABLE,
        new List<string>{ 'CampaignId', 'HasResponded', 'IsDefault', 'Label' }
      );
      if (areFieldsAccessible) {
        Database.DeleteResult[] drList = Database.delete(cmpgnMemberStatusToBeDeleted, false);

        for (Database.DeleteResult sr : drList) {
          if (!sr.isSuccess()) {
            for (Database.Error objErr : sr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                objErr.getMessage(),
                String.valueof(objErr.getStatusCode()),
                ' Error during CampaignMemberStatus deleted ' +
                sr.getId() +
                ' UserId ' +
                UserInfo.getUserId(),
                'Consents'
              );
            }
          }
        }
      } else {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          'The User does not have sufficient access on CampaignMemebrStatus fields',
          '',
          ' Error during delete SystemGenarated CampaignMemberStatus ' + UserInfo.getUserId(),
          ''
        );
      }
      if (!PF_Logger.logs.isEmpty()) {
        PF_Logger.createLogs(PF_Logger.logs);
      }
    }
  }

  public static void insertCampaignMemberStatus() {
    if (cmpgnMemberStatusList != null && !cmpgnMemberStatusList.isEmpty()) {
      Boolean areFieldsAccessible = PF_AccessibilityUtils.checkFLS(
        'CampaignMemberStatus',
        PF_AccessibilityUtils.PermissionType.CREATEABLE,
        new List<string>{ 'CampaignId', 'HasResponded', 'IsDefault', 'Label' }
      );
      if (areFieldsAccessible) {
        Database.SaveResult[] srList = Database.insert(cmpgnMemberStatusList, false);

        for (Database.SaveResult sr : srList) {
          if (!sr.isSuccess()) {
            for (Database.Error objErr : sr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                objErr.getMessage(),
                String.valueof(objErr.getStatusCode()),
                ' Error during CampaignMemberStatus Insert ' +
                sr.getId() +
                ' UserId ' +
                UserInfo.getUserId(),
                'Consents'
              );
            }
          }
        }
      } else {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          'The User does not have sufficient access on CampaignMemberStatus fields',
          '',
          ' Error during insert CampaignMemberStatus Records ' + UserInfo.getUserId(),
          ''
        );
      }
      if (!PF_Logger.logs.isEmpty()) {
        PF_Logger.createLogs(PF_Logger.logs);
      }
    }
  }

  /**
   * @description  method to insert the new campaignmember status based on the type of the campaign.
   * @param Object containing memberStatusRecord and the campaign object.
   **/
  public static CampaignMemberStatus insertCampaignMemberStatusBasedOnCampaignType(
    CEMCI_CampaignMemberStatus__c cmpgnMemberStatus,
    campaign cmpgn
  ) {
    CampaignMemberStatus cmpMemberStatus = new CampaignMemberStatus();

    Boolean areFieldsAccessible = PF_AccessibilityUtils.checkFLS(
      'CampaignMemberStatus',
      PF_AccessibilityUtils.PermissionType.CREATEABLE,
      new List<string>{ 'CampaignId', 'HasResponded', 'IsDefault', 'Label' }
    );
    if (areFieldsAccessible) {
      cmpMemberStatus.CampaignId = cmpgn.Id;
      cmpMemberStatus.Label = cmpgnMemberStatus.Member_Status__c;
      cmpMemberStatus.HasResponded = cmpgnMemberStatus.Responded__c;
      cmpMemberStatus.IsDefault = cmpgnMemberStatus.Is_Default__c;
    } else {
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        'The User does not have sufficient access on CampaignMemberStatus fields',
        '',
        ' Error during insert CampaignMemberStatus Records BasedOnCampaignType ' + UserInfo.getUserId(),
        ''
      );
    }
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }

    return cmpMemberStatus;
  }
}