public with sharing class OmniChannelUtilityController {

	public static Integer omnichannel_duration;
	public static String omnichannel_mode;
	public static String omnichannel_type;
	
	private static void toastParams(){
		
		Live_Agent_Settings__c OmniChannelValue = Live_Agent_Settings__c.getValues('Omni Channel');

		try{

			if(OmniChannelValue == NULL){
				throw new ApplicationException('Blank Custom Setting');
			}	
			else{

				omnichannel_duration = Integer.Valueof(OmniChannelValue.Duration__c);
				
				if(omnichannel_duration == NULL){
						throw new ApplicationException('Duration not specified');
				}
							
				omnichannel_mode = OmniChannelValue.Mode__c;

				if(omnichannel_mode == NULL){
					throw new ApplicationException('Mode not specified');
				}

				if(omnichannel_mode != 'pester' && omnichannel_mode != 'sticky' && omnichannel_mode != 'dismissible'){
					throw new ApplicationException('Wrong mode specified');
				}
			
				omnichannel_type = OmniChannelValue.Type__c;

				if(omnichannel_type == NULL){
					throw new ApplicationException('Type not specified');
				}

				if(omnichannel_type != 'error' && omnichannel_type != 'warning' && omnichannel_type != 'success' && omnichannel_type != 'info'){
					throw new ApplicationException('Wrong type specified');
				}
			}	
		}
		catch(Exception e){

			omnichannel_duration = 30000;
			omnichannel_mode = 'dismissible';
			omnichannel_type = 'success';
		}	
	}

	@AuraEnabled	
	public static LiveChatToastWrapper getLiveChatToastParams(){

		String LiveAgentTitle;
		String LiveAgentMessage;
	
		try{
			
			toastParams();

			LiveAgentTitle = System.Label.Live_Agent_Title;

			if(LiveAgentTitle == NULL){
				throw new ApplicationException('Title not specified');
			}

			LiveAgentMessage = System.Label.Live_Agent_Message;

			if(LiveAgentMessage == NULL){
				throw new ApplicationException('Message not specified');
			}
			
			LiveChatToastWrapper toastWrapperObj = new LiveChatToastWrapper(omnichannel_duration,omnichannel_mode,omnichannel_type,LiveAgentTitle,LiveAgentMessage);
			return toastWrapperObj;

		}
		catch(Exception e){

			LiveAgentTitle = 'Live Chat Alert';
			LiveAgentMessage = 'You are receiving an incoming chat.';
			LiveChatToastWrapper toastWrapperObj = new LiveChatToastWrapper(omnichannel_duration,omnichannel_mode,omnichannel_type,LiveAgentTitle,LiveAgentMessage);
			return toastWrapperObj;

		}		
	}
	@AuraEnabled	
	public static LiveChatToastWrapper getCaseParams(){

		String CaseTitle;
		String CaseMessage;
	
		try{
			
			toastParams();

			CaseTitle = System.Label.Omni_Channel_Case_Title;

			if(CaseTitle == NULL){
				throw new ApplicationException('Title not specified');
			}

			CaseMessage = System.Label.Omni_Channel_Case_Message;

			if(CaseMessage == NULL){
				throw new ApplicationException('Message not specified');
			}

			LiveChatToastWrapper toastWrapperObj = new LiveChatToastWrapper(omnichannel_duration,omnichannel_mode,omnichannel_type,CaseTitle,CaseMessage);
			return toastWrapperObj;

		}
		catch(Exception e){

			CaseTitle = 'Case Alert';
			CaseMessage = 'You are receiving an incoming case request.';
			LiveChatToastWrapper toastWrapperObj = new LiveChatToastWrapper(omnichannel_duration,omnichannel_mode,omnichannel_type,CaseTitle,CaseMessage);
			return toastWrapperObj;

		}

	}
	public class LiveChatToastWrapper{

		@AuraEnabled public Integer Duration;
		@AuraEnabled public String Mode;
		@AuraEnabled public String Type;
		@AuraEnabled public String Title;
		@AuraEnabled public String Message;
	    
	    public LiveChatToastWrapper( Integer toastDuration, String toastMode, String toastType, String toastTitle, String toastMessage){
	        
	        Duration = toastDuration;
	        Mode = toastMode;
	        Type = toastType;
	        Title = toastTitle;
	        Message = toastMessage;

	    }
	}
}