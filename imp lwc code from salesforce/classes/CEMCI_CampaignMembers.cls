/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 02-15-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class CEMCI_CampaignMembers {
  public static List<CampaignMember> campaignMembers;
  public static List<Lead> cmLeads;
  public static List<Contact> cmContacts;
  public static Set<Id> leadSet;
  public static Set<Id> conSet;
  public static Set<Id> campSet;
  public static Lead l;
  public static Contact c;
  public static Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();
  public static Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
  public static Map<Id, Lead> leadMap;
  public static Map<Id, Contact> contactMap;
  public static Map<Id, Campaign> campMap;
  public static List<CampaignMember> oldCampaignMembers;
  public static Map<Id, CampaignMember> newCampaignMemberMap = new Map<Id, CampaignMember>();
  public static Map<Id, CampaignMember> oldCampaignMemberMap = new Map<Id, CampaignMember>();
  public static Set<Id> individuals = new Set<Id>();
  public static List<CampaignMember> validCampaignMembers;
  public static List<CampaignMember> campMembers = new List<CampaignMember>();
  private static Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('WDR_Candidate')
    .getRecordTypeId();

  public CEMCI_CampaignMembers() {
    if (string.isBlank(contactRecTypeId))
      contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('WDR_Candidate')
        .getRecordTypeId();
  }
  //*******************************************************************************
  // Method to validate Campaign members and identify records to be processed
  //*******************************************************************************

  public static Map<Id, Id> convertedLeadtoContactMap = new Map<Id, Id>();

  public static void populateProcessingFields() {
    try {
      conSet = new Set<Id>();
      leadSet = new Set<id>();
      Set<Id> campSet = new Set<Id>();
      validCampaignMembers = new List<CampaignMember>();

      for (CampaignMember m : campaignMembers) {
        if (m.ContactId != null) {
          conSet.add(m.ContactId);
          campSet.add(m.CampaignId);
        } else if (m.LeadId != null && m.ContactId == null) {
          leadSet.add(m.LeadId);
          validCampaignMembers.add(m);
        }
      }

      leadMap = new Map<Id, Lead>(
        [
          SELECT
            Id,
            Marketing_Opt_In__c,
            Recruiting_Opt_In__c,
            IndividualId,
            Initial_Interaction_Date__c,
            Last_Interaction_Date__c,
            IsConverted,
            ConvertedContactId
          FROM Lead
          WHERE Id IN :leadSet
        ]
      );

      for (Lead ld : leadMap.values()) {
        if (ld.isConverted) {
          leadMap.remove(ld.id);
          conSet.add(ld.ConvertedContactId);
          convertedLeadtoContactMap.put(ld.id, ld.ConvertedContactId);
        }
      }

      if (!convertedLeadtoContactMap.isEmpty()) {
        for (CampaignMember m : validCampaignMembers) {
          if (m.LeadId != null && m.ContactId == null && convertedLeadtoContactMap.containsKey(m.LeadId)) {
            m.ContactId = convertedLeadtoContactMap.get(m.LeadId);
            m.LeadId = null;
          }
        }
      }

      contactMap = new Map<Id, Contact>(
        [
          SELECT
            Id,
            Marketing_Opt_In__c,
            Recruiting_Opt_In__c,
            IndividualId,
            Total_Job_Applications__c,
            Active_Job_Applications__c,
            RecordTypeId,
            Initial_Interaction_Date__c,
            Last_Interaction_Date__c
          FROM Contact
          WHERE Id IN :conSet
        ]
      );

      campMap = new Map<Id, Campaign>([SELECT Id, StartDate FROM Campaign WHERE Id IN :campSet]);
      for (CampaignMember m : campaignMembers) {
        if (m.ContactId != null) {
          if (
            contactMap.get(m.ContactId).RecordTypeId != null &&
            string.isNotBlank(contactRecTypeId) &&
            string.valueOf(contactRecTypeId).equalsIgnoreCase(contactMap.get(m.ContactId).RecordTypeId)
          )
            validCampaignMembers.add(m);
        }
      }
    } catch (exception e) {
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        String.valueOf(e.getCause()),
        ' line no ',
        String.valueOf(e.getLineNumber()),
        null,
        String.valueOf(e.getMessage()),
        ' Error during CEMCI_CampaignMembers.populateProcessingFields'
      );
    }
  }

  //*******************************************************************************
  // Method to copy Marketing Opt In & Recruiting Opt In from Lead or Contact
  //*******************************************************************************

  public static void copyOptInFields() {
    try {
      String contactMarketing, contactRecruiting, leadMarketing, leadRecruiting;

      for (CampaignMember m : validCampaignMembers) {
        if (m.ContactId != null && m.Marketing_Opt_In__c == null && m.Recruiting_Opt_In__c == null) {
          c = contactMap.get(m.ContactId);
          if (c.Marketing_Opt_In__c != null || c.Recruiting_Opt_In__c != null) {
            contactMarketing = c.Marketing_Opt_In__c;
            contactRecruiting = c.Recruiting_Opt_In__c;
            m.Marketing_Opt_In__c = contactMarketing;
            m.Recruiting_Opt_In__c = contactRecruiting;
          }
        } else if (
          m.LeadId != null &&
          m.ContactId == null &&
          m.Marketing_Opt_In__c == null &&
          m.Recruiting_Opt_In__c == null
        ) {
          l = leadMap.get(m.LeadId);
          if (l.Marketing_Opt_In__c != null || l.Recruiting_Opt_In__c != null) {
            leadMarketing = l.Marketing_Opt_In__c;
            leadRecruiting = l.Recruiting_Opt_In__c;
            m.Marketing_Opt_In__c = leadMarketing;
            m.Recruiting_Opt_In__c = leadRecruiting;
          }
        }
      }
    } catch (Exception e) {
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        String.valueOf(e.getCause()),
        ' line no ',
        String.valueOf(e.getLineNumber()),
        null,
        String.valueOf(e.getMessage()),
        ' Error during CEMCI_CampaignMembers.copyOptInFields'
      );
    }
  }
  //*******************************************************************************
  // Method to create AuthorizationFormConsents from Opt In/Out
  //*******************************************************************************

  public static void creatingAuthorizationConsentForCampaignMembers() {
    if (!leadsToUpdate.isEmpty()) {
      for (Id ldId : leadsToUpdate.keySet()) {
        leadMap.put(ldId, leadsToUpdate.get(ldId));
      }
    }
    if (!contactsToUpdate.isEmpty()) {
      for (Id ctId : contactsToUpdate.keySet()) {
        contactMap.put(ctId, contactsToUpdate.get(ctId));
      }
    }

    if (oldCampaignMemberMap != null) {
      for (Id campId : newCampaignMemberMap.keySet()) {
        CampaignMember newCM = newCampaignMemberMap.get(campId);
        CampaignMember oldCM = oldCampaignMemberMap.get(campId);

        if (
          newCM.Recruiting_Opt_In__c != oldCM.Recruiting_Opt_In__c ||
          newCM.Marketing_Opt_In__c != oldCM.Marketing_Opt_In__c
        ) {
          campMembers.add(newCM);
        }
      }
      if (campMembers != null && !campMembers.isEmpty()) {
        CEMCI_AuthorizationFormConsent authorizationForm = new CEMCI_AuthorizationFormConsent(campMembers);
        authorizationForm.setLeads(leadMap);
        authorizationForm.setContacts(contactMap);
        authorizationForm.setAuthorizationFormConsents();
      }
    } else if (campaignMembers != null && !campaignMembers.isEmpty()) {
      CEMCI_AuthorizationFormConsent authorizationForm = new CEMCI_AuthorizationFormConsent(campaignMembers);
      authorizationForm.setLeads(leadMap);
      authorizationForm.setContacts(contactMap);
      authorizationForm.setAuthorizationFormConsents();
    }
  }

  public static void validateCampaignMemberDeletion(){
    if (!(Schema.sObjectType.Campaign.isAccessible() && (Schema.sObjectType.Contact.isUpdateable() || Schema.sObjectType.Lead.isUpdateable()))) {
        for(CampaignMember cm: oldCampaignMembers){
            cm.addError('You do not have a permission to remove campaign member');
        }
    }
  } 

  //*******************************************************************************
  // Method to update Application Counts on Lead or Contact
  //*******************************************************************************

  public static void updateApplicationCounts() {
    try {
      //all applications to be considered
      set<Id> setCandidatesIds = new Set<Id>();
      Map<Id, set<Id>> cntctIdToCandidateIdMap = new Map<Id, set<Id>>();
      for (WDR_Candidate__c can : [
        SELECT Id, Candidate_Contact__c
        FROM WDR_Candidate__c
        WHERE Candidate_Contact__c IN :conSet
      ]) {
        setCandidatesIds.add(can.Id);
        if (!cntctIdToCandidateIdMap.containsKey(can.Candidate_Contact__c)) {
          cntctIdToCandidateIdMap.put(can.Candidate_Contact__c, new Set<Id>());
        }
        cntctIdToCandidateIdMap.get(can.Candidate_Contact__c).add(can.Id);
      }
      List<WDR_Application__c> appList = new List<WDR_Application__c>(
        [
          SELECT
            Id,
            Candidate__c,
            Candidate__r.Candidate_Contact__c,
            CreatedDate,
            Candidate_Stage__c,
            Application_Date__c,
            Last_Recruiting_Stage__c
          FROM WDR_Application__c
          WHERE Candidate__c IN :setCandidatesIds
        ]
      );

      //collections to calculate totals
      Set<Id> totalApps;
      Set<Id> activeApps;
      Map<Id, List<WDR_Application__c>> contactToApplMap = new Map<Id, List<WDR_Application__c>>();

      for (WDR_Application__c app : appList) {
        if (!contactToApplMap.containsKey(app.Candidate__r.Candidate_Contact__c)) {
          contactToApplMap.put(app.Candidate__r.Candidate_Contact__c, new List<WDR_Application__c>());
        }
        contactToApplMap.get(app.Candidate__r.Candidate_Contact__c).add(app);
      }

      //get totals
      for (CampaignMember m : validCampaignMembers) {
        totalApps = new Set<Id>();
        activeApps = new Set<Id>();
        if (
          campMap != null &&
          contactToApplMap.get(m.ContactId) != null &&
          contactMap.containsKey(m.ContactId) &&
          cntctIdToCandidateIdMap.containsKey(m.contactId) &&
          !cntctIdToCandidateIdMap.get(m.ContactId).isEmpty()
        ) {
          for (WDR_Application__c a : contactToApplMap.get((m.ContactId))) {
            Datetime campStart = campMap.containsKey(m.CampaignId) ? campMap.get(m.CampaignId).StartDate : null;
            Datetime appCreate = a.CreatedDate;
            if (campStart != null && appCreate != null) {
              //Total Application Count
              if (appCreate > campStart) {
                totalApps.add(a.Id);
              }
              //Active Application Count
              if (
                appCreate > campStart &&
                (a.Candidate_Stage__c != 'Declined by Candidate' &&
                a.Candidate_Stage__c != 'Rejected')
              ) {
                activeApps.add(a.Id);
              }
              //Hired checkbox
              if (
                appCreate > campStart &&
                (a.Candidate_Stage__c == 'Placement' ||
                a.Candidate_Stage__c == 'Pre-Placement')
              ) {
                m.Hired__c = true;
              }
            }
          }
        }
        if (totalApps <> null && !totalApps.isEmpty()) {
          integer totalAppCount = totalApps.size();
          m.Total_Job_Applications__c = totalAppCount;
        }
        if (activeApps <> null && !activeApps.isEmpty()) {
          integer activeAppCount = activeApps.size();
          m.Active_Job_Applications__c = activeAppCount;
        }
      }
    } catch (Exception e) {
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        String.valueOf(e.getCause()),
        ' line no ',
        String.valueOf(e.getLineNumber()),
        null,
        String.valueOf(e.getMessage()),
        ' Error during CEMCI_CampaignMembers.updateApplicationCounts'
      );
    }
  }

  //*******************************************************************************
  // Method to update Application Counts on Lead or Contact
  //*******************************************************************************
  private class flsException extends Exception {
  }
  public static void updateDatesFromCampaign() {
    Boolean IsLinkedInUser = FeatureManagement.checkPermission('CEMCI_LinkedIn_Integration_User');
    if (!IsLinkedInUser) {
      try {
        for (CampaignMember m : validCampaignMembers) {
          if (m.Member_Responded_Datetime__c != null && m.HasResponded == true) {
            Integer s = m.Member_Responded_Datetime__c.second();
            Integer min = m.Member_Responded_Datetime__c.minute();
            Integer h = m.Member_Responded_Datetime__c.hour();
            Integer d = m.Member_Responded_Datetime__c.day();
            Integer mo = m.Member_Responded_Datetime__c.month();
            Integer yr = m.Member_Responded_Datetime__c.year();
            DateTime cmResponded = DateTime.newInstance(yr, mo, d, h, min, s);
            Boolean cotactFieldsAccessible = PF_AccessibilityUtils.checkFLS(
              'Contact',
              PF_AccessibilityUtils.PermissionType.UPDATEABLE,
              new List<string>{ 'Initial_Interaction_Date__c', 'Last_Interaction_Date__c' }
            );
            Boolean leadFieldsAccessible = PF_AccessibilityUtils.checkFLS(
              'Lead',
              PF_AccessibilityUtils.PermissionType.UPDATEABLE,
              new List<string>{ 'Initial_Interaction_Date__c', 'Last_Interaction_Date__c' }
            );
            if (!cotactFieldsAccessible) {
              throw new flsException('The Admin running user does not have sufficient access on Contact fields');
            }
            if (!leadFieldsAccessible) {
              throw new flsException('The Admin running user does not have sufficient access on Lead fields');
            }
            if (m.ContactId != null) {
              Contact c = contactMap.get(m.ContactId);
              //update contacts if date is blank OR needs to be updated
              if (
                c.Initial_Interaction_Date__c == null ||
                c.Initial_Interaction_Date__c > m.Member_Responded_Datetime__c
              ) {
                c.Initial_Interaction_Date__c = cmResponded;
                contactsToUpdate.put(c.Id, c);
              }
              if (c.Last_Interaction_Date__c == null || c.Last_Interaction_Date__c < m.Member_Responded_Datetime__c) {
                c.Last_Interaction_Date__c = cmResponded;
                contactsToUpdate.put(c.Id, c);
              }
            } else if (m.LeadId != null && m.ContactId == null) {
              Lead l = leadMap.get(m.LeadId);
              //add leads if date is blank OR needs to be updated
              if (
                l.Initial_Interaction_Date__c == null ||
                l.Initial_Interaction_Date__c > m.Member_Responded_Datetime__c
              ) {
                Datetime leadFirst = m.Member_Responded_Datetime__c;
                l.Initial_Interaction_Date__c = cmResponded;
                leadsToUpdate.put(l.Id, l);
              }
              if (l.Last_Interaction_Date__c == null || l.Last_Interaction_Date__c < m.Member_Responded_Datetime__c) {
                Datetime leadLast = m.Member_Responded_Datetime__c;
                l.Last_Interaction_Date__c = cmResponded;
                leadsToUpdate.put(l.Id, l);
              }
            }
          }
        }
      } catch (Exception e) {
        PF_Logger.log(
          'CEMCI',
          'ERROR',
          String.valueOf(e.getCause()),
          ' line no ',
          String.valueOf(e.getLineNumber()),
          null,
          String.valueOf(e.getMessage()),
          ' Error during CEMCI_CampaignMembers.updateDatesFromCampaign'
        );
      }
    }
  }

  @InvocableMethod(label='Populate Campaign Fields' description='Populates fields from Campaign on Leads or Contacts')
  public static void invokeActiononMembers(List<Id> recordIds) {
    populateCampaignFieldsonMembers(recordIds);
  }

  @future
  public static void populateCampaignFieldsonMembers(List<Id> recordIds) {
    Map<Id, Lead> mapIdtoLeadToUpdate = new Map<Id, Lead>();
    Map<Id, Contact> mapIdtoContactUpdate = new Map<Id, Contact>();
    Set<Id> leadIdSet = new Set<Id>();
    Set<Id> contactIdSet = new Set<Id>();
    Set<Id> campaignIdSet = new Set<Id>();

    List<CampaignMember> memberList = [SELECT LeadId, ContactId, CampaignId FROM CampaignMember WHERE Id IN :recordIds];
    for (CampaignMember member : memberList) {
      if (member.LeadId != null)
        leadIdSet.add(member.LeadId);
      if (member.contactId != null)
        contactIdSet.add(member.ContactId);
      if (member.CampaignId != null)
        campaignIdSet.add(member.CampaignId);
    }

    Map<Id, Campaign> relatedCampaigns = new Map<Id, Campaign>(
      [
        SELECT Id, Region__c, Segment__c, Job_Family__c, Job_Profile__c, Geo_Hub__c
        FROM Campaign
        WHERE
          Id IN :campaignIdSet
          AND (Region__c != NULL
          OR Segment__c != NULL
          OR Job_Family__c != NULL
          OR Job_Profile__c != NULL
          OR Geo_Hub__c != NULL)
      ]
    );
    Map<Id, Lead> relatedLeads = new Map<Id, Lead>(
      [SELECT Id, Region__c, Segment__c, Job_Family__c, Job_Profile__c, Geo_Hub__c FROM Lead WHERE Id IN :leadIdSet]
    );
    Map<Id, Contact> relatedContacts = new Map<Id, Contact>(
      [
        SELECT Id, Region__c, Segment__c, Job_Family__c, Job_Profile__c, Geo_Hub__c
        FROM Contact
        WHERE Id IN :contactIdSet
      ]
    );

    if (relatedCampaigns.size() > 0 && (relatedLeads.size() > 0 || relatedContacts.size() > 0)) {
      for (CampaignMember member : memberList) {
        if (
          member.LeadId != null &&
          relatedLeads.containsKey(member.LeadId) &&
          relatedCampaigns.containsKey(member.campaignId) &&
          relatedLeads.get(member.LeadId) != null &&
          relatedCampaigns.get(member.campaignId) != null
        ) {
          Lead updateLead = relatedLeads.get(member.LeadId);
          updateLead.Region__c = updateLead.Region__c == null
            ? relatedCampaigns.get(member.campaignId).Region__c
            : updateLead.Region__c;
          updateLead.Segment__c = updateLead.Segment__c == null
            ? relatedCampaigns.get(member.campaignId).Segment__c
            : CEMCI_Util.appendValueToMultipicklist(
                updateLead.Segment__c,
                relatedCampaigns.get(member.campaignId).Segment__c
              );
          updateLead.Job_Family__c = updateLead.Job_Family__c == null
            ? relatedCampaigns.get(member.campaignId).Job_Family__c
            : CEMCI_Util.appendValueToMultipicklist(
                updateLead.Job_Family__c,
                relatedCampaigns.get(member.campaignId).Job_Family__c
              );
          updateLead.Job_Profile__c = updateLead.Job_Profile__c == null
            ? relatedCampaigns.get(member.campaignId).Job_Profile__c
            : CEMCI_Util.appendValueToMultipicklist(
                updateLead.Job_Profile__c,
                relatedCampaigns.get(member.campaignId).Job_Profile__c
              );
          updateLead.Geo_Hub__c = updateLead.Geo_Hub__c == null
            ? relatedCampaigns.get(member.campaignId).Geo_Hub__c
            : CEMCI_Util.appendValueToMultipicklist(
                updateLead.Geo_Hub__c,
                relatedCampaigns.get(member.campaignId).Geo_Hub__c
              );

          mapIdtoLeadToUpdate.put(updateLead.Id, updateLead);
        }
        if (
          member.ContactId != null &&
          relatedContacts.containsKey(member.ContactId) &&
          relatedCampaigns.containsKey(member.campaignId) &&
          relatedContacts.get(member.ContactId) != null &&
          relatedCampaigns.get(member.campaignId) != null
        ) {
          Contact updateContact = relatedContacts.get(member.ContactId);
          updateContact.Region__c = updateContact.Region__c == null
            ? relatedCampaigns.get(member.campaignId).Region__c
            : updateContact.Region__c;
          updateContact.Segment__c = updateContact.Segment__c == null
            ? relatedCampaigns.get(member.campaignId).Segment__c
            : CEMCI_Util.appendValueToMultipicklist(
                updateContact.Segment__c,
                relatedCampaigns.get(member.campaignId).Segment__c
              );
          updateContact.Job_Family__c = updateContact.Job_Family__c == null
            ? relatedCampaigns.get(member.campaignId).Job_Family__c
            : CEMCI_Util.appendValueToMultipicklist(
                updateContact.Job_Family__c,
                relatedCampaigns.get(member.campaignId).Job_Family__c
              );
          updateContact.Job_Profile__c = updateContact.Job_Profile__c == null
            ? relatedCampaigns.get(member.campaignId).Job_Profile__c
            : CEMCI_Util.appendValueToMultipicklist(
                updateContact.Job_Profile__c,
                relatedCampaigns.get(member.campaignId).Job_Profile__c
              );
          updateContact.Geo_Hub__c = updateContact.Geo_Hub__c == null
            ? relatedCampaigns.get(member.campaignId).Geo_Hub__c
            : CEMCI_Util.appendValueToMultipicklist(
                updateContact.Geo_Hub__c,
                relatedCampaigns.get(member.campaignId).Geo_Hub__c
              );

          mapIdtoContactUpdate.put(updateContact.Id, updateContact);
        }
      }
      if (mapIdtoLeadToUpdate.values().size() > 0) {
        Database.SaveResult[] updateLeadResult = Database.update(mapIdtoLeadToUpdate.values(), false);
      }
      if (mapIdtoContactUpdate.values().size() > 0) {
        Database.SaveResult[] updateContactResult = Database.update(mapIdtoContactUpdate.values(), false);
      }
    }
  }
}