public without sharing class CEMCI_AssignRoleToAccountOwner implements Queueable {
  public void execute(QueueableContext context) {
    updateRoleId();
  }

  private void updateRoleId() {
    List<UserRole> uRole = [
      SELECT Id
      FROM UserRole
      WHERE Name = :CEMCI_Settings__c.getInstance().Account_Owner_Role__c
    ];
    Id uRoleId;

    if (uRole.size() > 0) {
      uRoleId = uRole[0].Id;
      List<User> updateUserList = [
        SELECT Id, UserRoleId
        FROM User
        WHERE ProfileId = :CEMCI_Settings__c.getInstance().Account_Owner_Profile_Id__c AND UserRoleId = NULL
      ];
      for (User updateUser : updateUserList) {
        updateUser.UserRoleId = uRoleId;
      }
      update updateUserList;
    }
  }
}