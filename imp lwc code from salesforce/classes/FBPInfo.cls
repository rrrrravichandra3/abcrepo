public class FBPInfo {

	private boolean selectedFBP;
	private Regional_FBP_Lookup__c fbpInfo;
	
	
	public boolean getSelectedFBP() {
		return this.selectedFBP ;
	}
	public void setSelectedFBP(boolean selectedFBP) {
		this.selectedFBP = selectedFBP;
	}
	
	public Regional_FBP_Lookup__c getFbpInfo() {
		return this.fbpInfo ;
	}
	
	public void setFbpInfo(Regional_FBP_Lookup__c fbpInfo) {
		this.fbpInfo = fbpInfo;
	}
		
	public FBPInfo(Regional_FBP_Lookup__c fbpInfo){
		this.fbpInfo = fbpInfo;
		this.selectedFBP = false;
	}	
}