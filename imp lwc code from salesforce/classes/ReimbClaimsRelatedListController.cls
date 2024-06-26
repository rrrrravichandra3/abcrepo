public with sharing class ReimbClaimsRelatedListController {
    private ApexPages.StandardSetController claimSetController;
    public string parentId{get;set;}
    public string caseDetURL{get;set;}
    public String listViewId;
    public String auraAttribute{get;set;}
    public boolean isreload{get;set;}
    public boolean isEmpty{get;set;}
    public string modalHeaderText{get;set;}
    public string modalBody{get;set;}
    public string modalButtonText{get;set;}
    public string selectedClaimIdsStr{get;set;}
    public List<id> selectedClaimIds = new List<id>();
    
    public ReimbClaimsRelatedListController(ApexPages.StandardSetController standardSetCtrl){
        this.claimSetController = standardSetCtrl;       
        List<DJC_Wellness_Reimbursement_Claim__c> claimsSelected = claimSetController.getSelected();
        system.debug('claimsSelected'+claimsSelected.size());
        claimsSelected = [SELECT id,DJC_Wellness_Request_Status__c,DJC_Wellness_Case__c 
                                                                    from DJC_Wellness_Reimbursement_Claim__c 
                                                                    where id in :claimsSelected];
        String PreviousPageRef = String.valueOf(claimSetController.cancel()) ;

        if(claimsSelected.size()>0){
            selectedClaimIds = new List<id>();                      
            isEmpty = false;
            for(DJC_Wellness_Reimbursement_Claim__c claimSelected : claimsSelected){
                selectedClaimIds.add(claimSelected.Id); 
                parentId = claimSelected.DJC_Wellness_Case__c;
            }
            selectedClaimIdsStr = JSON.Serialize(selectedClaimIds);
        }else{
            isEmpty = true;
            parentId = PreviousPageRef.substringBefore('?');
            parentId = parentId.removeStartIgnoreCase('System.PageReference[/');
            parentId = parentId.remove(']');
        }    
        system.debug('parentId'+parentId); 
 		caseDetURL = PreviousPageRef.substringBetween('System.PageReference[', ']');
    }

    @remoteaction
    public static ReimbClaimsRelatedListController.ReimbClaimsResponse approveClaims(String ClaimIdsStr){
        system.debug('ClaimIdsStr'+ClaimIdsStr);
        ReimbClaimsRelatedListController.ReimbClaimsResponse response= new ReimbClaimsResponse();
        try{
            List<string> ClaimIds = (List<id>)JSON.deserialize(ClaimIdsStr, List<string>.class);
            system.debug('approveClaims'+ClaimIds);
            List<DJC_Wellness_Reimbursement_Claim__c> claimsSelected = [SELECT id,DJC_Wellness_Request_Status__c,DJC_Wellness_Case__c 
                                                                        from DJC_Wellness_Reimbursement_Claim__c 
                                                                        where id in :ClaimIds];
            for(DJC_Wellness_Reimbursement_Claim__c claim:claimsSelected){
                claim.DJC_Wellness_Request_Status__c = 'Approved';
            }
            update claimsSelected;    
            response.hasError = false;
            response.message = 'Your selected claims are now approved!';
            
        }catch(Exception ex){
            system.debug('Exception occured '+ex); 
            response.hasError=true;
            response.message = 'Exception occured while approving claims '+ex.getMessage();
        }
        
        return response;
    }

    public class ReimbClaimsResponse{
        String message;
        Boolean hasError;
    }
    
}