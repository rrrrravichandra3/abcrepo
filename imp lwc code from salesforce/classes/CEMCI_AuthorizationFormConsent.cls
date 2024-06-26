public with sharing class CEMCI_AuthorizationFormConsent {
  private List<Sobject> sobjectRecords;
  private Map<Id, Campaign> campaignById;
  private Map<Id, Contact> contactById;
  private Map<Id, Lead> leadById;
  private Map<Id, WDR_Application__c> jobAppplicationByContactId = new Map<Id, WDR_Application__c>();
  private Map<Id, String> campaignIdByName = new Map<Id, String>();
  private List<CampaignMember> CampaignMembers = new List<CampaignMember>();
  private Set<Id> individuals = new Set<Id>();
  private Map<Id, List<AuthorizationFormText>> authorizationFormTextByAuthorizationFromId = new Map<Id, List<AuthorizationFormText>>();
  private Map<Id, Id> authorizationFormId = new Map<Id, Id>();
  private Map<Id, ContactPointEmail> individualsWithContactPointEmail = new Map<Id, ContactPointEmail>();
  private Map<Id, ContactPointPhone> IndividualWithContactPointPhone = new Map<Id, ContactPointPhone>();
  private Map<Id, List<AuthorizationFormConsent>> individualsWithAutorizationFormConsent = new Map<Id, List<AuthorizationFormConsent>>();
  private Map<Id, sObject> mapOfIdLeadAndContact = new Map<Id, sObject>();
  private Map<String, String> mapOfIdMarkRecOptValue = new Map<String, String>();
  private Set<Id> campaignIds = new Set<id>();
  private Set<Id> AuthorizationFormIds = new Set<id>();
  private List<AuthorizationFormConsent> authorizationFormConsents = new List<AuthorizationFormConsent>();
  private List<AuthorizationFormConsent> recentAuthorizatioFormConsents = new List<AuthorizationFormConsent>();
  private List<AuthorizationFormConsent> updateAuthorizationsOfPreviousCampaign = new List<AuthorizationFormConsent>();
  private List<AuthorizationFormText> authorizationFormTexts = new List<AuthorizationFormText>();
  private Map<Id, String> authFormByCampaignId = new Map<Id, String>();
  private static final String Marketing_EmailOptIn = 'MarketingEmailOpt In';
  private static final String Marketing_EmailOptOut = 'MarketingEmailOpt Out';
  private static final String Recruiting_EmailOptIn = 'RecruitingEmailOpt In';
  private static final String Recruiting_EmailOptOut = 'RecruitingEmailOpt Out';
  private static final String Recruiting_PhoneOptIn = 'RecruitingPhoneOpt In';
  private static final String Recruiting_PhoneOptOut = 'RecruitingPhoneOpt Out';

  public CEMCI_AuthorizationFormConsent(List<Sobject> sobjectRecords) {
    this.sobjectRecords = sobjectRecords;
  }

  public void setLeads(Map<Id, Lead> leadById) {
    this.leadById = leadById;
  }
  public void setIndividuals(Set<Id> individuals) {
    this.individuals = individuals;
  }
  public void setAuthorizationFormIds(Set<Id> AuthorizationFormIds) {
    this.AuthorizationFormIds = AuthorizationFormIds;
  }
  public void setJobAppForContactId(Map<Id, WDR_Application__c> jobAppplicationByContactId) {
    this.jobAppplicationByContactId = jobAppplicationByContactId;
  }
  public void setContacts(Map<Id, Contact> contactById) {
    this.contactById = contactById;
  }
  public void setAuthorizationFormConsents() {
    setCampaignsAndIndividuals();
    setExistingConsents();
    setFormTextsByCampaign();
    stopProcessingIfNoAuthorizationForm();
    insertAuthorizationFormConsentRecords();
    updateAuthorizationFormConsentRecords();
    updateLeadContact();
  }
  public void setAuthorizationFormConsentsForJobApp() {
    setExistingConsents();
    setFormTextsByCampaign();
    stopProcessingAuthorizationformConsentForJobApp();
    insertAuthorizationFormConsentRecords();
    updateAuthorizationFormConsentRecords();
  }
  private void setCampaignsAndIndividuals() {
    for (Contact c : contactById.values()) {
      mapOfIdLeadAndContact.put(c.id, c);
    }
    for (Lead l : leadById.values()) {
      mapOfIdLeadAndContact.put(l.id, l);
    }

    campaignMembers = (List<CampaignMember>) sobjectRecords;
    for (CampaignMember m : campaignMembers) {
      campaignIds.add(m.CampaignId);
      if (m.ContactId != null) {
        Contact con = contactById.get(m.ContactId);
        if (con != null) {
          individuals.add(con.IndividualId);
        }
      } else if (m.LeadId != null && m.ContactId == null) {
        Lead l = leadById.get(m.LeadId);
        if (l != null) {
          individuals.add(l.IndividualId);
        }
      }
    }

    for (Campaign camp : [
      SELECT Id, Name, Authorization_Form__c, Authorization_Form__r.name
      FROM Campaign
      WHERE Authorization_Form__c != NULL AND id IN :campaignIds
    ]) {
      authorizationFormId.put(camp.Id, camp.Authorization_Form__c);
      campaignIdByName.put(camp.Id, camp.Name);
      authFormByCampaignId.put(camp.Id, camp.Authorization_Form__r.name);
      AuthorizationFormIds.add(camp.Authorization_Form__c);
    }
  }
  private void setExistingConsents() {
    for (AuthorizationFormConsent authFormconsent : [
      SELECT
        Id,
        ConsentGiverId,
        IsActive__c,
        AuthorizationFormText.Id,
        AuthorizationFormText.Consent_Category__c,
        AuthorizationFormText.Consent_Type__c,
        AuthorizationFormText.Opt_In_Out__c,
        Member_Responded_Datetime__c
      FROM AuthorizationFormConsent
      WHERE ConsentGiverId IN :individuals AND IsActive__c = TRUE
    ]) {
      if (individualsWithAutorizationFormConsent.containsKey(authFormconsent.ConsentGiverId)) {
        individualsWithAutorizationFormConsent.get(authFormconsent.ConsentGiverId).add(authFormconsent);
      } else {
        individualsWithAutorizationFormConsent.put(
          authFormconsent.ConsentGiverId,
          new List<AuthorizationFormConsent>{ authFormconsent }
        );
      }
    }
  }

  private void setFormTextsByCampaign() {
    for (AuthorizationFormText AauthorizationForm : [
      SELECT Id, Consent_Category__c, Consent_Type__c, Opt_In_Out__c, AuthorizationFormId
      FROM AuthorizationFormText
      WHERE AuthorizationFormId IN :AuthorizationFormIds
    ]) {
      if (authorizationFormTextByAuthorizationFromId.containsKey(AauthorizationForm.AuthorizationFormId)) {
        authorizationFormTextByAuthorizationFromId.get(AauthorizationForm.AuthorizationFormId).add(AauthorizationForm);
      } else {
        authorizationFormTextByAuthorizationFromId.put(
          AauthorizationForm.AuthorizationFormId,
          new List<AuthorizationFormText>{ AauthorizationForm }
        );
      }
    }
  }

  private void stopProcessingIfNoAuthorizationForm() {
    campaignMembers = (List<CampaignMember>) sobjectRecords;
    for (CampaignMember campaignmem : campaignMembers) {
      if (authorizationFormId.containsKey(campaignmem.CampaignId)) {
        if (campaignmem.ContactId != null) {
          Sobject objectRecord = contactById.get(campaignmem.ContactId);
          if (campaignmem.Marketing_Opt_In__c != null || campaignmem.Recruiting_Opt_In__c != null) {
            generateConsentsNeeded(objectRecord, campaignmem);
          }
        } else if (campaignmem.LeadId != null && campaignmem.ContactId == null) {
          Sobject objectRecord = leadById.get(campaignmem.LeadId);
          if (campaignmem.Marketing_Opt_In__c != null || campaignmem.Recruiting_Opt_In__c != null) {
            generateConsentsNeeded(objectRecord, campaignmem);
          }
        }
      }
    }
  }

  private void stopProcessingAuthorizationformConsentForJobApp() {
    WDR_Application__c wdJobApp;
    List<contact> contactsForProcessing = (List<contact>) sobjectRecords;
    for (Contact con : contactsForProcessing) {
      wdJobApp = jobAppplicationByContactId.get(con.id);
      generateConsentsNeeded(con, con);
    }
  }

  private void generateConsentsNeeded(Sobject objectRecord, Sobject consentRecord) {
    Id individual = (id) objectRecord.get('IndividualId');
    Id authorizationId;
    List<authorizationFormConsent> authorizationFormCons;
    if (consentRecord.getSObjectType() == CampaignMember.sObjectType) {
      authorizationFormTexts = authorizationFormTextByAuthorizationFromId.get(
        authorizationFormId.get((Id) consentRecord.get('CampaignId'))
      );
    } else {
      authorizationId = (new List<Id>(AuthorizationFormIds)[0]);
      authorizationFormTexts = authorizationFormTextByAuthorizationFromId.get(authorizationId);
    }
    if (individualsWithAutorizationFormConsent.containsKey(individual)) {
      recentAuthorizatioFormConsents = individualsWithAutorizationFormConsent.get(individual);
      authorizationFormCons = excludeConsentsIfAlreadyPresent(
        recentAuthorizatioFormConsents,
        consentRecord,
        authorizationFormTexts,
        objectRecord
      );
      if (authorizationFormCons != null) {
        authorizationFormConsents.addall(authorizationFormCons);
      }
    } else {
      authorizationFormCons = createAuthorizationBasedOnTheOptInOrOptOut(
        consentRecord,
        objectRecord,
        AuthorizationFormTexts,
        true,
        true,
        true
      );
      authorizationFormConsents.addall(authorizationFormCons);
    }
  }
  private List<AuthorizationFormConsent> excludeConsentsIfAlreadyPresent(
    List<AuthorizationFormConsent> recentAuthorizatioFormConsents,
    SObject consentRecord,
    List<AuthorizationFormText> authorizationFormTexts,
    SObject objectRecord
  ) {
    String checkTheAuthorizationFormText;
    Id authorizationId;
    Map<String, String> previousCampignMemberValues = new Map<String, String>();
    List<AuthorizationFormConsent> deActivateConsentAuthorization;
    List<authorizationFormConsent> authorizationFormCons;
    List<Authorizationformconsent> ListOfAuthorizationConsent = new List<Authorizationformconsent>();
    if (consentRecord.getSObjectType() == CampaignMember.sObjectType) {
      authorizationFormTexts = authorizationFormTextByAuthorizationFromId.get(
        authorizationFormId.get((Id) consentRecord.get('CampaignId'))
      );
    } else {
      authorizationId = (new List<Id>(AuthorizationFormIds)[0]);
      authorizationFormTexts = authorizationFormTextByAuthorizationFromId.get(authorizationId);
    }
    if (recentAuthorizatioFormConsents.size() > 0) {
      for (AuthorizationFormConsent authorizationForm : recentAuthorizatioFormConsents) {
        previousCampignMemberValues.put(
          authorizationform.AuthorizationFormText.Consent_Category__c,
          authorizationform.AuthorizationFormText.Consent_Category__c
        );
        checkTheAuthorizationFormText =
          authorizationform.AuthorizationFormText.Consent_Type__c +
          authorizationform.AuthorizationFormText.Opt_In_Out__c;

        if (consentRecord.get('Marketing_Opt_In__c') == 'Opt In') {
          if (authorizationform.AuthorizationFormText.Consent_Category__c == 'Marketing') {
            if (checkTheAuthorizationFormText != 'EmailOpt In') {
              deActivateConsentAuthorization = createAuthorizationBasedOnTheOptInOrOptOut(
                consentRecord,
                objectRecord,
                AuthorizationFormTexts,
                true,
                false,
                false
              );
              if (deActivateConsentAuthorization != null && !deActivateConsentAuthorization.isEmpty())
                deActivateConsentAuthorization[0] = compareAuthFormConsents(
                  deActivateConsentAuthorization[0],
                  authorizationForm,
                  objectRecord
                );

              ListOfAuthorizationConsent.addall(deActivateConsentAuthorization);
            }
          }
        } else if (consentRecord.get('Marketing_Opt_In__c') == 'Opt Out') {
          if (authorizationform.AuthorizationFormText.Consent_Category__c == 'Marketing') {
            if (checkTheAuthorizationFormText != 'EmailOpt Out') {
              deActivateConsentAuthorization = createAuthorizationBasedOnTheOptInOrOptOut(
                consentRecord,
                objectRecord,
                AuthorizationFormTexts,
                true,
                false,
                false
              );
              if (deActivateConsentAuthorization != null && !deActivateConsentAuthorization.isEmpty())
                deActivateConsentAuthorization[0] = compareAuthFormConsents(
                  deActivateConsentAuthorization[0],
                  authorizationForm,
                  objectRecord
                );

              ListOfAuthorizationConsent.addall(deActivateConsentAuthorization);
            }
          }
        }
        if (consentRecord.get('Recruiting_Opt_In__c') == 'Opt In') {
          if (authorizationform.AuthorizationFormText.Consent_Category__c == 'Recruiting') {
            if (AuthorizationForm.AuthorizationFormText.Consent_Type__c == 'Email') {
              if (authorizationForm.AuthorizationFormText.Opt_In_Out__c != 'Opt In') {
                deActivateConsentAuthorization = createAuthorizationBasedOnTheOptInOrOptOut(
                  consentRecord,
                  objectRecord,
                  AuthorizationFormTexts,
                  false,
                  false,
                  true
                );
                if (deActivateConsentAuthorization != null && !deActivateConsentAuthorization.isEmpty())
                  deActivateConsentAuthorization[0] = compareAuthFormConsents(
                    deActivateConsentAuthorization[0],
                    authorizationForm,
                    objectRecord
                  );

                ListOfAuthorizationConsent.addall(deActivateConsentAuthorization);
              }
            } else if (AuthorizationForm.AuthorizationFormText.Consent_Type__c == 'Phone') {
              if (authorizationForm.AuthorizationFormText.Opt_In_Out__c != 'Opt In') {
                deActivateConsentAuthorization = createAuthorizationBasedOnTheOptInOrOptOut(
                  consentRecord,
                  objectRecord,
                  AuthorizationFormTexts,
                  false,
                  true,
                  false
                );
                if (deActivateConsentAuthorization != null && !deActivateConsentAuthorization.isEmpty())
                  deActivateConsentAuthorization[0] = compareAuthFormConsents(
                    deActivateConsentAuthorization[0],
                    authorizationForm,
                    objectRecord
                  );

                ListOfAuthorizationConsent.addall(deActivateConsentAuthorization);
              }
            }
          }
        } else if (consentRecord.get('Recruiting_Opt_In__c') == 'Opt Out') {
          if (authorizationform.AuthorizationFormText.Consent_Category__c == 'Recruiting') {
            if (AuthorizationForm.AuthorizationFormText.Consent_Type__c == 'Email') {
              if (authorizationForm.AuthorizationFormText.Opt_In_Out__c != 'Opt Out') {
                deActivateConsentAuthorization = createAuthorizationBasedOnTheOptInOrOptOut(
                  consentRecord,
                  objectRecord,
                  AuthorizationFormTexts,
                  false,
                  false,
                  true
                );
                if (deActivateConsentAuthorization != null && !deActivateConsentAuthorization.isEmpty())
                  deActivateConsentAuthorization[0] = compareAuthFormConsents(
                    deActivateConsentAuthorization[0],
                    authorizationForm,
                    objectRecord
                  );

                ListOfAuthorizationConsent.addall(deActivateConsentAuthorization);
              }
            } else if (AuthorizationForm.AuthorizationFormText.Consent_Type__c == 'Phone') {
              if (authorizationForm.AuthorizationFormText.Opt_In_Out__c != 'Opt Out') {
                deActivateConsentAuthorization = createAuthorizationBasedOnTheOptInOrOptOut(
                  consentRecord,
                  objectRecord,
                  AuthorizationFormTexts,
                  false,
                  true,
                  false
                );
                if (deActivateConsentAuthorization != null && !deActivateConsentAuthorization.isEmpty())
                  deActivateConsentAuthorization[0] = compareAuthFormConsents(
                    deActivateConsentAuthorization[0],
                    authorizationForm,
                    objectRecord
                  );

                ListOfAuthorizationConsent.addall(deActivateConsentAuthorization);
              }
            }
          }
        }
      }
    }
    if (!previousCampignMemberValues.ContainsKey('Marketing') && consentRecord.get('Marketing_Opt_In__c') != null) {
      authorizationFormCons = createAuthorizationBasedOnTheOptInOrOptOut(
        consentRecord,
        objectRecord,
        AuthorizationFormTexts,
        true,
        false,
        false
      );
      ListOfAuthorizationConsent.addall(authorizationFormCons);
    } else if (
      !previousCampignMemberValues.ContainsKey('Recruiting') && consentRecord.get('Recruiting_Opt_In__c') != null
    ) {
      authorizationFormCons = createAuthorizationBasedOnTheOptInOrOptOut(
        consentRecord,
        objectRecord,
        AuthorizationFormTexts,
        false,
        true,
        true
      );
      ListOfAuthorizationConsent.addall(authorizationFormCons);
    }
    return ListOfAuthorizationConsent;
  }

  /**
   * @description Check the OptIn/Opt Out Values Of the campaign Mebember.
   * @param  campaign member and contact point phone and email related to individualand authorization form texts based on Campaign authorization form
   * @return list of the Authorization forms that needed to insert.
   **/
  private List<AuthorizationFormConsent> createAuthorizationBasedOnTheOptInOrOptOut(
    SObject consentRecord,
    SObject objectRecord,
    List<authorizationFormText> authorizationFormTexts,
    boolean isMarketing,
    boolean isRecruitingPhone,
    boolean isRecruitingEmail
  ) {
    String name;
    Id sObjectId = (id) objectRecord.get('Id');

    DateTime MemberRespondedDateTime;
    Id individual = (id) objectRecord.get('IndividualId');
    AuthorizationFormConsent consentForAuthorization;
    List<AuthorizationFormConsent> AuthorizationFormConsents = new List<AuthorizationFormConsent>();
    String checkTheAuthorizationFormText;
    if (consentRecord.getSObjectType() == CampaignMember.sObjectType) {
      name = campaignIdByName.get((Id) consentRecord.get('CampaignId'));

      MemberRespondedDateTime = (DateTime) consentRecord.get('Member_Responded_Datetime__c');
    } else {
      WDR_Application__c wdJobApp = jobAppplicationByContactId.get((Id) consentRecord.get('Id'));
      name = wdJobApp.Name;
      MemberRespondedDateTime = null;
    }

    if (authorizationFormTexts != null && authorizationFormTexts.size() > 0) {
      for (authorizationFormText authorizationform : authorizationFormTexts) {
        checkTheAuthorizationFormText =
          authorizationform.Consent_Category__c +
          authorizationform.Consent_Type__c +
          authorizationform.Opt_In_Out__c;
        if (
          consentRecord.get('Marketing_Opt_In__c') == 'Opt In' &&
          checkTheAuthorizationFormText == Marketing_EmailOptIn &&
          consentRecord.get('email') != null &&
          isMarketing
        ) {
          consentForAuthorization = InsertAuthorizationFormConsent(
            individual,
            (String) consentRecord.get('email'),
            authorizationform,
            name,
            MemberRespondedDateTime,
            sObjectId
          );
          AuthorizationFormConsents.add(consentForAuthorization);
        } else if (
          consentRecord.get('Marketing_Opt_In__c') == 'Opt Out' &&
          consentRecord.get('email') != null &&
          checkTheAuthorizationFormText == Marketing_EmailOptOut &&
          isMarketing
        ) {
          consentForAuthorization = InsertAuthorizationFormConsent(
            individual,
            (String) consentRecord.get('email'),
            authorizationform,
            name,
            MemberRespondedDateTime,
            sObjectId
          );
          AuthorizationFormConsents.add(consentForAuthorization);
        }
        if (
          consentRecord.get('Recruiting_Opt_In__c') == 'Opt In' &&
          consentRecord.get('email') != null &&
          checkTheAuthorizationFormText == Recruiting_EmailOptIn &&
          isRecruitingEmail
        ) {
          consentForAuthorization = InsertAuthorizationFormConsent(
            individual,
            (String) consentRecord.get('email'),
            authorizationform,
            name,
            MemberRespondedDateTime,
            sObjectId
          );
          AuthorizationFormConsents.add(consentForAuthorization);
        }
        if (
          consentRecord.get('Recruiting_Opt_In__c') == 'Opt In' &&
          consentRecord.get('phone') != null &&
          checkTheAuthorizationFormText == Recruiting_PhoneOptIn &&
          isRecruitingPhone
        ) {
          consentForAuthorization = InsertAuthorizationFormConsent(
            individual,
            (String) consentRecord.get('phone'),
            authorizationform,
            name,
            MemberRespondedDateTime,
            sObjectId
          );
          AuthorizationFormConsents.add(consentForAuthorization);
        } else {
          if (
            consentRecord.get('Recruiting_Opt_In__c') == 'Opt Out' &&
            consentRecord.get('email') != null &&
            checkTheAuthorizationFormText == Recruiting_EmailOptOut &&
            isRecruitingEmail
          ) {
            consentForAuthorization = InsertAuthorizationFormConsent(
              individual,
              (String) consentRecord.get('email'),
              authorizationform,
              name,
              MemberRespondedDateTime,
              sObjectId
            );
            AuthorizationFormConsents.add(consentForAuthorization);
          }
          if (
            consentRecord.get('Recruiting_Opt_In__c') == 'Opt Out' &&
            consentRecord.get('phone') != null &&
            checkTheAuthorizationFormText == Recruiting_PhoneOptOut &&
            isRecruitingPhone
          ) {
            consentForAuthorization = InsertAuthorizationFormConsent(
              individual,
              (String) consentRecord.get('phone'),
              authorizationform,
              name,
              MemberRespondedDateTime,
              sObjectId
            );
            AuthorizationFormConsents.add(consentForAuthorization);
          }
        }
      }
    }
    return AuthorizationFormConsents;
  }

  /**
   * @description Intialising the Authorization form consent records and insert values based on opt in an opt out
   * @param we are passsing the invidiaul id,lead source ,email or phone and authorizaion form text id
   * @return  Authorization forms that needed to insert.
   **/
  private AuthorizationFormConsent InsertAuthorizationFormConsent(
    id individual,
    String EmailOrphone,
    AuthorizationFormText authorizationFormText,
    string name,
    DateTime MemberRespondedDateTime,
    Id sObjectId
  ) {
    AuthorizationFormConsent authconsent = new AuthorizationFormConsent();
    Boolean IsCEMCIUser = FeatureManagement.checkPermission('CEMCI_Consent_Creation');
    if (!IsCEMCIUser) {
      PF_Logger.log(
        'CEMCI',
        'ERROR',
        'User does not have sufficient access to create consents',
        ' ',
        'Error during creating consents' + UserInfo.getUserId(),
        'Consents'
      );
    } else {
      authconsent.AuthorizationFormTextId = authorizationFormText.Id;
      authconsent.ConsentGiverId = individual;
      authconsent.ConsentCapturedSource = name;
      authconsent.ConsentCapturedDateTime = System.now();
      authconsent.ConsentCapturedSourceType = 'Web';
      authconsent.Status = 'signed';
      authconsent.name = EmailOrphone;
      authconsent.IsActive__c = true;
      authconsent.Member_Responded_Datetime__c = MemberRespondedDateTime;
    }
    if (!PF_Logger.logs.isEmpty()) {
      PF_Logger.createLogs(PF_Logger.logs);
    }

    mapOfIdMarkRecOptValue.put(
      sObjectId +
      '_' +
      authorizationFormText.Consent_Category__c,
      authorizationFormText.Opt_In_Out__c
    );

    return authconsent;
  }

  private void insertAuthorizationFormConsentRecords() {
    if (authorizationFormConsents != null && !authorizationFormConsents.isEmpty()) {
      Database.SaveResult[] srList = Database.insert(authorizationFormConsents, false);

      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for (Database.Error objErr : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              objErr.getMessage(),
              String.valueof(objErr.getStatusCode()),
              ' Error during source specific Authorization Form consent Insert ' +
              sr.getId() +
              ' UserId ' +
              UserInfo.getUserId(),
              'Consents'
            );
          }
        }
      }
      if (!PF_Logger.logs.isEmpty()) {
        PF_Logger.createLogs(PF_Logger.logs);
      }
    }
  }
  private void updateAuthorizationFormConsentRecords() {
    if (updateAuthorizationsOfPreviousCampaign != null && !updateAuthorizationsOfPreviousCampaign.isEmpty()) {
      Database.SaveResult[] srList = Database.update(updateAuthorizationsOfPreviousCampaign, false);

      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for (Database.Error objErr : sr.getErrors()) {
            PF_Logger.log(
              'CEMCI',
              'ERROR',
              objErr.getMessage(),
              String.valueof(objErr.getStatusCode()),
              ' Error during source specific Authorization Form consent Insert ' +
              sr.getId() +
              ' UserId ' +
              UserInfo.getUserId(),
              'Consents'
            );
          }
        }
      }
      if (!PF_Logger.logs.isEmpty()) {
        PF_Logger.createLogs(PF_Logger.logs);
      }
    }
  }

  private AuthorizationFormConsent compareAuthFormConsents(
    AuthorizationFormConsent newAuthFormConsent,
    AuthorizationFormConsent oldAuthFormConsent,
    SObject objectRecord
  ) {
    if (oldAuthFormConsent.Member_Responded_Datetime__c > newAuthFormConsent.Member_Responded_Datetime__c) {
      newAuthFormConsent.IsActive__c = false;

      mapOfIdMarkRecOptValue.put(
        (id) objectRecord.Id +
        '_' +
        oldAuthFormConsent.AuthorizationFormText.Consent_Category__c,
        oldAuthFormConsent.AuthorizationFormText.Opt_In_Out__c
      );
    } else {
      updateAuthorizationsOfPreviousCampaign.add(
        new AuthorizationFormConsent(Id = oldAuthFormConsent.Id, IsActive__c = false)
      );
    }
    return newAuthFormConsent;
  }

  private void updateLeadContact() {
    for (String idMKRC : mapOfIdMarkRecOptValue.keySet()) {
      Id objectId = (Id) idMKRC.substringBefore('_');
      String markRec = idMKRC.substringAfter('_');

      if (contactById.containsKey(objectId)) {
        if (markRec == 'Marketing')
          contactById.get(objectId).Marketing_Opt_In__c = mapOfIdMarkRecOptValue.get(idMKRC);
        else
          contactById.get(objectId).Recruiting_Opt_In__c = mapOfIdMarkRecOptValue.get(idMKRC);
      }
      if (leadById.containsKey(objectId)) {
        if (markRec == 'Marketing')
          leadById.get(objectId).Marketing_Opt_In__c = mapOfIdMarkRecOptValue.get(idMKRC);
        else
          leadById.get(objectId).Recruiting_Opt_In__c = mapOfIdMarkRecOptValue.get(idMKRC);
      }
    }

    System.enqueueJob(new CEMCI_LeadContactUpdateQueueable(contactById.values(), leadById.values()));
  }
}