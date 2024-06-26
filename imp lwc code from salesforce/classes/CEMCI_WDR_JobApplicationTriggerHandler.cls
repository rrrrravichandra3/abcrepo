public with sharing class CEMCI_WDR_JobApplicationTriggerHandler implements WDR_CommonTriggerHandler {
  /**
   * @description Constructor for the class
   **/
  public CEMCI_WDR_JobApplicationTriggerHandler() {
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the before insert event of the WDR_Application object
   **/
  public void beforeInsert() {
    List<WDR_Application__c> appsToProcess = (List<WDR_Application__c>) Trigger.new;

    //set the isNew field for new Job apps
    for (WDR_Application__c app : appsToProcess) {
      app.is_New__c = true;
      app.Confidential__c = app.Confidential_Calculated__c;
    }
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the after insert event of the WDR_Application object
   **/
  public void afterInsert() {
    List<WDR_Application__c> appsToProcess = (List<WDR_Application__c>) Trigger.new;
    List<WDR_Application__c> validJobApplications = new List<WDR_Application__c>();

    //set the isNew field for new Job apps
    for (WDR_Application__c app : appsToProcess) {
      if (app.Candidate_Type__c == 'Prospect')
        validJobApplications.add(app);
    }

    //In Workday Confidential Candidates are not available in findcandidates for querying.
    //Confidential Job applications are created at Confidential WD Prospect level not Candidate because of the way Workday works.
    //Once a Job application is submitted, the Prospect does not convert to Candidate. To get around this, a logic is being put in at CRM side
    //to update the Candidate Type to Candidate when Job application comes in. If at any time in the future EI updates the Prospect
    //and Job application, this will be flipped to Candidate when a subsequent Job app update comes in. For CEMCI, the Candidate type flip
    //needs to happen only once to allow for Contact creation but to reduce NHW and SIFT impact, we have to flip the Candidate type everytime
    //EI updates the record. This is NOT an ideal solution and does some unnecessary processing,
    //if at some point Workday gets around the WQL problem, this logic needs to be taken out.
    WDR_Util handleRecord = new WDR_Util();
    handleRecord.changeCandidateType(validJobApplications);
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the before update event of the WDR_Application object
   **/
  public void beforeUpdate() {
    List<WDR_Application__c> appsToProcess = (List<WDR_Application__c>) Trigger.new;

    for (WDR_Application__c app : appsToProcess) {
      app.Confidential__c = app.Confidential_Calculated__c;
    }
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the after update event of the WDR_Application object
   **/
  public void afterUpdate() {
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the before delete event of the WDR_Application object
   **/
  public void beforeDelete() {
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the after delete event of the WDR_Application object
   **/
  public void afterDelete() {
  }

  /**
   * @description Method to propogate changes to CEMCI objects on the after undelete event of the WDR_Application object
   **/
  public void afterUnDelete() {
  }
}