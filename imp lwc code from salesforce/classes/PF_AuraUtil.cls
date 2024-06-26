public class PF_AuraUtil {
	
    public static String getStringFromDate(Date dateToConvert){
        return dateToConvert.year() + '-' + (dateToConvert.month() - 1) + '-' + dateToConvert.day();
    }
    
}