global with sharing class CaseConnectorMultiCaseTransferCtrl {

	public String filterId{
        get{
            return filterId;
        }
        set;
    }
    private ApexPages.StandardSetController caseSetController;
    public List<Case> selectedCases{
    	get{
    		if(selectedCases == null) {
                List<Case> selectedCasesPlain = (List<Case>) caseSetController.getSelected();

                    List<Id> selectedCaseIds = new List<Id>();
                    for(Case cse: selectedCasesPlain){
                        selectedCaseIds.add(cse.Id);
                    }
                    selectedCases = [SELECT Id, CaseNumber, PII__c, Origin, ContactId, Status, Subject, Description, Type, ES_DJC_Topic__c, ES_DJC_Sub_Topic__c, 
                                            ESDJC_Supportforce_Case_Id__c, ESDJC_Supportforce_Case_Number__c, Priority FROM Case 
                                            WHERE Id IN : selectedCaseIds];
            }
    		return selectedCases;
    	}
    	set;
    } 
    public CaseConnectorMultiCaseTransferCtrl(ApexPages.StandardSetController standardSetCtrl){
        this.caseSetController = standardSetCtrl;
        this.filterId = standardSetCtrl.getFilterId();
    }

    public String message{get; set;}
    public String messageHeader{get; set;}
    public boolean hasCaseSelectionError{get; set;}

    public boolean anyValidationFailed{
        get{
            message = '';
            messageHeader = '';
            hasCaseSelectionError = false;
            if(selectedCases.isEmpty()){
                messageHeader = 'Case Selection Error';
                message= Label.Case_Connector_Select_at_least_One_Case;
                hasCaseSelectionError = true;
                return true;
            }else if(selectedCases.size() > 10){
                messageHeader = 'Case Selection Error';
                message= Label.Case_Connector_Select_Only_up_to_10_Cases;
                hasCaseSelectionError = true;
                return true;
            }else{
                boolean hasPIICase = this.hasPIICase;
                boolean fieldValidationFailed = this.fieldValidationFailed;
                boolean alreadySentCaseSelected = this.alreadySentCaseSelected;
                messageHeader = fieldValidationFailed || alreadySentCaseSelected ? 'Validation Errors': '';
                messageHeader = hasPIICase ? 'Confidential Information': messageHeader;
                return (  hasPIICase || fieldValidationFailed || alreadySentCaseSelected);
            }
        }
        set;
    }

	public boolean hasPIICase{
	 	get{
 			for(Case cse : selectedCases){
 				if(cse.PII__c == 'Yes')	{
 					hasPIICase = true;
                    return true;
 				}
 			}
	 		return false;
	 	}
	 	set;
	}

    public List<Case> fieldValidationFailedCases{get; set;}

    public boolean fieldValidationFailed{
        get{
            fieldValidationFailed = false;
            fieldValidationFailedCases = new List<Case>();
            for(Case cse : selectedCases){
                if(cse.Priority == null || cse.ContactId == null || cse.Origin == null) {
                    fieldValidationFailed = true;
                    fieldValidationFailedCases.add(cse);
                }
            }
            return fieldValidationFailed;
        }
        set;
    }

    public List<Case> alreadySentCases{get; set;}

    public boolean alreadySentCaseSelected{
        get{
            alreadySentCaseSelected = false;
            alreadySentCases = new List<Case>();
            for(Case cse : selectedCases){
                if(cse.ESDJC_Supportforce_Case_Number__c != null) {
                    alreadySentCaseSelected = true;
                    alreadySentCases.add(cse);
                }
            }
            return alreadySentCaseSelected;
        }
        set;
    }

	public List<SelectOption> destinations{
		get{
			if(destinations == null){
				destinations = new List<SelectOption>();
				List<CaseConnectorUtil.CaseConnectorDestinationResponse> destinationsResponse = CaseConnectorUtil.getDestinations(getConfigurationForThisOrg(), new CaseConnectorPFtoSFException());
				for(CaseConnectorUtil.CaseConnectorDestinationResponse dest: destinationsResponse){
					destinations.add(new SelectOption(dest.name, dest.name));
				}
			}
			return destinations;
		}
		set;
	}
	// Just get dependent picklist functionality, need to use case object. Otherwise these is no use for this variable 
	public Case tempCase{get; set;}

    public String trasferingCaseId{get; set;}
    public String newType{get; set;}
    public String newTopic{get; set;}
    public String pii{get; set;}
    public String destination{get; set;}

    @RemoteAction
    global static CaseConnector_PforceToSforceUtil.CaseConnectorResponse transferThisCase(String trasferingCaseId, String newType, String newTopic, String pii, String destination){
        Case cse = [SELECT Id, CaseNumber, PII__c, Status, Subject, Description, Type, ES_DJC_Topic__c, ES_DJC_Sub_Topic__c, 
                    ESDJC_Supportforce_Case_Id__c, ESDJC_Supportforce_Case_Number__c, Priority FROM Case WHERE Id =: trasferingCaseId];

        cse.Type = newType;
        cse.ES_DJC_Topic__c = newTopic;
        cse.PII__c = pii;
        String priority = cse.Priority;
        if( priority != null) priority = priority.toUpperCase();
        String caseDescription = cse.Description;
        if(caseDescription == null || caseDescription  =='') caseDescription = 'No description is added';
        CaseConnector_PforceToSforceUtil.CaseConnectorResponse response = CaseConnector_PforceToSforceUtil.sendToDestination(cse, destination, '', cse.Subject, caseDescription, priority, true, true, pii);
        if(response.errored == false){
            response.message = 'Transfer Complete';
        }else{
            response.message = 'Failed : ' + response.message ;
        }
        return response;
    }

	private static Case_Connector_Settings__mdt getConfigurationForThisOrg(){
        List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorPFtoSFException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorPFtoSFException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        return settings.get(0);
    }

    public String orgToEligibleCaseTypes{
        get{
            if(orgToEligibleCaseTypes == null){
                 List<Case_Connector_PF_to_SF_Settings__mdt> orgEligibleTypesSettings = [SELECT DeveloperName,Setting_Type__c,Value1__c, Value2__c  
                                                                                                FROM Case_Connector_PF_to_SF_Settings__mdt WHERE Setting_Type__c='Eligibility'];
                 Map<String, List<String>> options = new Map<String, List<String>>();
                 for(Case_Connector_PF_to_SF_Settings__mdt typesSetting: orgEligibleTypesSettings){
                    if(typesSetting.Value2__c != null){
                        List<String> types = (typesSetting.Value1__c+ typesSetting.Value2__c).split(',');
                        options.put(typesSetting.DeveloperName, types);
                    }else{
                        List<String> types = (typesSetting.Value1__c).split(',');
                        options.put(typesSetting.DeveloperName, types);
                    }
                 }
                 orgToEligibleCaseTypes = JSON.serialize(options);

            }
            return orgToEligibleCaseTypes;
        }
        set;
    }

    public String successMessageTimeout{
        get{
            if(successMessageTimeout == null){
                List<Case_Connector_PF_to_SF_Settings__mdt> timeoutSettings = [SELECT DeveloperName,Setting_Type__c,Value1__c  FROM Case_Connector_PF_to_SF_Settings__mdt 
                                                                                            WHERE DeveloperName='Success_Message_Display_Timeout' AND Setting_Type__c='Generic Setting'];
                if(timeoutSettings.isEmpty()){
                    successMessageTimeout = '2000';
                }else{
                    successMessageTimeout = timeoutSettings[0].Value1__c;
                }
            }
            return successMessageTimeout;
        }

        set;
    }

}