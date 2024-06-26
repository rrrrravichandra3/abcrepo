public class DJC_WellnessTimeRangeManager_Fndt extends DJC_TimeRangeManager {
    private Date hireDate;
    private Date standardMinActDate;
    private String contactCountry;
    public DJC_WellnessTimeRangeManager_Fndt(DJC_Region region){
        super(region);
    }

    public override void setContactCountry(String contactCountry) {
        this.contactCountry = contactCountry;
    }

    public override String getCurrentTimeRange(){
        return getCurrentTimeRange(System.today());
    }

    public override String getCurrentTimeRange(Date targetDate){
        return super.getQuarter(targetDate);
    }

    public override String getPreviousTimeRange(){
        return getPreviousTimeRange(System.today());
    }   

    public override String getPreviousTimeRange(Date targetDate){

        if (region == null) {
            throw new ApplicationException ('region is null');
        }
        Integer month = targetDate.month();
        String quarter = '';
        Integer year;
        
        if (month <= 3){
            quarter = 'Q4';
        } else if (month <= 6){
            quarter = 'Q1';
        } else if (month <= 9){
            quarter = 'Q2';
        } else {
            quarter = 'Q3';
        }
        year = ((quarter == 'Q4') ? targetDate.year() -1 : targetDate.year());
        
        String result = String.format('{0} - {1}', new String[]{quarter, String.valueOf(year)});
        return result;
    }
    
    public override Boolean isDateMorethanOnePeriodBack(Date targetDate){
        String claimQuarter = getCurrentTimeRange(targetDate);
        if ((targetDate < system.today()) && (claimQuarter != getCurrentTimeRange()) &&
                            (claimQuarter != getPreviousTimeRange())) {
            return true;                                            
        }                    
        return false;
    }
    
    public override String getDateOutOfPeriodErrorMessage(){
        return System.Label.ES_Wellness_date_out_of_period_message_quarter;
    }
    
    public override Date getMinDateInCurrentPeriod(){

        Date currentDate = System.today();
        Integer month = currentDate.month();
        hireDate = [select id,contact.Start_Date__c from User where id=:UserInfo.getUserId() limit 1 ].contact.Start_Date__c; //assuming hireDate__c is the name of the field
        System.debug('hireDate'+hireDate);
        if (region == DJC_Region.EMEA || region == DJC_Region.JAPAN){
            if (month <= 3){
                standardMinActDate = Date.newInstance(currentDate.year() - 1, 10, 1);
            } else if (month <= 6){
                standardMinActDate = Date.newInstance(currentDate.year(), 1, 1);
            } else if (month <= 9){
                standardMinActDate = Date.newInstance(currentDate.year(), 4, 1);
            } else {
                standardMinActDate = Date.newInstance(currentDate.year(), 7, 1);
            }
            return (hireDate>standardMinActDate)?hireDate:standardMinActDate;
        } else if (region == DJC_Region.APAC || region == DJC_Region.LACA) {
            if ((month == 1) || (month >= 11)){
                if(month == 1){
                    standardMinActDate = Date.newInstance(currentDate.year() - 1, 8, 1);
                }else{
                    standardMinActDate = Date.newInstance(currentDate.year(), 8, 1);
                }
            } else if (month <= 4){
                standardMinActDate =  Date.newInstance(currentDate.year() - 1, 11, 1);
            } else if (month <= 7){
                standardMinActDate =  Date.newInstance(currentDate.year(), 2, 1);
            } else if (month <= 10){
                standardMinActDate =  Date.newInstance(currentDate.year(), 5, 1);
            }
            return (hireDate>standardMinActDate)?hireDate:standardMinActDate;
        }
        return null;
    }

    public override Date getMaxDateInCurrentPeriod(){

        Date currentDate = System.today();
        Integer month = currentDate.month();

        if (region == DJC_Region.EMEA || region == DJC_Region.JAPAN){
            if (month <= 3){
                return Date.newInstance(currentDate.year(), 3, 31);
            } else if (month <= 6){
                return Date.newInstance(currentDate.year(), 6, 30);
            } else if (month <= 9){
                return Date.newInstance(currentDate.year(), 9, 30);
            } else {
                return Date.newInstance(currentDate.year(), 12, 31);
            }
        } else if (region == DJC_Region.APAC || region == DJC_Region.LACA) {
            if ((month == 1) || (month >= 11)){
                if(month == 1){
                    return Date.newInstance(currentDate.year(), 1, 31);
                }else{
                    return Date.newInstance(currentDate.year() + 1, 1, 31);
                }
            } else if (month <= 4){
                return Date.newInstance(currentDate.year(), 4, 30);
            } else if (month <= 7){
                return Date.newInstance(currentDate.year(), 7, 31);
            } else if (month <= 10){
                return Date.newInstance(currentDate.year(), 10, 31);
            }
        }
        return null;
    }
}