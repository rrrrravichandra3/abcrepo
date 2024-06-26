public with sharing class REWS_Package_Email_Controller{
	
	public String emailType{get;set;}
	public String caseId{get;
		set {
			caseId = value;
			caseDetail = [select contact.Name,REWS_Sender__c,REWS_Carrier__c,REWS_Delivery_Location__c,REWS_Received_Location__c, REWS_Reminder_Notification_Trigger__c,
					 (select REWS_Status__c,REWS_Tracking_Number__c from REWS_Package_Delivery__r) from Case where id =:caseId];
		}
	}
	//public String packageId{get;set;}
	
	public Case caseDetail{get; private set;}
	
	public String getPerishableEmailText() {
		String receivedLocation = (caseDetail == null || caseDetail.REWS_Received_Location__c == null)?'':caseDetail.REWS_Received_Location__c;
		List<String> args = new List<String>{receivedLocation, receivedLocation};
		String label = String.format(System.Label.REWS_Perishable, args);
		return label;	
	}
	
	public String getRushedEmailText() {
		String receivedLocation = (caseDetail == null || caseDetail.REWS_Received_Location__c == null)?'':caseDetail.REWS_Received_Location__c;
		List<String> args = new List<String>{receivedLocation, receivedLocation};
		String label = String.format(System.Label.REWS_Rushed, args);
		return label;	
	}
  	
  	public String getOversizedEmailText() {
		String receivedLocation = (caseDetail == null || caseDetail.REWS_Received_Location__c == null)?'':caseDetail.REWS_Received_Location__c;
		List<String> args = new List<String>{receivedLocation, receivedLocation};
		String label = String.format(System.Label.REWS_Oversized, args);
		return label;	
	}

	public String getOversizedEmailTextFooter() {
		REWS_Setting__c rewSettings= REWS_Setting__c.getInstance();

		List<String> args = new List<String>{rewSettings.REWS_Oversize_Registration_Form__c};
		String label = String.format(System.Label.REWS_Oversize_Registration_Footer, args);
		return label;	
	}

	public String getReminderNotificationText(){
		if(caseDetail.REWS_Reminder_Notification_Trigger__c == 'First Notification'){
			return getFirstReminderText();
		}else if(caseDetail.REWS_Reminder_Notification_Trigger__c == 'Second Notification'){
			return getSecondReminderText();
		}else if(caseDetail.REWS_Reminder_Notification_Trigger__c == 'Third Notification'){
			return getThirdReminderText();
		}else if(caseDetail.REWS_Reminder_Notification_Trigger__c == 'Final Notification'){
			return getForthAndFinalReminderText();
		}
		return null;
	}

	public String getFirstReminderText() {
		String currentLocation = (caseDetail == null || caseDetail.REWS_Delivery_Location__c == null)?'':caseDetail.REWS_Delivery_Location__c;
		List<String> args = new List<String>{currentLocation};
		String label = String.format(System.Label.REWS_Package_First_Reminder_Text, args);
		return label;
	}

	public String getSecondReminderText() {
		String currentLocation = (caseDetail == null || caseDetail.REWS_Delivery_Location__c == null)?'':caseDetail.REWS_Delivery_Location__c;
		List<String> args = new List<String>{currentLocation};
		String label = String.format(System.Label.REWS_Package_Second_Reminder_Text, args);
		return label;
	}

	public String getThirdReminderText() {
		String currentLocation = (caseDetail == null || caseDetail.REWS_Delivery_Location__c == null)?'':caseDetail.REWS_Delivery_Location__c;
		List<String> args = new List<String>{currentLocation};
		String label = String.format(System.Label.REWS_Package_Third_Reminder_Text, args);
		return label;
	}

	public String getForthAndFinalReminderText() {
		String currentLocation = (caseDetail == null || caseDetail.REWS_Delivery_Location__c == null)?'':caseDetail.REWS_Delivery_Location__c;
		List<String> args = new List<String>{currentLocation};
		String label = String.format(System.Label.REWS_Package_Forth_Final_Reminder_Text, args);
		return label;
	}

	public String getDailyMailText() {
		String currentLocation = (caseDetail == null || caseDetail.REWS_Delivery_Location__c == null)?'':caseDetail.REWS_Delivery_Location__c;
		List<String> args = new List<String>{currentLocation, currentLocation};
		String label = String.format(System.Label.REWS_Package_Daily_Notification_Email_Text, args);
		return label;
	}

	public String getRegularEmailText() {
		String currentLocation = (caseDetail == null || caseDetail.REWS_Delivery_Location__c == null)?'':caseDetail.REWS_Delivery_Location__c;
		List<String> args = new List<String>{currentLocation, currentLocation};
		String label = String.format(System.Label.REWS_Regular_Email, args);
		return label;
	}

	public String getEmailFooterText() {
		return String.format(System.Label.REWS_Footer_Email, null);
	}


	public String getTrackingNumbers(){
		String trackingNumbers='';
		if(caseDetail!=null){
			for(REWS_Package_Delivery__c package_d : caseDetail.REWS_Package_Delivery__r){
				trackingNumbers=trackingNumbers+package_d.REWS_Tracking_Number__c+',';
			}
			trackingNumbers = trackingNumbers.removeEnd(',');
			trackingNumbers.trim();
		}
		return trackingNumbers;
	}

	public String getSiteURL(){
        return ESDJC_Util.getSiteURL();
    }
}