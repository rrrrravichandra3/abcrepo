public class DJC_YearTimeRangeManager extends DJC_TimeRangeManager{

    private Date hireDate;
    private String contactCountry;
    private Date standardMinActDate;

	public DJC_YearTimeRangeManager(DJC_Region region){
		super(region);
	}

    public override void setContactCountry(String country) {
        this.contactCountry = country;
    }

	public override String getCurrentTimeRange(){
		return getCurrentTimeRange(System.today());
	}

	public override String getCurrentTimeRange(Date targetDate){

        if (region == null) {
            throw new ApplicationException ('region is null');
        }
        if (targetDate == null) {
            throw new ApplicationException ('targetDate is null');
        }               
        if (contactCountry == null) {
            contactCountry = [SELECT Id,Contact.ES_DJC_Contact_Country__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1].Contact.ES_DJC_Contact_Country__c;
        } 
        if (region == DJC_Region.EMEA || region == DJC_Region.JAPAN) {
            return String.format('01 - {0}', new String[]{String.valueOf(targetDate.year())});
        } else if (region == DJC_Region.APAC && contactCountry!=null && contactCountry.equalsIgnoreCase(System.Label.ES_DJC_Country_India_Label)) {
            Integer year = targetDate.month() > 7 ? targetDate.year() : targetDate.year() - 1;
            return String.format('02 - {0}', new String[]{String.valueOf(year)});
        } else if (region == DJC_Region.APAC || region == DJC_Region.LACA) {
            Integer year = targetDate.month() > 1 ? targetDate.year() : targetDate.year() - 1;
            return String.format('02 - {0}', new String[]{String.valueOf(year)});
        }        
        return null;
	}

	public override String getPreviousTimeRange(){
		return getPreviousTimeRange(System.today());
	}

	public override String getPreviousTimeRange(Date targetDate){

        if (region == null) {
            throw new ApplicationException ('region is null');
        }
        Integer month = targetDate.month();
        Integer year = targetDate.year();
        if (contactCountry == null) {
            contactCountry = [SELECT Id,Contact.ES_DJC_Contact_Country__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1].Contact.ES_DJC_Contact_Country__c;
        } 
        if (region == DJC_Region.EMEA || region == DJC_Region.JAPAN){
            year--;
            return String.format('01 - {0}', new String[]{String.valueOf(year)});
        } else if (region == DJC_Region.APAC && contactCountry!=null && contactCountry.equalsIgnoreCase(System.Label.ES_DJC_Country_India_Label)) {
            year = month > 7 ? year - 1 : year - 2;
            return String.format('02 - {0}', new String[]{String.valueOf(year)});
        } else if (region == DJC_Region.APAC || region == DJC_Region.LACA) {
            year = month > 1 ? year - 1 : year - 2;
            return String.format('02 - {0}', new String[]{String.valueOf(year)});
        }        
        return null;
	}

    public override Boolean isDateMorethanOnePeriodBack(Date targetDate){

        String claimFiscalYear = getCurrentTimeRange(targetDate);
        DJC_QuarterTimeRangeManager quarterPolicyManager = new DJC_QuarterTimeRangeManager(region);
        String currentQuarter = quarterPolicyManager.getCurrentTimeRange();

        return  targetDate < system.today() &&
                claimFiscalYear != getCurrentTimeRange() &&
                claimFiscalYear != getPreviousTimeRange();
    }

    public override String getDateOutOfPeriodErrorMessage(){
        return System.Label.ES_Wellness_date_out_of_period_message_year;
    }
    
    public override Date getMinDateInCurrentPeriod(){
        
        Date currentDate = Date.today();
        User currentUser = [select id,Contact.Start_Date__c,Contact.ES_DJC_Contact_Country__c from User where id=:UserInfo.getUserId() limit 1 ];
        hireDate = currentUser.Contact.Start_Date__c;
        if (contactCountry == null) {
            contactCountry = currentUser.Contact.ES_DJC_Contact_Country__c;
        }
        if (region == DJC_Region.EMEA || region == DJC_Region.JAPAN){
            standardMinActDate = Date.newInstance(currentDate.year() - 1, 1, 1);
            return (hireDate > standardMinActDate) ? hireDate:standardMinActDate;
        } else if (region == DJC_Region.APAC && contactCountry.equalsIgnoreCase(System.Label.ES_DJC_Country_India_Label)) {
            Integer year = currentDate.month() > 7 ? currentDate.year() - 1 : currentDate.year() - 2;
            standardMinActDate = Date.newInstance(year, 8, 1);
            return (hireDate > standardMinActDate) ? hireDate:standardMinActDate;
        }
        else if (region == DJC_Region.APAC || region == DJC_Region.LACA) {
            Integer year = currentDate.month() > 1 ? currentDate.year() - 1 : currentDate.year() - 2;
            standardMinActDate = Date.newInstance(year, 2, 1);
            return (hireDate > standardMinActDate) ? hireDate:standardMinActDate;
        }
        
        return null;
    }
    
    public override Date getMaxDateInCurrentPeriod(){
        
        Date currentDate = Date.today();
        
        if (region == DJC_Region.EMEA || region == DJC_Region.JAPAN){
            return Date.newInstance(currentDate.year(), 12, 31);
        } else if (region == DJC_Region.APAC || region == DJC_Region.LACA) {
            Integer year = currentDate.month() > 1 ? currentDate.year() + 1 : currentDate.year();
            return Date.newInstance(year, 1, 31);
        }
        
        return null;
    }
}