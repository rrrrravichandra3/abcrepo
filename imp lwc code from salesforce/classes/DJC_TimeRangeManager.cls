public abstract class DJC_TimeRangeManager {

    protected DJC_Region region{get;set;}

	public DJC_TimeRangeManager(DJC_Region region) {
		this.region = region;
	}

    public DJC_Region getRegion() {
        return region;
    }
	
    public String getQuarter(Date targetDate) {
		if (region == null) {
            throw new ApplicationException ('Unable to identify the user division');
        }
        if (targetDate == null) {
            throw new ApplicationException ('Date of activity is empty');
        }

        Integer month = targetDate.month();
        String quarter = '';
        Integer year;

        if (region == DJC_Region.APAC || region == DJC_Region.LACA) {
            if ((month == 1) || (month >= 11)) {
                quarter = 'Q4';
            } else if (month <= 4) {
                quarter = 'Q1';
            } else if (month <= 7) {
                quarter = 'Q2';
            } else if (month <= 10) {
                quarter = 'Q3';
            }
            year = (month == 1? targetDate.year() -1 : targetDate.year());
        }else{
            if (month <= 3) {
                quarter = 'Q1';
            } else if (month <= 6) {
                quarter = 'Q2';
            } else if (month <= 9) {
                quarter = 'Q3';
            } else {
                quarter = 'Q4';
            }
            year = targetDate.year();

        }
        String result = String.format('{0} - {1}', new String[]{quarter, String.valueOf(year)});
        return result;
	}

	public abstract String getCurrentTimeRange();

	public abstract String getPreviousTimeRange();

	public abstract String getCurrentTimeRange(Date targetDate);

	public abstract String getPreviousTimeRange(Date targetDate);

    public abstract void setContactCountry(String contactCountry);
	
	public abstract Boolean isDateMorethanOnePeriodBack(Date targetDate);
    
    public abstract String getDateOutOfPeriodErrorMessage();
    
    public abstract Date getMinDateInCurrentPeriod();
    
    public abstract Date getMaxDateInCurrentPeriod();
}