public with sharing class JapanDNAController {

	private Employment_Application__c empApp;
	private String HTMLContent;

	public JapanDNAController(ApexPages.StandardController stdController) {
		this.empApp = (Employment_Application__c)stdController.getRecord();
		this.empApp = [ select Id, first_name_contact__c, last_name_contact__c, city_contact__c, state_contact__c, country_contact__c, 
						zip_postal_code_contact__c, current_address_contact__c, Electronic_Consent_NDA__c, Electronic_Consent_Email_Address_NDA__c, 
						Electronic_Consent_Full_Name_NDA__c, Date_Signed_NDA__c from Employment_Application__c where Id = : empApp.Id ];
		this.HTMLContent = Utils.locateFirstElementFromForm();
	}

	public Employment_Application__c getEmpApp(){

		return empApp;
	}

	public String getHTMLContent(){
		return HTMLContent;
	}

	public String getDateSignedNDA(){
        String dateSignedNDA = '';
        if(empApp.Date_Signed_NDA__c != null){
           dateSignedNDA = ((empApp.Date_Signed_NDA__c).format('YYYY-MM-dd','GMT')) + '  (GMT)';
        }
        return dateSignedNDA;
    }

}