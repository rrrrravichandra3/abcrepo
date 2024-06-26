/* Scheduler to assign permsets for payrollAmerManager users */

global class ESDJC_AssignPermSet_Scheduler implements Schedulable {
  
  global void execute(SchedulableContext SC){
    ESDJC_AutoAssign_PayrollPermset assignPermBatch = new ESDJC_AutoAssign_PayrollPermset();
    Database.executeBatch(assignPermBatch);
  }
}