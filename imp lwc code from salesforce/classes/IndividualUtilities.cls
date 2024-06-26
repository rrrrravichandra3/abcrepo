public with sharing class IndividualUtilities {
  @AuraEnabled
  public static String getIndividualId(Id recordId) {
    //Get sObject Type to determine which individual field to query
    Schema.SObjectType sobjectType = recordId.getSObjectType();

    String sobjectTypeString = sobjectType.getDescribe().getName();

    String individualId;

    switch on sobjectTypeString {
      when 'Contact' {
        individualId = getIndividualIdFromContact(recordId);

        if (individualId == null) {
          individualId = 'No Individual';
        }
      }
      when 'Lead' {
        individualId = getIndividualIdFromLead(recordId);

        if (individualId == null) {
          individualId = 'No Individual';
        }
      }
      when else {
        individualId = 'No Individual';
      }
    }

    return individualId;
  }

  @AuraEnabled(cacheable=true)
  public static String getSObjectType(Id recordId) {
    Schema.SObjectType sObjectType = recordId.getSObjectType();

    String sObjectString = String.valueOf(sObjectType);

    return sObjectString;
  }

  public static String getIndividualIdFromContact(Id recordId) {
    List<Contact> result = [SELECT IndividualId FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
    Contact contact = (result.size() == 1) ? result.get(0) : null;

    return contact.IndividualId;
  }

  public static String getIndividualIdFromLead(Id recordId) {
    List<Lead> result = [SELECT IndividualId FROM Lead WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
    Lead lead = (result.size() == 1) ? result.get(0) : null;

    return lead.IndividualId;
  }
}