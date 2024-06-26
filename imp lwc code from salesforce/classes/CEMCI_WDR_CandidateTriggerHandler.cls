public with sharing class CEMCI_WDR_CandidateTriggerHandler implements WDR_CommonTriggerHandler {
  /**
   * @description Interface method for handling before insert method.
   *
   **/
  public void beforeInsert() {
    if (!System.isBatch()) {
      CEMCI_WD_Candidates.newWDCandidates = Trigger.new;
      CEMCI_WD_Candidates.oldWDCandidates = Trigger.old;
      CEMCI_WD_Candidates.oldWDCandidatesMap = Trigger.oldMap;
      CEMCI_WD_Candidates.newWDCandidateMap = Trigger.newMap;
      CEMCI_WD_Candidates.updateMailingCountry();
    }
  }

  /**
   * @description Interface method for handling after insert method.
   *
   **/
  public void afterInsert() {
  }

  /**
   * @description Interface method for handling before update method.
   *
   **/
  public void beforeUpdate() {
    if (!System.isBatch()) {
      CEMCI_WD_Candidates.newWDCandidates = Trigger.new;
      CEMCI_WD_Candidates.oldWDCandidates = Trigger.old;
      CEMCI_WD_Candidates.oldWDCandidatesMap = Trigger.oldMap;
      CEMCI_WD_Candidates.newWDCandidateMap = Trigger.newMap;
      CEMCI_WD_Candidates.updateMailingCountry();
      CEMCI_WD_Candidates.updateSourceofTruthFields();
      CEMCI_WD_Candidates.setCandidateTypeField();
    }
  }

  /**
   * @description Interface method for handling after update method.
   *
   **/
  public void afterUpdate() {
    if (!System.isBatch()) {
      CEMCI_WD_Candidates.newWDCandidates = Trigger.new;
      CEMCI_WD_Candidates.oldWDCandidates = Trigger.old;
      CEMCI_WD_Candidates.oldWDCandidatesMap = Trigger.oldMap;
      CEMCI_WD_Candidates.newWDCandidateMap = Trigger.newMap;
      CEMCI_WD_Candidates.wdCandidateToLeadUpdate();
    }
  }
  /**
   * @description Interface method for handling before delete method.
   *
   **/
  public void beforeDelete() {
  }

  /**
   * @description Interface method for handling after delete method.
   *
   **/
  public void afterDelete() {
  }

  /**
   * @description Interface method for handling after undelete method.
   *
   **/
  public void afterUnDelete() {
  }
}