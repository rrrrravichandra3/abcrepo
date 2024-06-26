public class IA_ContactRecordTypeImpl implements IA_ContactRecordTypeInterface {
	@testvisible static List<String> errorMessages;
    Public Static Id getContactIdBasedRecordType(String UserEmail,String Usertype){
		Id contactId;        
        errorMessages = new List<string>();
        try{
			String contactRecordTypeName = IA_Util.InsiderConfigDefaultRec.Candidate_Contact_Rec_Typ_Developer_Name__c;
        	Id ContactrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecordTypeName).getRecordTypeId();
        	if(Usertype == 'Standard'){
            	Contact contactRec =[select id from contact where email= :UserEmail AND RecordTypeId= :ContactrecordTypeId limit 1];
            	contactId =contactRec.id;
        	}
        }
        Catch(Exception exp){
            errorMessages.add(IA_Util.buildErrorMessage(UserInfo.getUserEmail(),userInfo.getUserId(),'Internal Candidate Contact Not have WDR Candidate Recordtype',exp.getMessage(),exp.getStackTraceString()));
        }
		finally{
            IA_Util.notifyErrors(errorMessages);
        }
        return contactId;
    }
}