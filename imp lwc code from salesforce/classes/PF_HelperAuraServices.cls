public class PF_HelperAuraServices {
    
    public static String getDateAsString(Date d){
        if(d != null){
            return d.year() + '-' + (d.month() - 1) + '-' + d.day();
        }
        return null;
    }
}