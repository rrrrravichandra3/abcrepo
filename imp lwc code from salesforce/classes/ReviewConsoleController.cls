public with sharing class ReviewConsoleController {
//ReviewConsole.page
	
	private List<ReferralInfo> referrals = new List<ReferralInfo>();
	private list<ProcessInstanceWorkitem> approvals = new list<ProcessInstanceWorkitem>();
	private list<Endorsement__c> endorsements = new list<Endorsement__c>();
	
    public Integer MAX_ROWS = 100;
    public Integer DEFAULT_SPAN = 1; //years
    public User currentUser{get;set;}
    public Integer totalReferrals = 0, totalApprovals = 0, totalEndorsement = 0;
    public Boolean ReferralFlag = False, ApprovalFlag = False, EndorseFlag = False;

    public ReviewConsoleController() {
    	
        String userName = UserInfo.getUserName();
        List<User> users = [Select Id, Email, firstName, lastName From User where UserName = :userName];
        if(users != null && users.size() == 1){
            currentUser = users[0];
        }
        
        DateTime startTime = DateTime.now().addYears(-1*DEFAULT_SPAN);
        DateTime endTime = DateTime.now();
        
		referrals = Utils.getMyReferrals(currentUser.Email, startTime, endTime, MAX_ROWS);
		
		approvals =  Utils.getMyApprovals( UserInfo.getUserId() );
		
		endorsements = Utils.getMyEndorsements( UserInfo.getUserId() );
		
        getMyTotalReferrals();
        getMyTotalApprovals();
        getMyTotalEndorsement();
 
    }	
	
	public List<ReferralInfo> getMyReferrals() {
        return referrals;
    }
	
	public Integer getMyTotalReferrals(){
		
		if ( getMyReferrals() != NULL ){
			totalReferrals = getMyReferrals().size();
		}	

		if ( totalReferrals == 0 )
			ReferralFlag = True;
							
		return totalReferrals;
		
	}
	
	public Boolean getReferralFlag(){
		return ReferralFlag;			
	}	

	public List<ProcessInstanceWorkitem> getMyApprovals(){
		return approvals;
	}
	
	public Integer getMyTotalApprovals(){
		
		if ( getMyApprovals() != NULL ){
			totalApprovals = getMyApprovals().size();
		}	

		if ( totalApprovals == 0 )
			ApprovalFlag = True;
						
		return totalApprovals;
	}
		
	public Boolean getApprovalFlag(){
		return ApprovalFlag;			
	}	

	public List<Endorsement__c> getMyEndorsements(){
		return endorsements;
	}
		
	public Integer getMyTotalEndorsement(){

		if ( getMyEndorsements() != NULL ){
			totalEndorsement = getMyEndorsements().size();
		}			

		if ( totalEndorsement == 0 )
			EndorseFlag = True;
						
		return totalEndorsement;
	}
		
	public Boolean getEndorseFlag(){
		return EndorseFlag;
	}
	
}