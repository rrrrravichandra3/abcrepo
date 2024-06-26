/**
 * @description Wrapper of Competency Description record. Allow sorting
 *    based on configurable criteria.
 * @author Angel Abrego <aabrego@salesforce.com>
 * @date 2017-10-12
 */
public with sharing class IFB_CompetencyDescriptionWrapper implements Comparable {
  private static Decimal sortingWeightGroup               {get; set;}
  private static Decimal sortingWeightInterviewType       {get; set;}
  private static Decimal sortingWeightPosition            {get; set;}

  public IFB_Competency_Description__c competencyRecord  {get; private set;}
  private Decimal totalSortingWeight = null;

  /**
   * Provide weighting values for the "Group", "Interview Record Type" and
   * "Position" sorting. Values should be one digit positive integers. The higher
   * the number the higher the importance of that field on the sorting. The 
   * weights of all fields that have a value are added up. Compentency Description 
   * records are sorted from higher to lower total weight.
   */
  static {
    // Default weighting values.
    // A record that has a value in "Position" has higher prority than a record
    // that has a value in  both "Interview Record Type" and "Group".
    // This is: 4 > (2 + 1)
    sortingWeightGroup = 1;
    sortingWeightInterviewType = 2;
    sortingWeightPosition = 4;

    IFB_SIFT_Settings_List__c config;
    config = IFB_SIFT_Settings_List__c.getInstance('SIFT');
    // By custom setting we can determine if we want to use the default (harcoded)
    // values of if we want to use the values provided in the configuration record
    // See: "Competency Sorting Weights Values Enabled" boolean field.
    if (config != null && config.Competency_Sorting_Weight_Values_Enabled__c) {
      if (config.Competency_Sorting_Weight_Group__c != null) {
        sortingWeightGroup = config.Competency_Sorting_Weight_Group__c;
      } else {
        sortingWeightGroup = 0;
      }
      if (config.Competency_Sorting_Weight_Interview_RT__c != null) {
        sortingWeightInterviewType = config.Competency_Sorting_Weight_Interview_RT__c;
      } else {
        sortingWeightInterviewType = 0;
      }
      if (config.Competency_Sorting_Weight_Position__c != null) {
        sortingWeightPosition = config.Competency_Sorting_Weight_Position__c;
      } else {
        sortingWeightPosition = 0;
      }
    } 
  }

  /**
   * Constructor. Initialize a wrapper instance from a single "Competency Description"
   * record. "Competency Description" record must have been queried including
   * the following fields:
   *  - Group__c
   *  - Interview_Record_Type__c
   *  - Position__c
   *  - LastModifiedDate
   */
	public IFB_CompetencyDescriptionWrapper(
      IFB_Competency_Description__c competencyRecord) {
		this.competencyRecord = competencyRecord;
	}

  /**
   * @descrtiption Calculates the total sorting weight of a "Competency Description"
   *   record based on the fields that have a value (Group, 
   *   Interview Record Type and/or Position)
   * @return total sorting weight of the "Competency Description" record
   */
  private Decimal getTotalSortingWeight() {
    if (this.totalSortingWeight == null) {
      this.totalSortingWeight = 0;
      if (this.competencyRecord.SIFT_Group_Lookup__c != null) {
        this.totalSortingWeight = this.totalSortingWeight + sortingWeightGroup;
      }
      if (this.competencyRecord.SIFT_Interview_Type_Lookup__c != null) {
        this.totalSortingWeight = this.totalSortingWeight + sortingWeightInterviewType;
      }
      if (this.competencyRecord.SIFT_Position_Lookup__c != null) {
        this.totalSortingWeight = this.totalSortingWeight + sortingWeightPosition;
      }
    }
    return this.totalSortingWeight;
  }

  /**
   * @descrtiption Implementation of the compareTo method of the "Comparable" 
   *    interface. Allows sorting of instances of this class. Sorting crtieria:
   *    - The instances with the higher "Total Sorting Weight" will go first
   *    - As a safety net, if 2 instances have the same "Total Sorting Weight"
   *      the one that was modified more rencently has precedence over the other.
   *    NOTE: The default weighting values (1 ,2 and 4 for Group, Interview 
   *          Record Type and Position respectively) ensure that for non-repeated
   *          combinations, each "Comptency Descrition" record has a different
   *          total weight. This safety net is for escenarios where there are 
   *          duplicate configuration records. Eg. Two records that have
   *          the same Group and Position values (wrong setup).
   */
  public Integer compareTo(Object compareTo) {
    Integer compareToResult = 0; //By default, two instances are equal
    IFB_CompetencyDescriptionWrapper compareToCompetencyDescriptionWrapper;
    compareToCompetencyDescriptionWrapper = (IFB_CompetencyDescriptionWrapper)compareTo;

    if (this.getTotalSortingWeight() > compareToCompetencyDescriptionWrapper.getTotalSortingWeight()) {
      compareToResult = -1;
      System.debug('some record was greater than other!'+ this.competencyRecord.Name);
    } else if (this.getTotalSortingWeight() < compareToCompetencyDescriptionWrapper.getTotalSortingWeight()) {
      compareToResult = 1;
    } else if (this.competencyRecord.LastModifiedDate > compareToCompetencyDescriptionWrapper.competencyRecord.LastModifiedDate) {
      compareToResult = -1;
    } else if (this.competencyRecord.LastModifiedDate < compareToCompetencyDescriptionWrapper.competencyRecord.LastModifiedDate) {
      compareToResult = 1;
    }
    return compareToResult;
  }
}