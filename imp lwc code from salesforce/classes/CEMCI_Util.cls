/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class CEMCI_Util {
  public static String defualtCEMCIUser {
    get {
      if (defualtCEMCIUser == null) {
        defualtCEMCIUser = CEMCI_Settings__c.getOrgDefaults().CEMCI_Default_Lead_Owner__c;
      }
      return defualtCEMCIUser;
    }
    set;
  }
  /**
   * Determines a set of users on lead conversion that should not own Contacts.
   */
  public static Set<Id> rmmOrSysAdminUsers {
    get {
      if (rmmOrSysAdminUsers == null || rmmOrSysAdminUsers.size() == 0) {
        rmmOrSysAdminUsers = new Set<Id>();
        List<PermissionSetAssignment> psaRMM = [
          SELECT Id, AssigneeId
          FROM PermissionSetAssignment
          WHERE PermissionSet.Name = 'Recruitment_Marketing_Manager'
        ];

        for (User u : getUsersWithCustomPermission('CEMCI_RMM')) {
          rmmOrSysAdminUsers.add(u.id);
        }

        Map<Id, Profile> sysAdminProfilesMap = new Map<Id, Profile>(
          [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'systemadministrator')]
        );

        for (User u : [SELECT id FROM User WHERE IsActive = TRUE AND ProfileId IN :sysAdminProfilesMap.keyset()]) {
          rmmOrSysAdminUsers.add(u.Id);
        }
      }
      return rmmOrSysAdminUsers;
    }
    set;
  }

  /**
   * Used to identify a list of users with a specific custom permission.
   */
  public static List<User> getUsersWithCustomPermission(String name) {
    Set<Id> permissionSetIds = new Set<Id>();
    for (SetupEntityAccess access : [
      SELECT ParentId
      FROM SetupEntityAccess
      WHERE SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName = :name)
    ]) {
      permissionSetIds.add(access.ParentId);
    }
    return permissionSetIds.isEmpty()
      ? new List<User>()
      : [
          SELECT Id, Email, Username
          FROM User
          WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSetIds)
        ];
  }

  public static String appendValueToMultipicklist(String existingValue, String newValue) {
    List<String> finalValueSet = existingValue.split(';');
    List<String> newValueSet = newValue != null ? newValue.split(';') : null;
    String finalValue = '';

    if (newValueSet != null) {
      for (String str : newValueSet) {
        if (str != null && !finalValueSet.contains(str))
          finalValueSet.add(str);
      }

      for (String str : finalValueSet)
        finalValue += str + ';';
      finalValue = finalValue.length() > 0 ? finalValue.substring(0, finalValue.length() - 1) : finalValue;
    } else
      finalValue = existingValue;

    return finalValue;
  }
  /**
   * Method will check if the lead owner is a valid user to own the contact(Non Sys Admin OR RMM)
   * Sets the Contact Owner to be Lead Owner
   * Secondly checks if the lead is owned by a queue if so, set as defaultCEMCI User (Custom Setting)
   * If neither set contactOwnerId to null which will result in the owner being the User that does the conversion
   * @param leadOwnerId
   *
   * @return contactOwnerId
   */

  public static id setLeadOwnerValidforContactOwner(Id leadOwnerId) {
    id contactOwnerId = null;
    if (!rmmOrSysAdminUsers.contains(leadOwnerId) & String.valueOf(leadOwnerId).substring(0, 3) != '00G') {
      contactOwnerId = leadOwnerId;
    }
    return contactOwnerId;
  }
  /**
   * Method will check if the lead is assigned to an RMM or Sys Admins update the owner to OSR Queue
   *
   * @param leadOwnerId
   *
   * @return newId
   */
  public static id setValidLeadOwner(Id leadOwnerId, Boolean confidential) {
    Id osrQueue = CEMCI_Settings__c.getInstance().OSR_Global_Queue_Id__c;
    Id executiveRQueue = CEMCI_Settings__c.getInstance().Executive_Recruiting_Queue_Id__c;

    if (rmmOrSysAdminUsers.contains(leadOwnerId)) {
      if (confidential)
        leadOwnerId = executiveRQueue;
      else
        leadOwnerId = osrQueue;
    }
    return leadOwnerId;
  }

  public static string generateLinkedInSubstring(String inputURL) {
    String linkedInURL = System.Label.CEMCI_Valid_LinkedIn_URL;
    String linkedinSubstring;

    try {
      Pattern linkedInURLPattern = Pattern.compile(linkedInURL);
      Matcher inputURLMatcher = linkedInURLPattern.matcher(inputURL);
      Boolean isValid = inputURLMatcher.matches();
      if (isValid) {
        String linkedinValue = String.valueOf(inputURL).toLowerCase();
        linkedinSubstring = linkedinValue.subStringAfter('linkedin.com/in/');
      }
      linkedinSubstring = linkedinSubstring.subStringBefore('/');
      return linkedinSubstring;
    } catch (Exception e) {
      return null;
    }
  }

  public static void expireConsentsForOldEmailPhone(List<String> emailPhoneListToExpireConsent) {
    List<AuthorizationFormConsent> updatedAFC = new List<AuthorizationFormConsent>();
    List<ContactPointConsent> updatedCPC = new List<ContactPointConsent>();

    for (AuthorizationFormConsent afc : [
      SELECT id, name, IsActive__c
      FROM AuthorizationFormConsent
      WHERE name IN :emailPhoneListToExpireConsent
    ]) {
      afc.IsActive__c = false;
      updatedAFC.add(afc);
    }

    for(ContactPointEmail cpe : [Select id,name, (select EffectiveTo from ContactPointConsents) from ContactPointEmail where name IN :emailPhoneListToExpireConsent]){
      for(ContactPointConsent cpc : cpe.ContactPointConsents){
        cpc.EffectiveTo = System.now();
        updatedCPC.add(cpc);
      }
    }

    for(ContactPointPhone cpp : [Select id,name, (select EffectiveTo from ContactPointConsents) from ContactPointPhone where name IN :emailPhoneListToExpireConsent]){
      for(ContactPointConsent cpc : cpp.ContactPointConsents){
        cpc.EffectiveTo = System.now();
        updatedCPC.add(cpc);
      }
    }

    if (updatedAFC != null && !updatedAFC.isEmpty()) {
      Database.SaveResult[] srList = Database.update(updatedAFC, false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              '' + err.getFields(),
              'Error while expiring AFC',
              'CEMCI_Util'
            );
          }
        }
      }
    }
    if (updatedCPC != null && !updatedCPC.isEmpty()) {
      Database.SaveResult[] srList = Database.update(updatedCPC, false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              err.getMessage(),
              '' + err.getFields(),
              'Error while expiring CPC',
              'CEMCI_Util'
            );
          }
        }
      }
    }
  }
}