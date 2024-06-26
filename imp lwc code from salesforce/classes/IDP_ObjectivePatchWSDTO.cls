public class IDP_ObjectivePatchWSDTO {
    @AuraEnabled public String errorMessage;
    @AuraEnabled public String idpRecordId;
    @AuraEnabled public String recordId;
    @AuraEnabled public String objectiveName;
    @AuraEnabled public List<Actions> actions;

    public class Actions {
        @AuraEnabled public String Status;
        @AuraEnabled public String recordId;
        @AuraEnabled public String completionDate;
        @AuraEnabled public String Action;
        @AuraEnabled public String Comments;
    }

    
    public static IDP_ObjectivePatchWSDTO parse(String json) {
        return (IDP_ObjectivePatchWSDTO) System.JSON.deserialize(json, IDP_ObjectivePatchWSDTO.class);
    }

    public static List<Actions> parseActions(String json) {
        return (List<Actions>) System.JSON.deserialize(json, List<Actions>.class);
    }
}