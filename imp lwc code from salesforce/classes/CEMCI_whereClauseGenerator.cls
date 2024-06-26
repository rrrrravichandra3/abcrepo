/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 10-18-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public class CEMCI_whereClauseGenerator {
  public String field;
  public String operator;
  public Object value;

  public CEMCI_whereClauseGenerator() {
  }

  /**
   * @description CEMCI_whereClauseGenerator description
   * @param  wrapper : Takes in the wrapper contaning infor to create a SOQL WHERE criteria
   * @return         return description
   */

  public CEMCI_whereClauseGenerator(CEMCI_SearchDataModel.ClauseWrapper wrapper) {
    this.field = wrapper.field;
    this.value = wrapper.value;
    this.operator = wrapper.operator;
  }

  /**
   * @description getSOQLCriteria creates a where clause criteria based on the value passed to the constructor
   *              (ex: Candidate_Stage__c = 'Review')
   * @return   return criteria
   */
  public String getSOQLCriteria() {
    if (operator == '=' || operator == '!=')
      return field + ' ' + operator + ' \'' + value + '\'';
    else if (operator == '>' || operator == '<')
      return field + ' ' + operator + ' ' + value + ' ';
    else if (operator == 'LIKE')
      return field + ' ' + operator + ' \'%' + value + '%\'';
    else if (operator == 'boolean')
      return field + ' ' + '=' + ' ' + value;
    else if (operator == 'IN' || operator == 'NOT IN') {
      value = String.valueOf(value).remove('(');
      value = String.valueOf(value).remove(')');
      String comparator = '(';

      for (String str : String.valueOf(value).split(',')) {
        str = str.replace('\'', '\\\'');
        str = str.trim();
        comparator += '\'' + str + '\',';
      }
      comparator = comparator.removeEnd(',');
      comparator += ')';
      comparator = comparator.trim();
      return field + ' ' + operator + ' ' + comparator;
    } else
      return '';
  }

  public Boolean isFieldValueGiven() {
    return value != null && value != '';
  }

  /**
   * @description generateWhereQuery will add up all the criterias to form a string
   * @param  criterias : All criteria based on selected filters and default filters
   * @return return WHERE Clause of Full joined criteria
   */
  public String generateWhereQuery(
    List<CEMCI_whereClauseGenerator> criterias,
    List<CEMCI_whereClauseGenerator> tagsCriteria
  ) {
    List<String> and_conditions = new List<String>();
    List<String> tags_or_conditions = new List<String>();
    String tagsSoqlCondition;
    if (!tagsCriteria.isEmpty()) {
      tagsSoqlCondition = 'Id IN (SELECT Contact__c FROM CEMCI_TagAssignment__c WHERE Topic__r.Name IN (';
      List<String> tagsList = new List<String>();
      for (CEMCI_whereClauseGenerator tag_single_criteria : tagsCriteria) {
        if (tag_single_criteria.IsFieldValueGiven()) {
          tagsList.add(String.valueOf(tag_single_criteria.value));
        }
      }

      String tagString = '\'' + String.join(tagsList, '\',\'') + '\'';
      tagsSoqlCondition += tagString + ') AND Contact__c != null)';

      and_conditions.add(tagsSoqlCondition);
    }

    for (CEMCI_whereClauseGenerator single_criteria : criterias) {
      if (single_criteria.IsFieldValueGiven()) {
        and_conditions.add(single_criteria.getSOQLCriteria());
      }
    }
    return String.join(and_conditions, ' AND ');
  }

  public String generateLocationQuery(CEMCI_whereClauseGenerator locationCriteria) {
    String condition = '';
    if (locationCriteria != null) {
      Object value = locationCriteria.value;
      String values = String.valueOf(value);
      Map<String, Object> geoValues = (Map<String, Object>) JSON.deserializeUntyped(values);
      condition =
        'DISTANCE(Location__c, GEOLOCATION(' +
        geoValues.get('lat') +
        ',' +
        geoValues.get('lng') +
        '),' +
        ' \'mi\'' +
        ') < ' +
        geoValues.get('distance') +
        ' AND ';
    }
    return condition;
  }
}