public with sharing class CaseConnectorRecoverFailedCaseTransfCtrl {

	private final Case_Connector_Error__c caseConnectorError;

    public CaseConnectorRecoverFailedCaseTransfCtrl(ApexPages.StandardController stdController) {
        Case_Connector_Error__c error = (Case_Connector_Error__c)stdController.getRecord();
        caseConnectorError = [SELECT Aditional_Details__c,Case__c,HTTPCode__c,Message__c,Name,Need_Recovery__c,Recovered__c,
            Request__c,Step__c,Transction_Id__c FROM Case_Connector_Error__c where Id = :error.Id];

    }

    public PageReference isEligible(){
        if(!this.caseConnectorError.Need_Recovery__c){
            return New PageReference('/'+this.caseConnectorError.Case__c);
        }else{
            Case_Connector_Settings__mdt config = CaseConnector_PforceToSforceUtil.getConfigurationForThisOrg();
            Case caseToTransfer = new Case(Id = this.caseConnectorError.Case__c);
            if(caseConnectorError.Step__c == 'Step 3: Get Target Case Details'){
               try{
                    Map<String, String> requestValues = (Map<String, String>) JSON.deserialize(caseConnectorError.Request__c, Map<String, String>.class);
                    CaseConnectorUtil.CaseConnectorTargetCaseModel tragetCaseDetails = CaseConnectorUtil.getTargetOrgCaseDetails(config, caseConnectorError.Transction_Id__c, new CaseConnectorPFtoSFException());
                    // Update case with Internal support category, Status, Supportforce Case Number and Supportfoce Case Id
                    caseToTransfer.ESDJC_Supportforce_Case_Number__c = tragetCaseDetails.destinationNumber;
                    caseToTransfer.ESDJC_Supportforce_Case_Id__c = tragetCaseDetails.destinationId;
                    caseToTransfer.PII__c = requestValues.get('PII__c');
                    caseToTransfer.Status='Closed';
                    try{
                        update caseToTransfer;
                        this.caseConnectorError.Recovered__c = true;
                        update caseConnectorError;
                    }catch(Exception ex){
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                        return null;
                    }
                }catch(CaseConnectorException ccex){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ccex.getMessage()));
                    return null;
                }catch (Exception ex){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                    return null;
                }     
            }else if(caseConnectorError.Step__c == 'Step 4: Update PF Case'){
               try{
                    CaseConnectorUtil.CaseConnectorTargetCaseModel tragetCaseDetails = CaseConnectorUtil.getTargetOrgCaseDetails(config, caseConnectorError.Transction_Id__c, new CaseConnectorPFtoSFException());
                    // Update case with Internal support category, Status, Supportforce Case Number and Supportfoce Case Id
                    Map<String, String> requestValues = (Map<String, String>) JSON.deserialize(caseConnectorError.Request__c, Map<String, String>.class);

                    caseToTransfer.ESDJC_Supportforce_Case_Number__c = requestValues.get('ESDJC_Supportforce_Case_Number__c');
                    caseToTransfer.ESDJC_Supportforce_Case_Id__c = requestValues.get('ESDJC_Supportforce_Case_Id__c');
                    caseToTransfer.PII__c = requestValues.get('PII__c');
                    caseToTransfer.Status='Closed';
                    try{
                        update caseToTransfer;
                        this.caseConnectorError.Recovered__c = true;
                        update caseConnectorError;
                    }catch(Exception ex){
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                        return null;
                    }
                    
                }catch(CaseConnectorException ccex){
                    
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ccex.getMessage()));
                    return null;
                    //return new CaseConnectorResponse(true, ccex.getMessage());
                }catch (Exception ex){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                    return null;
                    //return new CaseConnectorResponse(true, ex.getMessage());
                }     
            }
            
        }
        return null;
    }
}