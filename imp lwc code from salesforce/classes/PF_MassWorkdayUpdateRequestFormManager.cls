public class PF_MassWorkdayUpdateRequestFormManager extends PF_FormManager {
    
    protected override Map<String,Object> getFormSpecificInformation(Map<String,Object> parameters){
        Map<String,Object> specificInformation = new Map<String,Object>();
        Boolean switchCaseTypeToHRIS = ESDJC_Settings__c.getInstance().Mass_Workday_Case_Type_HRIS__c;
        specificInformation.put('CASETYPEHRIS',switchCaseTypeToHRIS);
        return specificInformation;
    }
    
    protected override List<String> getUserFields(){
        return null;
    }
    
    public override Id createCase(Map<String, Object> caseInformation, String attachmentsStoreId){
        Boolean switchCaseTypeToHRIS = ESDJC_Settings__c.getInstance().Mass_Workday_Case_Type_HRIS__c;
        Case c = (Case)JSON.deserialize(JSON.serialize(caseInformation), Case.class);
        c.Type = 'EED';
        c.ES_DJC_Topic__c = 'Mass Workday Updates (Loads)';
        c.Origin = 'Employee Success - Web';
        c.Status = 'New';
        c.Priority = 'Medium';
        c.Subject = 'Mass Workday Update Request for ' + currentUser.Contact.Name;
        c.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
        c.RecordTypeId = getRecordTypeId(DJC_Division.getDivisionByName(currentUser.contact.Division__c));
        caseInformation.remove('sobjectType');
        INSERT c;
        
        moveAttachmentsToCase(c.Id, attachmentsStoreId);
        
        return c.Id;
    }
    
    private Id getRecordTypeId(DJC_Division division){
        
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Case.getRecordTypeInfosByName();
        Id recordType = null;
        
        if (division == DJC_Division.AMERCANADA || division == DJC_Division.AMERUSA || division == DJC_Division.LACA){
            recordType = recordTypes.get('All Case Types except ER - AMER').getRecordTypeId();
        }else if (division == DJC_Division.APAC){
            recordType = recordTypes.get('All Case Types except ER - APAC').getRecordTypeId();
        }else if (division == DJC_Division.EMEA){
            recordType = recordTypes.get('All Case Types except ER - EMEA').getRecordTypeId();
        }else if (division == DJC_Division.JAPAN){
            recordType = recordTypes.get('All Case Types except ER - Japan').getRecordTypeId();
        }
        
        return recordType;
    }
}