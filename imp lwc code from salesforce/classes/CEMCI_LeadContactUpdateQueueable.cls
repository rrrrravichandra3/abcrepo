public class CEMCI_LeadContactUpdateQueueable implements Queueable {
  private List<Contact> contactsToUpdate;
  private List<Lead> leadsToUpdate;

  public CEMCI_LeadContactUpdateQueueable(List<Contact> contactsToUpdate, List<Lead> leadsToUpdate) {
    this.contactsToUpdate = contactsToUpdate;
    this.leadsToUpdate = leadsToUpdate;
  }

  public void execute(System.QueueableContext qc) {
    if (!contactsToUpdate.isEmpty()) {
      Database.SaveResult[] srList = Database.update(contactsToUpdate, false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for (Database.Error objErr : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              objErr.getMessage(),
              String.valueof(objErr.getStatusCode()),
              ' Error during updating Contact with id ' + sr.getId(),
              'CEMCI_LeadContactUpdateQueueable'
            );
          }
        }
      }
    }
    if (!leadsToUpdate.isEmpty()) {
      Database.SaveResult[] sList = Database.update(leadsToUpdate, false);
      for (Database.SaveResult sr : sList) {
        if (!sr.isSuccess()) {
          for (Database.Error objErr : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              objErr.getMessage(),
              String.valueof(objErr.getStatusCode()),
              ' Error during updating Lead with id ' + sr.getId(),
              'CEMCI_LeadContactUpdateQueueable'
            );
          }
        }
      }
      if (!PF_Logger.logs.isEmpty()) {
        PF_Logger.createLogs(PF_Logger.logs);
      }
    }
  }
}