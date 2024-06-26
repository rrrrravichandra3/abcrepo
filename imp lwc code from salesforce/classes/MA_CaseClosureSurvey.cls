/**
 * W-11122415
 * This class is used to create Survey Invitations for closed M&A cases and add the link on Case record itself, to be used in Case closure 
 * email template.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/05/2022      Priyanka Kanani         Handle Case Closure survey creation and contact update
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class MA_CaseClosureSurvey {

    private static final String SURVEY_INVITATION_LINK = Label.MA_Survey_Invitation_Link;
    private static final String CASE_CLOSURE_SURVEY_NAME = Label.MA_CaseClose_Survey_Name;
    public static Survey testData = new Survey();

    private static Survey caseCloseSurvey{get {
        if(caseCloseSurvey == null) {
            caseCloseSurvey = [SELECT Id, Name FROM Survey WHERE Name = :CASE_CLOSURE_SURVEY_NAME LIMIT 1];
        }
        return caseCloseSurvey;
    } set;}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create SurveyInvitation & SurveySubject record for a given Case & update SurveyLink on Case record itself.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    caseIdToContactIdMap            DESCRIPTION (Data type Map, Map of Case Id to Contact Id)
    * @param    contactIdToCommunityURLMap      DESCRIPTION (Data type Map, Map of ContactId to M&A Community URL as on Contact record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void createCaseClosureSurvey(Map<Id, Id> caseIdToContactIdMap, Map<Id, String> contactIdToCommunityURLMap) {
        Map<Id, Id> contactIdToCommunityIdMap = getContactIdToCommunityIdMap(contactIdToCommunityURLMap);
        List<SurveyInvitation> surveyInvitations = getSurveyInvitations(caseIdToContactIdMap, contactIdToCommunityIdMap);

        Map<Id, SurveyInvitation> caseIdToSurveyInvMap = new Map<Id, SurveyInvitation>();
        createSurveySubjects(surveyInvitations, caseIdToContactIdMap, caseIdToSurveyInvMap);
        updateCaseRecordsWithSurveyLinks(caseIdToContactIdMap, caseIdToSurveyInvMap, contactIdToCommunityURLMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Map of Contact Id to Community Id based on M&A Community URL on contact record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactIdToCommunityURLMap      DESCRIPTION (Data type Map, Map of ContactId to M&A Community URL as on Contact record)
    * @return   Map                             DESCRIPTION (return Map of Contact Id to Community Id.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, Id> getContactIdToCommunityIdMap(Map<Id, String> contactIdToCommunityURLMap) {
        Map<Id, String> contactIdToPathURLPrefixMap = getContactIdToPathURLPrefixMap(contactIdToCommunityURLMap);
        Map<String, Id> pathPrefixToNetworkIdMap = getPathPrefixToNetworkIdMap(new Set<String>(contactIdToPathURLPrefixMap.values()));
        Map<Id, Id> contactIdToCommunityIdMap = new Map<Id, Id>();

        for(Id contactId : contactIdToPathURLPrefixMap.keySet()) {
            contactIdToCommunityIdMap.put(contactId, pathPrefixToNetworkIdMap.get(contactIdToPathURLPrefixMap.get(contactId)));
        }

        return contactIdToCommunityIdMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Map of Contact Id to Community Path URL Prefix using M&A Community URL on Contact record.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactIdToCommunityURLMap      DESCRIPTION (Data type Map, Map of ContactId to Community URL as on Contact record)
    * @return   Map                             DESCRIPTION (return Map of Contact Id to Community Path URL Prefix.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, String> getContactIdToPathURLPrefixMap(Map<Id, String> contactIdToCommunityURLMap) {
        Map<Id, String> contactIdToPathURLPrefixMap = new Map<Id, String>();
        for(Id contactId : contactIdToCommunityURLMap.keySet()) {
            contactIdToPathURLPrefixMap.put(contactId, contactIdToCommunityURLMap.get(contactId).substringBeforeLast('/').substringAfterLast('/'));
        }
        return contactIdToPathURLPrefixMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Map of Community Path URL Prefix to Community Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pathPrefixSet       DESCRIPTION (Data type Set, Set of Community Path URL Prefixes)
    * @return   Map                 DESCRIPTION (return Map of Community Path URL Prefix to Community Id.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Id> getPathPrefixToNetworkIdMap(Set<String> pathPrefixSet) {
        Map<String, Id> pathPrefixToNetworkIdMap = new Map<String, Id>();

        for(Network network : [SELECT Id, UrlPathPrefix FROM Network WHERE UrlPathPrefix IN :pathPrefixSet]) {
            pathPrefixToNetworkIdMap.put(network.UrlPathPrefix, network.Id);
        }
    
        return pathPrefixToNetworkIdMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return list SurveyInvitation records for each Closed Case.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    caseIdToContactIdMap        DESCRIPTION (Data type Map, Map of Case Id to Contact Id)
    * @param    contactIdToCommunityIdMap   DESCRIPTION (Data type Map, Map of Contact Id to Community Id)
    * @return   List                        DESCRIPTION (return List SurveyInvitation records.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<SurveyInvitation> getSurveyInvitations(Map<Id, Id> caseIdToContactIdMap, Map<Id, Id> contactIdToCommunityIdMap) {
        List<SurveyInvitation> surveyInvitations = new List<SurveyInvitation>();

        for(Id caseId : caseIdToContactIdMap.keySet()) {
            Id contactId = caseIdToContactIdMap.get(caseId);
            Id communityId = contactIdToCommunityIdMap.get(contactId);
            SurveyInvitation surveyInvitation = getSurveyInvitation(caseId, contactId, communityId);  
            surveyInvitations.add(surveyInvitation);
        }
            
        Database.SaveResult[] srList = Database.insert(surveyInvitations, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);

        return getSurveyInvitations(surveyInvitations);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize SurveyInvitation record for each Closed Case.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    caseId                  DESCRIPTION (Data type Id, Id of Closed Case record)
    * @param    contactId               DESCRIPTION (Data type Id, Id of Contact related on Case record)
    * @param    communityId             DESCRIPTION (Data type Id, Id of Community Id based on M&A Community URL on Contact record)
    * @return   SurveyInvitation        DESCRIPTION (return SurveyInvitation record.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static SurveyInvitation getSurveyInvitation(Id caseId, Id contactId, Id communityId) {
        SurveyInvitation surveyInvitation = new SurveyInvitation();
        surveyInvitation.CommunityId = communityId;
        surveyInvitation.ParticipantId =  contactId;
        surveyInvitation.SurveyId = caseCloseSurvey.Id;
        surveyInvitation.Name = caseCloseSurvey.Name + '-' + caseId;
        return surveyInvitation;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to query and return List of SurveyInvitation records to access UUID for newly created survey invitations.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    surveyInvitations       DESCRIPTION (Data type List, List of newly inserted SurveyInvitation records)
    * @return   List                    DESCRIPTION (return List of SurveyInvitation records to access UUID.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<SurveyInvitation> getSurveyInvitations(List<SurveyInvitation> surveyInvitations) {
        system.debug('***getSurveyInvitationIds(surveyInvitations) '+getSurveyInvitationIds(surveyInvitations));
        return [SELECT Id, Name, UUID, ParticipantId 
                FROM SurveyInvitation 
                WHERE Id IN : getSurveyInvitationIds(surveyInvitations)];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get Set of Ids for newly inserted SurveyInvitation records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    surveyInvitations       DESCRIPTION (Data type List, List of newly inserted SurveyInvitation records)
    * @return   Set                     DESCRIPTION (return Set of Ids for newly inserted SurveyInvitation record.)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<Id> getSurveyInvitationIds(List<SurveyInvitation> surveyInvitations) {
        Set<Id> surveyInvitationIds = new Set<Id>();
        for(SurveyInvitation surveyInvitation : surveyInvitations) {
            surveyInvitationIds.add(surveyInvitation.Id);
            system.debug('surveyInvitationIds** '+surveyInvitationIds);
        }
        return surveyInvitationIds;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to insert SurveySubject records, one for each newly inserted SurveyInvitation record.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    surveyInvitations           DESCRIPTION (Data type List, List of newly inserted SurveyInvitation records)
    * @param    caseIdToContactIdMap        DESCRIPTION (Data type Map, Map of Case Id to related Contact record Id)
    * @param    caseIdToSurveyInvMap        DESCRIPTION (Data type Map, Map of Case Id to SurveyInvitation record)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void createSurveySubjects(List<SurveyInvitation> surveyInvitations, Map<Id, Id> caseIdToContactIdMap, Map<Id, SurveyInvitation> caseIdToSurveyInvMap) {
        List<SurveySubject> surveySubjects = new List<SurveySubject>();

        for(SurveyInvitation surveyInvitation : surveyInvitations) {
            Id caseId = Id.valueOf(surveyInvitation.Name.substringAfter('-'));                
            surveySubjects.add(getSurveySubject(caseId, surveyInvitation.Id, surveyInvitation.Name));
            caseIdToSurveyInvMap.put(caseId, surveyInvitation);
        }
            
        Database.SaveResult[] srList = Database.insert(surveySubjects, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize SurveySubject record for each Closed Case using Case Id, SurveyInvitation Id & SurveyInvitation Name.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    caseId                      DESCRIPTION (Data type Id, Id of Closed Case record)
    * @param    surveyInvitationId          DESCRIPTION (Data type Id, Id of SurveyInvitation record created for Closed Case)
    * @param    surveyInvitationName        DESCRIPTION (Data type String, Name of SurveyInvitation record created for Closed Case)
    * @return   SurveySubject               DESCRIPTION (return SurveySubject record.)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @testVisible
    private static SurveySubject getSurveySubject(Id caseId, Id surveyInvitationId, String surveyInvitationName) {
        SurveySubject surveySubjectRec = new SurveySubject();
        surveySubjectRec.SubjectId = caseId;
        surveySubjectRec.Name = surveyInvitationName;
        surveySubjectRec.ParentId = surveyInvitationId;
        return surveySubjectRec;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Closed Case records with the Survey Invitation Link.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    caseIdToContactIdMap            DESCRIPTION (Data type Map, Map of Case Id to related Contact record Id)
    * @param    caseIdToSurveyInvMap            DESCRIPTION (Data type Map, Map of Case Id to SurveyInvitation record)
    * @param    contactIdToCommunityURLMap      DESCRIPTION (Data type Map, Map of ContactId to M&A Community URL as on Contact record)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateCaseRecordsWithSurveyLinks(Map<Id, Id> caseIdToContactIdMap, Map<Id, SurveyInvitation> caseIdToSurveyInvMap, Map<Id, String> contactIdToCommunityURLMap) {
        List<Case> maCases = new List<Case>();

        for(Id caseId : caseIdToContactIdMap.keySet()) {
            Id contactId = caseIdToContactIdMap.get(caseId);
            String communityURL = contactIdToCommunityURLMap.get(contactId);
            SurveyInvitation surveyInvitation = caseIdToSurveyInvMap.get(caseId);
            maCases.add(getCaseWithSurveyLink(caseId, communityURL, surveyInvitation));
        }

        Database.SaveResult[] srList = Database.update(maCases, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(srList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initialize & return Case record to be updated with the Survey Invitation Link.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    caseId                  DESCRIPTION (Data type Id, Id of Closed Case record)
    * @param    communityURL            DESCRIPTION (Data type String, M&A Community URL as on Case Contact record)
    * @param    surveyInvitation        DESCRIPTION (Data type SurveyInvitation, SurveyInvitation record created for the Closed Case)
    * @return   Case                    DESCRIPTION (return Case record with updated Survey Invitation Link.)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Case getCaseWithSurveyLink(Id caseId, String communityURL, SurveyInvitation surveyInvitation) {
        Case maCase = new Case(Id = caseId);
        String[] linkParams = new String[] {communityURL, surveyInvitation.Id, CASE_CLOSURE_SURVEY_NAME, surveyInvitation.UUID};
        maCase.MA_Survey_Invitation_Link__c = String.format(SURVEY_INVITATION_LINK, linkParams);
        return maCase;
    }
}