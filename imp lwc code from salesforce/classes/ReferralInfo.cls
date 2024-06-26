public  class ReferralInfo {
	public String referralId {get; set;}
	public String jobId {get; set;}
	public String jobURL {get; set;}
	public String applicantURL {get; set;}
	public String managerURL {get; set;}
	public String recruiterURL {get; set;}
	public String name {get; set;}
	public String prospectName {get; set;}
	public String prospectEmail {get;set;}
	public String jobName {get; set;}
	public String jobStatus {get; set;}
	public String recruiterName {get; set;} 
	public String referralLink {get; set;}
	public boolean isApplied {get; set;}
	public String applicationStatus {get; set;}
	public String applicationStage {get; set;}
	public DateTime createdDate {get; set;}
	public String jobLocation {get; set;}
	public String hiringManager {get; set;}
	public DateTime candidateLastActivityDate {get; set;}
	public boolean isJobPosted{get;set;}
	public Date startDate {get; set;}
	public Date payOutDate {get; set;}
	public Boolean nullstageflag {get; set;}
	public Boolean appstageflag {get; set;}
	public Boolean substageflag {get; set;}
	public Boolean hmsubstageflag {get; set;}
	public Boolean int1stageflag {get; set;}
	public Boolean int2stageflag {get; set;}
	public Boolean int3stageflag {get; set;}
	public Boolean offstageflag {get; set;}
	public Boolean plastageflag {get; set;}
	
		
		
	public ReferralInfo() {
		
	}
	
	public Integer displayStatus{
	get{
		if(isApplied){
			return 1;
		} else if(isJobPosted) {
			return 2;
		} else {
			return 3;
		}
	}
	set{
	}}
}