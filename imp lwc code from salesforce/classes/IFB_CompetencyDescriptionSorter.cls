/**
 * @description Sorts IFB_Competency_Description__c records based on weighted 
 * criteria that consideres Group, Position and Interview Type
 * @autor Angel Abrego <aabrego@salesforce.com>
 * @date 2017-10-11
 */
public with sharing class IFB_CompetencyDescriptionSorter {
  private Map<String, List<IFB_CompetencyDescriptionWrapper>> competenciesByName {get; set;}
  private String criteriaGroup                {get; set;}
  private String criteriaInterviewType        {get; set;}
  private String criteriaPosition             {get; set;}

  /**
   * @description Contructor. Initialize the sorted with a list of 
   * "Competency Description" records.
   * @param competencies - List of IFB_Competency_Description__c that we want to
   *    segregate. Records must have been queried including the following fields:
   *      - Name
   *      - Group__c
   *      - Interview_Record_Type__c
   *      - Position__c
   *      - LastModifiedDate
   */
  public IFB_CompetencyDescriptionSorter(
        List<IFB_Competency_Description__c> competencies,
        String criteriaGroup,
        String criteriaInterviewType,
        String criteriaPosition) {
    this.criteriaGroup = criteriaGroup;
    this.criteriaInterviewType = criteriaInterviewType;
    this.criteriaPosition = criteriaPosition;

    // Because there can be multiple "Competency Description" records
    // for a given Competency Name, we use this map to relate all the records
    // by competency name. The wrapper class "IFB_CompetencyDescriptionWrapper"
    // is used because it allows sorting of the records based on configurable
    // criteria
    this.competenciesByName = new Map<String, List<IFB_CompetencyDescriptionWrapper>>();

    for (IFB_Competency_Description__c competency : competencies) {
      if (this.competenciesByName.containsKey(competency.Name) == false) {
        this.competenciesByName.put(competency.Name, new List<IFB_CompetencyDescriptionWrapper>());
      }
      this.competenciesByName.get(competency.Name).add(new IFB_CompetencyDescriptionWrapper(competency));
    }   
  }

  /**
   * @description Sorts multiple IFB_Competency_Description__c records and 
   *    returns one record by Competency name. 
   * @return A map of the IFB_Competency_Description__c record that based on
   *    weighted criteria, should be used for the Competency name.
   */   
  public Map<String, IFB_Competency_Description__c> getCompetencyByNameMap() {

    // This is the map we'll return as a result
    Map<String, IFB_Competency_Description__c> competencyByName;
    competencyByName = new Map<String, IFB_Competency_Description__c>();  
    
    // If there is more than one "Competency Description" record
    // we sort them based on the configurations, and match the record
    // against the: Group, Interview Type and Position criteria
    for (String competencyName : this.competenciesByName.keySet()) {
      List<IFB_CompetencyDescriptionWrapper> competencies;
      competencies = competenciesByName.get(competencyName);
      if (competencies.isEmpty() == false) {
        // Custom sort. See "compareTo" method in "IFB_CompetencyDescriptionWrapper"
        competencies.sort();
        IFB_Competency_Description__c competency;
        //We evalue the records for match, in the order defined in the sort()
        competency = this.getFirstCompetencyDescriptionMatch(competencies);
        if (competency != null) {
          competencyByName.put(competencyName, competency);  
        }
      }   
    }

    return competencyByName;
  }

  /**
   * @description From the provided list of "Competency Description" records, 
   *    this method return the first "Competency Description" record that 
   *    matches the criteria. (CASE SENSITIVE)
   * @return  First "Competency Description" record that matches the criteria
   */
  private IFB_Competency_Description__c getFirstCompetencyDescriptionMatch(
      List<IFB_CompetencyDescriptionWrapper> competencies) {
    IFB_Competency_Description__c competencyDescriptionToReturn;
    
    for (IFB_CompetencyDescriptionWrapper competency : competencies) {
      Boolean match = true;
      if (competency.competencyRecord != null) {
        if(competency.competencyRecord.SIFT_Group_Lookup__c != null) {
          match = match && ((competency.competencyRecord.SIFT_Group_Lookup__r.Name).equals(this.criteriaGroup));
        } 
        if(competency.competencyRecord.SIFT_Interview_Type_Lookup__c != null) {
          match = match && ((competency.competencyRecord.SIFT_Interview_Type_Lookup__r.Name).equals(this.criteriaInterviewType));
        }
        if(competency.competencyRecord.SIFT_Position_Lookup__c != null) {
          match = match && ((competency.competencyRecord.SIFT_Position_Lookup__r.Name).equals(this.criteriaPosition));
        }
        if (match == true) {
          competencyDescriptionToReturn = competency.competencyRecord;
          // As soon as we find a match, we "break" the loop
          break;
        }
      }   
    }

    return competencyDescriptionToReturn; 
  }
}