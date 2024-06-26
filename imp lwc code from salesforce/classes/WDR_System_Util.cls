public without sharing class WDR_System_Util {
  public void handleCEMCIAccountUser(Id accountOwnerId, Id accountOwnerProfileId, Integer existingUserCount) {
    List<User> userUpserList = new List<User>();
    String orgSuffix = '';

    Organization orgInfo = [SELECT IsSandbox FROM Organization];
    if (orgInfo.IsSandbox)
      orgSuffix = '.' + System.Url.getOrgDomainUrl().getAuthority().substringAfter('--').substringBefore('.');

    User us = new User(
      ProfileId = accountOwnerProfileId,
      Email = 'bt-emp-engagement@salesforce.com',
      Username = 'cemciaccountowner' + (existingUserCount + 1) + '@salesforce.com' + orgSuffix,
      Alias = 'cowne' + (existingUserCount + 1),
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      LastName = 'Owner ' + (existingUserCount + 1),
      FirstName = 'CEMCI Account',
      isActive = true,
      Available_for_CEMCI_Account_Assignment__c = true
    );

    userUpserList.add(us);

    if (accountOwnerId != null) {
      User usr = new User(Id = accountOwnerId, Available_for_CEMCI_Account_Assignment__c = false);
      userUpserList.add(usr);
    }
    Database.UpsertResult[] sObjectupsertResult = Database.upsert(userUpserList, false);
    for (Database.UpsertResult result : sObjectupsertResult) {
      if (!result.isSuccess()) {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(result.getErrors()),
          null,
          ' Error creating or updating Users for CEMCI Account processing at ' + System.now(),
          'WDR_System_Util'
        );
      }
    }
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }
  }
}