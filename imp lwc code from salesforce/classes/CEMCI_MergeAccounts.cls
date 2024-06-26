public with sharing class CEMCI_MergeAccounts {
  public void mergeAccounts(List<Account> accounts) {
    List<Contact> updateContactList = new List<Contact>();
    List<Id> listOfAccountId = new List<Id>();
    Map<Id, Account> deleteAccounts = new Map<Id, Account>();
    Map<Id, List<Contact>> mapOfAccountIdContacts = new Map<Id, List<Contact>>();
    Map<Id, Id> contactToAccountMap = new Map<Id, Id>();
    Account parentAccount;

    if (accounts != null && !accounts.isEmpty()) {
      for (Account ac : accounts) {
        listOfAccountId.add(ac.Id);
      }

      //fetching the list of contacts related to each account
      for (Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :listOfAccountId]) {
        List<Contact> localContacts = new List<Contact>();
        if (mapOfAccountIdContacts.containsKey(c.AccountId)) {
          localContacts = mapOfAccountIdContacts.get(c.AccountId);
        }
        localContacts.add(c);
        mapOfAccountIdContacts.put(c.AccountId, localContacts);
      }

      // deleting the duplicate account records and reparenting the contact records
      for (Account acc : accounts) {
        if (parentAccount == null) {
          parentAccount = acc;
          continue;
        }
        if (parentAccount.Name.toLowerCase() == acc.Name.toLowerCase()) {
          if (mapOfAccountIdContacts.containsKey(acc.Id)) {
            for (Contact con : mapOfAccountIdContacts.get(acc.Id)) {
              contactToAccountMap.put(con.Id, con.AccountId);
              con.AccountId = parentAccount.Id;
              updateContactList.add(con);
            }
          }
          deleteAccounts.put(acc.Id, acc);
        } else
          parentAccount = acc;
      }

      if (updateContactList.size() > 0) {
        Database.SaveResult[] srList = Database.update(updateContactList, false);

        for (Integer i = 0; i < srList.size(); i++) {
          if (!srList[i].isSuccess()) {
            Id prevAccountId = contactToAccountMap.get(updateContactList[i].Id);
            if (deleteAccounts.containsKey(prevAccountId)) {
              deleteAccounts.remove(prevAccountId);
            }
          }
        }
      }

      if (deleteAccounts.size() > 0) {
        Database.DeleteResult[] drList = Database.delete(deleteAccounts.values(), false);
        for (Database.DeleteResult dr : drList) {
          if (!dr.isSuccess()) {
            for (Database.Error err : dr.getErrors()) {
              PF_Logger.log(
                'CEMCI',
                'ERROR',
                err.getMessage(),
                '' + err.getFields(),
                'Error during Account merge',
                'CEMCI_MergeAccounts_Batch'
              );
            }
          }
        }
      }
      if (PF_Logger.logs.size() > 0)
        PF_Logger.createLogs(PF_Logger.logs);
    }
  }
}