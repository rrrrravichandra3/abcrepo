public with sharing class CaseConnectorSingleCaseImplementationEx {

	private final Case cse;

    public CaseConnectorSingleCaseImplementationEx(ApexPages.StandardController stdController) {
        this.cse = (Case)stdController.getRecord();
    }
    public String selectedOrg{
        get;
        set{
            if(value != null){
                selectedOrg = value;
                selectedOrgRoutes = orgsRoutes.get(value);
            }else{
                selectedOrg = value;
                selectedOrgRoutes = new List<SelectOption>();
            }
        }
    }
    public String selectedRoute{ get; set;}
    public Boolean sendAttachments{get; set;}
    public Boolean sendComments{get; set;}
    public List<SelectOption> selectedOrgRoutes{get; set;}

    private Map<String, List<SelectOption>> orgsRoutes{get; set;}
    public List<SelectOption> targetOrgs{
        get{
            if(targetOrgs == null){
                targetOrgs = new List<SelectOption>();
                targetOrgs.add(new SelectOption('','--none--'));
                List<CaseConnectorUtil.CaseConnectorDestinationResponse> destinations = CaseConnectorUtil.getDestinations(getConfigurationForThisOrg(), new CaseConnectorExampleException());
                orgsRoutes = new Map<String, List<SelectOption>>();
                for(CaseConnectorUtil.CaseConnectorDestinationResponse destination: destinations){
                    targetOrgs.add(new SelectOption(destination.name, destination.Name));
                    List<SelectOption> routesForAOrg = new List<SelectOption>();
                    routesForAOrg.add(new SelectOption('', '--none--'));
                    for(String route: destination.routes){
                        routesForAOrg.add(new SelectOption(route, route));
                    }
                    orgsRoutes.put(destination.name, routesForAOrg);
                }
            }
            return targetOrgs;
        }
        set;
    }
    public static Case_Connector_Settings__mdt getConfigurationForThisOrg(){
        List<Case_Connector_Settings__mdt> settings = [SELECT Case_Transfer_Destination_URL__c,Case_Transfer_URL__c,
                                                       DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,
                                                       Org_External_URL__c,QualifiedApiName,Sandbox_Production__c 
                                                       FROM Case_Connector_Settings__mdt where Org_External_URL__c =: URL.getSalesforceBaseUrl().toExternalForm()];
        if(settings.isEmpty()) throw new CaseConnectorExampleException('No Configurations found for this Org: '+URL.getSalesforceBaseUrl()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) add configuration this Org.');
        else if(settings.size() > 1) throw new CaseConnectorExampleException('Multiple Configurations found for this Org: '+URL.getSalesforceBaseUrl().toExternalForm()+'. Please go to Case Connector Settings(Case_Connector_Settings__mdt) keep only one config and remove extra configurations this Org.');
        return settings.get(0);
    }

    public PageReference updateTargetSelections(){
        return null;
    }
    public String dummy{get; set;} // For Section Refresh we need to pass param back to server

    public PageReference sendToTargetOrg(){
        CaseConnectorResponse response = sendToDestination(cse.id, selectedOrg, selectedRoute, cse.subject, cse.Description, 'MEDIUM', sendAttachments, sendComments);
        if(response.errored == true){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.FATAL, response.message);
            ApexPages.addMessage(errorMessage);
        }else{
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, response.message);
            ApexPages.addMessage(errorMessage);
        }
        return null;
    }

    public CaseConnectorResponse sendToDestination(Id caseId, String destination, String route, String subject, String description, String priority, boolean transferAttachments, boolean transferComments){
        Case_Connector_Settings__mdt config = getConfigurationForThisOrg();
        String transactionId = null;
        CaseConnectorUtil.CaseConnectorTransferModel caseTransfer = null;
        try{
            caseTransfer = new CaseConnectorUtil.CaseConnectorTransferModel(caseId, destination, route, subject, description, priority, transferAttachments, transferComments);
            CaseConnectorUtil.CaseTransferResponseModal transfered = CaseConnectorUtil.sendToDestination(caseTransfer, config, new CaseConnectorExampleException());
            transactionId = transfered.id;

        }catch(CaseConnectorException ccex){
            ccex.handle('Step 2: Transfer Case', JSON.serialize(caseTransfer), null, false, caseId);
            if(ccex.getMessage().contains('"route":"may not be empty"')){
                return new CaseConnectorResponse(true, 'Target Route can not be null');
            }else if(ccex.getMessage().contains('No contact found in the destination org for email')){
                return new CaseConnectorResponse(true, 'Contact Data miss match between Source and Target Orgs. Contact matching happens through Contact Email, Federation Id or Employee Number.(Also, Multiple matches are considered as missmatch)');
            }else if(ccex.httpCode == null){
                return new CaseConnectorResponse(true, ccex.getMessage());
            }else{
                String responseString = ccex.getMessage();
                String errorString = responseString;
                if(responseString != null){
                    Map<String, Object> messageBody = (Map<String, Object>)JSON.deserializeUntyped(responseString);
                    errorString = (String)messageBody.get('message');
                }
                return new CaseConnectorResponse(true, errorString);
            }
        }catch (Exception ex){
            return new CaseConnectorResponse(true, ex.getMessage());
        }

        try{
            CaseConnectorUtil.CaseConnectorTargetCaseModel tragetCaseDetails= CaseConnectorUtil.getTargetOrgCaseDetails(config, transactionId, new CaseConnectorExampleException());
        }catch(CaseConnectorException ccex){
            Map<String, String> logDetails = new Map<String, String>();
                logDetails.put('Id', caseId);
                logDetails.put('url', config.Case_Transfer_URL__c +'/'+transactionId);
                String log = JSON.serialize(logDetails);
            ccex.handle('Step 3: Get Target Case Details', log, transactionId, true, caseId);
            return new CaseConnectorResponse(true, ccex.getMessage());
        }catch (Exception ex){
            return new CaseConnectorResponse(true, ex.getMessage());
        }
        
        return new CaseConnectorResponse(false, 'Case is successfully transfered to '+ destination);
     }

    public class CaseConnectorResponse {
        public CaseConnectorResponse(Boolean errored, String message){
            this.errored = errored;
            this.message = message;
        }
        public CaseConnectorResponse(){
        }
        public Boolean errored{get; set;}
        public String message{get; set;}
    }

}