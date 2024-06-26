public class PF_NHW_StartEndDateConfigurator implements PF_NHW_LightningComponentConfigurator{

    
    public List<PF_NHW_LightningComponentAttribute> getComponentConfiguration(Case c){

        String dateFormat = 'yyyy-MM-dd';
        
        String startDateMin, startDateMax, endDateMin, endDateMax;
        
        Date d = Date.today();
        if(String.isBlank(c.NHW_Employee_Type__c) || c.NHW_Employee_Type__c.containsIgnorecase('Regular Employee')){
            d = d.addDays(1);
        }else{
            d = d.addDays(-90);
        }
        
        startDateMin = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);        
        d = d.addDays(1);
        endDateMin = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);
        d = d.addDays(-2);
        d = d.addYears(1);
        startDateMax = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);
        d = d.addYears(1);
        endDateMax = DateTime.newInstance(d.year(), d.month(), d.day()).format(dateFormat);
        
        return new List<PF_NHW_LightningComponentAttribute>{
            new PF_NHW_LightningComponentAttribute('SDMIN', startDateMin),
                new PF_NHW_LightningComponentAttribute('SDMAX', startDateMax),
                new PF_NHW_LightningComponentAttribute('EDMIN', endDateMin),
                new PF_NHW_LightningComponentAttribute('EDMAX', endDateMax)
                };
                    }
}