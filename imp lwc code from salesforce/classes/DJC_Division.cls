public with sharing class DJC_Division {

    private static String DEFAULT_TIMEZONE = 'America/Los_Angeles';

    public static DJC_Division AMERUSA{get{if(AMERUSA == null){instantiateValues();}return AMERUSA;}private set;}
    public static DJC_Division AMERCANADA{get{if(AMERCANADA == null){instantiateValues();}return AMERCANADA;}private set;}
    public static DJC_Division APAC{get{if(APAC == null){instantiateValues();}return APAC;}private set;}
    public static DJC_Division EMEA{get{if(EMEA == null){instantiateValues();}return EMEA;}private set;}
    public static DJC_Division JAPAN{get{if(JAPAN == null){instantiateValues();}return JAPAN;}private set;}
    public static DJC_Division LACA{get{if(LACA == null){instantiateValues();}return LACA;}private set;}

    public String name{get; private set;}
    public String timeZoneKey{get; private set;}

    private DJC_Division(String name, String timeZone){
        this.name = name;
        this.timeZoneKey = timeZone;
    }
    
    private static void instantiateValues(){
        
        List<BusinessHours> bhours = [SELECT Name, TimeZoneSidKey, IsActive, IsDefault FROM BusinessHours];
        BusinessHours defaultbhours = null;
        
        for(BusinessHours bh:bhours){
            if(bh.name.equals('Americas')){
                AMERUSA = new DJC_Division('Americas - USA', bh.TimeZoneSidKey);
                AMERCANADA = new DJC_Division('Americas - Canada', bh.TimeZoneSidKey);
            }else if(bh.name.equals('APAC')){
                APAC = new DJC_Division('APAC - All Countries', bh.TimeZoneSidKey);
            }else if(bh.name.equals('EMEA')){
                EMEA = new DJC_Division('EMEA - All Countries', bh.TimeZoneSidKey);
            }else if(bh.name.equals('Japan')){
                JAPAN = new DJC_Division('Japan', bh.TimeZoneSidKey);
            }else if(bh.name.equals('LACA')){
                LACA = new DJC_Division('Americas - Latin America', bh.TimeZoneSidKey);
            }
            if(bh.IsDefault){
                defaultbhours = bh;
            }
        }
        
        if(AMERUSA == null){
            AMERUSA = new DJC_Division('Americas - USA', defaultbhours != null ? defaultbhours.TimeZoneSidKey : DEFAULT_TIMEZONE);
        }
        if(AMERCANADA == null){
            AMERCANADA = new DJC_Division('Americas - Canada', defaultbhours != null ? defaultbhours.TimeZoneSidKey : DEFAULT_TIMEZONE);
        }
        if(APAc == null){
            APAC = new DJC_Division('APAC - All Countries', defaultbhours != null ? defaultbhours.TimeZoneSidKey : DEFAULT_TIMEZONE);
        }
        if(EMEA == null){
            EMEA = new DJC_Division('EMEA - All Countries', defaultbhours != null ? defaultbhours.TimeZoneSidKey : DEFAULT_TIMEZONE);
        }
        if(JAPAN == null){
            JAPAN = new DJC_Division('Japan', defaultbhours != null ? defaultbhours.TimeZoneSidKey : DEFAULT_TIMEZONE);
        }
        if(LACA == null){
            LACA = new DJC_Division('Americas - Latin America', defaultbhours != null ? defaultbhours.TimeZoneSidKey : DEFAULT_TIMEZONE);
        }
    }

    public static DJC_Division getDivisionByName(String name){
        if(name != null){
            if(name.equals('Americas - USA')){
                return AMERUSA;
            }else if(name.equals('Americas - Canada')){
                return AMERCANADA;
            }else if(name.equals('APAC - All Countries')){
                return APAC;
            }else if(name.equals('EMEA - All Countries')){
                return EMEA;
            }else if(name.equals('Japan')){
                return JAPAN;
            }else if(name.equals('Americas - Latin America')){
                return LACA;
            }
        }
        return AMERUSA;
    }
    public Integer getDivTzOffsetForGMTDatetime(datetime GMTdate){
        system.debug(LOGGINGLEVEL.INFO,'GMTDate'+GMTdate);
        Timezone tz = Timezone.getTimeZone(this.timeZoneKey);
        Integer offset = tz.getoffset(GMTdate)/(60*60*1000);
        return offset;
    }
}