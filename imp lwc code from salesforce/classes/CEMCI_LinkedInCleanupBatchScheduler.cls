/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 06-16-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
global class CEMCI_LinkedInCleanupBatchScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    CEMCI_LinkedInCleanupBatch batch = new CEMCI_LinkedInCleanupBatch();
    database.executebatch(batch, 20);
  }
}