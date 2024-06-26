@IsTest
private class PF_CaseUIComponentController_Test {

    @IsTest
    static void negativeTest_getInitData_withEmptyRecordId() {
        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(null, null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_ERROR, result.status);
        System.assertEquals(PF_CaseUIComponentController.EMPTY_RECORD_ID_MESSAGE, result.message);
    }

    @IsTest
    static void negativeTest_getInitData_withNotSupportedRecordType() {
        Case unsupportedCase = new Case();
        unsupportedCase.Subject = 'Test Case 1';
        String unsupportedRecordId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Case'
                    AND  DeveloperName NOT IN :PF_CaseUIComponentController.SUPPORTED_CASE_RECORD_TYPES
                LIMIT 1
        ].Id;

        if (String.isNotBlank(unsupportedRecordId)) unsupportedCase.RecordTypeId = unsupportedRecordId;

        unsupportedCase.ContactId = ESDJC_TestUtil.getContact().Id;
        insert unsupportedCase;

        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(unsupportedCase.Id,null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_ERROR, result.status);
        System.assertEquals(PF_CaseUIComponentController.COMPONENT_RESTRICTION_MESSAGE, result.message);
    }

    @IsTest
    static void negativeTest_getInitData_warmline_emptyContactId() {
        Case wCase = ESDJC_TestUtil.getWarmlineCase();
        wCase.ContactId = null;
        update wCase;

        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(wCase.Id,null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_ERROR, result.status);
        System.assertEquals(PF_CaseUIComponentController.CONTACT_ID_IS_MISSING, result.message);
    }

    @IsTest
    static void negativeTest_getInitData_GERC_emptyInReferenceTo() {
        Case gerc = new Case();
        String gercRecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Case'
                AND  DeveloperName = :PF_CaseUIComponentController.CASE_RECORD_TYPE_GENERAL_ER_CASE
                LIMIT 1
        ].Id;

        gerc.Subject = 'Test Case';
        gerc.RecordTypeId = gercRecordTypeId;
        gerc.ContactId = ESDJC_TestUtil.getContact().Id;

        insert gerc;

        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(gerc.Id,null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_ERROR, result.status);
        System.assertEquals(PF_CaseUIComponentController.IN_REFERENCE_TO_IS_MISSING, result.message);
    }

    @IsTest
    static void negativeTest_getInitData_ERI_noAllegations() {
        Case eriCase = ESDJC_TestUtil.getERInvestigationCase();

        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(eriCase.Id,null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_ERROR, result.status);
        System.assertEquals(PF_CaseUIComponentController.ALLEGATIONS_IS_MISSING, result.message);
    }
    @IsTest
    static void positiveTest_getInitData_warmline() {
        Case context = ESDJC_TestUtil.getWarmlineCase();
        List<Case> relatedCases = new List<Case> {
            ESDJC_TestUtil.getERInvestigationCase(),
            ESDJC_TestUtil.getERInvestigationCase()
        };
        for (Case rCase: relatedCases) {
            rCase.ContactId = context.ContactId;
        }

        update relatedCases;

        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(context.Id,null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_SUCCESS, result.status);
        System.assertEquals(6, result.tableColumns.size());
        System.assertEquals(2, result.records.size());
    }
    
    @IsTest
    static void positiveTest_getInitData_ERInvestigation() {
        Case context = ESDJC_TestUtil.getERInvestigationCase();
        String accusedContactId = ESDJC_TestUtil.getContact().Id;

        Allegations__c anAllegation = new Allegations__c();
        anAllegation.RecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Allegations__c'
                    AND DeveloperName = 'ER_Allegations'
                LIMIT 1
        ].Id;
        anAllegation.Accused_Type__c = 'Employee';
        anAllegation.Issue_Type__c = 'Attendance';
        anAllegation.Case__c = context.Id;
        anAllegation.Accused__c = accusedContactId;
        insert anAllegation;

        Case gerc = new Case();
        String gercRecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Case'
                AND  DeveloperName = :PF_CaseUIComponentController.CASE_RECORD_TYPE_GENERAL_ER_CASE
                LIMIT 1
        ].Id;

        gerc.Subject = 'Test Related Case';
        gerc.RecordTypeId = gercRecordTypeId;
        gerc.ContactId = accusedContactId;

        insert gerc;

        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(context.Id,null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_SUCCESS, result.status);
        System.assertEquals(6, result.tableColumns.size());
        System.assertEquals(1, result.records.size());
    }

    @IsTest
    static void positiveTest_getInitData_GlobalERCase() {
        Case context = new Case();

        context.Subject = 'Test Context Case';
        context.RecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Case'
                AND  DeveloperName = :PF_CaseUIComponentController.CASE_RECORD_TYPE_GENERAL_ER_CASE
                LIMIT 1
        ].Id;
        context.ContactId = ESDJC_TestUtil.getContact().Id;
        context.In_Reference_To__c = ESDJC_TestUtil.getContact().Id;

        insert context;

        Case erRelatedCase = ESDJC_TestUtil.getERInvestigationCase();
        erRelatedCase.ContactId = context.In_Reference_To__c;

        update erRelatedCase;

        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(context.Id,null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_SUCCESS, result.status);
        System.assertEquals(6, result.tableColumns.size());
        System.assertEquals(1, result.records.size());
    }
     @IsTest
    static void positiveTest_getERRelatedCases() {
        Case context = ESDJC_TestUtil.getERInvestigationCase();
        String accusedContactId = ESDJC_TestUtil.getContact().Id;
        Allegations__c anAllegation = new Allegations__c();
        anAllegation.RecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Allegations__c'
                    AND DeveloperName = 'ER_Allegations'
                LIMIT 1
        ].Id;
        anAllegation.Accused_Type__c = 'Employee';
        anAllegation.Issue_Type__c = 'Attendance';
        anAllegation.Case__c = context.Id;
        anAllegation.Accused__c = accusedContactId;
        insert anAllegation;
        List<Case> relatedCases = new List<Case> {
            ESDJC_TestUtil.getERInvestigationCase(),
            ESDJC_TestUtil.getERInvestigationCase()
        };
        for (Case rCase: relatedCases) {
            rCase.ContactId = context.ContactId;
        }

        update relatedCases;

        PF_CaseUIComponentController.ResultData result = PF_CaseUIComponentController.getInitData(context.Id,null);
        System.assertEquals(PF_CaseUIComponentController.STATUS_SUCCESS, result.status);
        System.assertEquals(6, result.tableColumns.size());
        System.assertEquals(2, result.records.size());
    }

}