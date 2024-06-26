public with sharing class IA_InsidersInvitationBatch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Schedulable {
    List<IA_InsidersInvitationBatchHandler.EmailWrapper> emails = new List<IA_InsidersInvitationBatchHandler.EmailWrapper>();
    public List<IA_InsidersInvitationBatchHelper.ConfigWrapper> groups;
    List<IA_Invitation_JobApplication__c> jobAppCustomSettings;
    List<EmailTemplate> templates = null;
    public String jobAppQuery = '';
    public String trackingQuery = '';

    public IA_InsidersInvitationBatch() {
        String groupQuery = IA_InsidersInvitationBatchHelper.retrieveGroupQuery();
        String personaQuery = IA_InsidersInvitationBatchHelper.retrievePersonaQuery();
        this.jobAppQuery = IA_InsidersInvitationBatchHelper.retrieveJobAppQuery();
        this.trackingQuery = IA_InsidersInvitationBatchHelper.retrieveTrackingIVTQuery();
        List<IA_Invitation_Criteria_Group__mdt> groupsSrc = Database.query(groupQuery);
        List<IA_Invitation_Criteria_Persona__mdt> personasSrc = Database.query(personaQuery);
        List<IA_Invitation_Config__mdt> criteria = IA_InsidersInvitationBatchHelper.fieldsCriteriaConfig();
        List<IA_InsidersInvitationBatchHelper.ConfigWrapper> groups = IA_InsidersInvitationBatchHelper.compose(groupsSrc, criteria);
        List<IA_InsidersInvitationBatchHelper.ConfigWrapper> personas = IA_InsidersInvitationBatchHelper.compose(personasSrc, criteria);
        // ------------------------------------------------------------------------
        String templatesInput = IA_InsidersInvitationBatchHelper.extractTemplates(personas);
        String templateQuery = 'SELECT Id, Name, DeveloperName, FolderName FROM EmailTemplate WHERE DeveloperName IN ' + templatesInput;
        this.templates = Database.query(templateQuery);
        // System.debug('QUERY: ' + templateQuery);
        // ------------------------------------------------------------------------
        this.groups = IA_InsidersInvitationBatchHelper.groupPersonas(groups, personas);
        this.jobAppCustomSettings = [SELECT Id, Name FROM IA_Invitation_JobApplication__c WITH SECURITY_ENFORCED LIMIT 1000];
        // ------------------------------------------------------------------------
        String ids = IA_InsidersInvitationBatchHelper.composeJobAppScopeToRetrieve(this.jobAppCustomSettings);
        String scope = ' WHERE Id IN ' + ids + ' WITH SECURITY_ENFORCED';
        this.jobAppQuery = this.jobAppQuery + scope;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.jobAppQuery);
    }

    public void execute(Database.BatchableContext bc, List<WDR_Application__c> scope) {
        if (!scope.isEmpty()) {
            IA_InsidersInvitationBatchHandler.HandleScopeWrapper entry = IA_InsidersInvitationBatchHandler.handleScope(scope, this.groups, this.templates);
            IA_InsidersInvitationBatchHandler.MassEmailWrapper result = IA_InsidersInvitationBatchHandler.massEmail(entry.emailsToBeSent);
            if(result.listSentResult.size()>0){
                IA_InsidersInvitationBatchHandler.updateTrackings(result.listSentResult, this.trackingQuery, scope);
            }
            IA_InsidersInvitationBatchHandler.cleanUpSettings(entry.defaultsToDelete, this.jobAppCustomSettings);
            IA_InsidersInvitationBatchHandler.cleanUpSettings(result.mapSentResult, this.jobAppCustomSettings);
        }
    }

    public void finish(Database.BatchableContext bc) {
        // ...
    }

    public void execute(SchedulableContext scope) {
        IA_InsidersInvitationBatch btch = new IA_InsidersInvitationBatch();
        Database.executebatch(btch, 2);
    }
}

// ========================================================================================
// InsidersInvitationBatch myBatch = new InsidersInvitationBatch();
// String mySchedule = '0 30 * * * ?';
// String jobID = System.schedule('InvintationEmailBatch', mySchedule, myBatch);
// ========================================================================================
// IA_InsidersInvitationBatch btch = new IA_InsidersInvitationBatch();
// Database.executebatch(btch, 9);
// ========================================================================================