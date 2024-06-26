public class IDP_WSControllerDTO {

	@AuraEnabled public cls_objectives[] objectives;
	@AuraEnabled public String recordId;
	@AuraEnabled public String managerName;
	@AuraEnabled public String keyStrengths;
	@AuraEnabled public String careerInterest;
	@AuraEnabled public Datetime lastModifiedDate;
	@AuraEnabled public String errorMessage;
	@AuraEnabled public String sfdcBaseURL;
	class cls_objectives {
		@AuraEnabled public String recordId;
		@AuraEnabled public String objectiveName;	
		@AuraEnabled public cls_actions[] actions;
	}
	class cls_actions {
		@AuraEnabled public String recordId;
		@AuraEnabled public String Status;	
		@AuraEnabled public String completionDate;	
		@AuraEnabled public String Action;	
		@AuraEnabled public String Comments;	
	}
	
	@AuraEnabled public static IDP_WSControllerDTO parse(String json){
		return (IDP_WSControllerDTO) System.JSON.deserialize(json, IDP_WSControllerDTO.class);
	}
}