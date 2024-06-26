public with sharing class CEMCI_CheckGDPRRecursion {
  private static Boolean leadConversionContext = false;
  private static Map<Id, Id> leadToIndividualMap;
  private static Boolean mergeRecordRunonce = false;
  private static Boolean doNotRunGDPRFlow = false;
  private static Boolean doNotRunLeadMergeFlow = false;
  private static Boolean doNotRunLeadTriggers = false;

  public static void setExecutionVariable() {
    if (!leadConversionContext) {
      leadConversionContext = true;
    }
  }
  public static void setleadToIndividualMap(Map<Id, Id> ldToIndividualMap) {
    if (!ldToIndividualMap.isEmpty()) {
      leadToIndividualMap = ldToIndividualMap;
    }
  }
  public static void setMergeRecordRunonce() {
    if (!mergeRecordRunonce && leadConversionContext) {
      mergeRecordRunonce = true;
    }
  }
  public static void setdoNotRunGDPRFlow() {
    if (!doNotRunGDPRFlow) {
      doNotRunGDPRFlow = true;
    }
  }
  public static void setdoNotRunLeadMergeFlow() {
    if (!doNotRunLeadMergeFlow) {
      doNotRunLeadMergeFlow = true;
    }
  }
  public static void setdoNotRunLeadTriggers() {
    if (!doNotRunLeadTriggers) {
      doNotRunLeadTriggers = true;
    }
  }
  public static boolean getExecutionVariable() {
    return leadConversionContext;
  }
  public static Map<Id, Id> getleadToIndividualMap() {
    return leadToIndividualMap;
  }
  public static boolean getMergeRecordRunonce() {
    return mergeRecordRunonce;
  }
  public static boolean getdoNotRunGDPRFlow() {
    return doNotRunGDPRFlow;
  }
  public static boolean getdoNotRunLeadMergeFlow() {
    return doNotRunLeadMergeFlow;
  }
  public static boolean getdoNotRunLeadTriggers() {
    return doNotRunLeadTriggers;
  }
}