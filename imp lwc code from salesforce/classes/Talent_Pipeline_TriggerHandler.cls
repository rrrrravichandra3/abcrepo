public with sharing class Talent_Pipeline_TriggerHandler {
  public static void handleTrigger(
    List<Talent_Pipeline__c> oldRecords,
    List<Talent_Pipeline__c> newRecords,
    System.TriggerOperation triggerEvent
  ) {
    switch on triggerEvent {
      when BEFORE_INSERT, BEFORE_UPDATE {
        setSegmentationTextFields(oldRecords);
      }
    }
  }

  public static void setSegmentationTextFields(List<Talent_Pipeline__c> oldRecords) {
    Integer charLimit = 255;

    for (Talent_Pipeline__c t : oldRecords) {
      String jobFam = String.ValueOf(t.Job_Family__c);
      String jobFamGroup = String.ValueOf(t.Job_Family_Group__c);
      if (jobFam != null && jobFam.length() > charLimit) {
        t.Job_Family_Text__c = jobFam.substring(0, 255);
      } else {
        t.Job_Family_Text__c = jobFam;
      }

      if (jobFamGroup != null && jobFamGroup.length() > charLimit) {
        t.Job_Family_Group_Text__c = jobFamGroup.substring(0, 255);
      } else {
        t.Job_Family_Group_Text__c = jobFamGroup;
      }
    }
  }
}