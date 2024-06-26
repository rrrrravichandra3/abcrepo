public class PF_ReportRequestFormManager extends PF_FormManager {
    
    protected override Map<String,Object> getFormSpecificInformation(Map<String,Object> parameters){
        return null;
    }

    protected override List<String> getUserFields(){
        return null;
    }
    
    public override Id createCase(Map<String, Object> caseInformation, String attachmentsStoreId){
        
        Case c = (Case)JSON.deserialize(JSON.serialize(caseInformation), Case.class);
        
        User u = getCurrentUser();
        c.Type = 'ES Data Request';
        c.Origin = 'Employee Success - Web';
        c.Tier__c = 'Tier 1';
        c.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
        c.RecordTypeId = getRecordTypeId(DJC_Division.getDivisionByName(u.contact.Division__c));
        
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