public with sharing class DJC_YearEducationTimeRangeManager extends DJC_TimeRangeManager{
	private Date hireDate;
    private Date standardMinActDate;
    private String contactCountry;
    public DJC_YearEducationTimeRangeManager(DJC_Region region){
        super(region);
    }

    public override void setContactCountry(String contactCountry) {
        this.contactCountry = contactCountry;
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
        
        Integer month = targetDate.month();
        Integer day = targetDate.day();
        Integer year = targetDate.year();
        
        if(month == 12){
            year++;
        }
        
        return String.valueOf(year);
    }

    public override String getPreviousTimeRange(){
        return getPreviousTimeRange(System.today());
    }

    public override String getPreviousTimeRange(Date targetDate){

        if (region == null) {
            throw new ApplicationException ('region is null');
        }

        Integer month = targetDate.month();
        Integer day = targetDate.day();
        Integer year = targetDate.year();
        
        if(month < 12){
            year--;
        }
        
        return String.valueOf(year);
    }

    public override Boolean isDateMorethanOnePeriodBack(Date targetDate){

        String claimFiscalYear = getCurrentTimeRange(targetDate);
        
        return  targetDate < system.today() &&
                claimFiscalYear != getCurrentTimeRange();
    }

    public override String getDateOutOfPeriodErrorMessage(){
        return System.Label.ES_Wellness_date_out_of_period_message_year;
    }
    
    public override Date getMinDateInCurrentPeriod(){
        
        Date currentDate = System.today();
        hireDate = [select id,contact.Start_Date__c from User where id=:UserInfo.getUserId() limit 1 ].contact.Start_Date__c;
        if(currentDate.month() < 12){
            standardMinActDate = Date.newInstance(currentDate.year() - 1, 12, 1);
            return (hireDate>standardMinActDate)?hireDate:standardMinActDate;
        }else{
            standardMinActDate = Date.newInstance(currentDate.year(), 12, 1);
            return (hireDate>standardMinActDate)?hireDate:standardMinActDate;
        }
    }
    
    public override Date getMaxDateInCurrentPeriod(){
        
        Date currentDate = System.today();
        
        if(currentDate.month() < 12){
            return Date.newInstance(currentDate.year(), 11, 30);
        }else{
            return Date.newInstance(currentDate.year() + 1, 11, 30);
        }
    }
}