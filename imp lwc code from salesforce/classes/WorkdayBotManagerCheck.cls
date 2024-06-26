public with sharing class WorkdayBotManagerCheck {
    
    public class Input {
        @InvocableVariable(required=false)
        public String contactId;
    }
    
    public class Output {
        @InvocableVariable(required=true)
        public Boolean isManager;
    }
    
    @InvocableMethod(label='Check if User is a Manager')
    public static List<Output> managerCheck(List<Input> transcripts) {
        List<Output> result = new List<Output>();
        
        for (Input transcript : transcripts) {
            if (transcript.contactId == null || transcript.contactId == '') {
                result.add(generateOutput(false));
                break;
            }
            
            Contact contact = [SELECT Id, Email, ES_DJC_Is_Manager__c FROM Contact WHERE Id = :transcript.contactId LIMIT 1];
            
            if (contact == null) {
                result.add(generateOutput(false));
                break;
            }
            
            result.add(generateOutput(contact.ES_DJC_Is_Manager__c));
        }
        
        return result;
    }
    
    private static Output generateOutput(Boolean isManager) {
        Output outputData = new Output();
        outputData.isManager = isManager;
        
        return outputData;
    }
}