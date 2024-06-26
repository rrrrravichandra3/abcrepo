/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author - 4/2/2009
*/

public with sharing class V2MOMMetricsController {

    
     Id              v2momId;
     Id              v2momId2;
     Id              valueId;
     Id              methodId;
     transient List<Measure__c>    metrics;
     transient List<Value__c>      values;
     transient List<Method__c>     methods;
     V2MOM__c            v2mom = new V2MOM__c();
     boolean             isEditPage = false;
     boolean             isDeleteAllowed = false;
     boolean             isSaveAllowed = false;
     Measure__c          newMetric = new Measure__c();
     MeasureDate         metric;
     Integer             metricsShowing = 5;
     Integer             metricSize;
     String              prioritiesToUpdate;

    public V2MOMMetricsController(){
        // sets the parameter to select if the table to show is the editable one or the read-only
        String typePage = System.currentPageReference().getParameters().get('type');
        v2momId = System.currentPageReference().getParameters().get('v2momId');
        if(typePage == 'edit'){
        	isSaveAllowed = true;
            isEditPage = true;
        }
        loadMetrics();
    } 
    public String getPriorities()
    {
        return prioritiesToUpdate;
    }
    
    public void setPriorities(String priorities)
    {
        prioritiesToUpdate = priorities;
    }
    
    // returns true if it is in edit mode
    public boolean getIsEditPage(){
        return isEditPage;  
    }
    
   
    // selects the metrics of the v2mom
    public void setV2momId(String v2momp){
        v2momId = v2momp;
        
        metrics = [select Id, V2MOM__c, Value__r.Name, Value__c, Method__r.Name, Method__c, Priority__c, 
                    Name, Description__c, Start_Date__c, End_Date__c
                    from Measure__c 
                    where V2MOM__c =: v2momId order by Priority__c];

        metricSize = metrics.size();
        
        values = [select Name, Id, V2MOM__r.Name, V2MOM__c, Tag_Line__c, Priority__c 
                  from Value__c
                  where V2MOM__c =: v2momId
                  order by Priority__c];
        
        if ((valueId == null) || (valueId == '')) {
            methods = [select Id, V2MOM__c, Value__r.Name, Value__c, Priority__c, 
                        Name, Description__c, Accountable_Person__c, Accountable_Person__r.Name
                        from Method__c 
                        where V2MOM__c =: v2momId order by Priority__c];
        } else {
            methods = [select Id, V2MOM__c, Value__r.Name, Value__c, Priority__c, 
                        Name, Description__c, Accountable_Person__c, Accountable_Person__r.Name
                        from Method__c 
                        where V2MOM__c =: v2momId and Value__c =: valueId order by Priority__c];
        }
        
        List<V2MOM__c> v = [select Name, Locked__c, Id from V2MOM__c where Id =: v2momId]; 
        
        if (v.size() > 0)
            v2mom = v.get(0);
        
        if ((v2mom != null) && (v2mom.Locked__c))
            isEditPage = false;
    }

    public void loadMetrics()
    {
        metrics = [select Id, V2MOM__c, Value__r.Name, Value__c, Method__r.Name, Method__c, Priority__c, 
                    Name, Description__c, Start_Date__c, End_Date__c
                    from Measure__c 
                    where V2MOM__c =: v2momId order by Priority__c];

        metricSize = metrics.size();
        
        values = [select Name, Id, V2MOM__r.Name, V2MOM__c, Tag_Line__c, Priority__c 
                  from Value__c
                  where V2MOM__c =: v2momId
                  order by Priority__c];
        
        if ((valueId == null) || (valueId == '')) {
            methods = [select Id, V2MOM__c, Value__r.Name, Value__c, Priority__c, 
                        Name, Description__c, Accountable_Person__c, Accountable_Person__r.Name
                        from Method__c 
                        where V2MOM__c =: v2momId order by Priority__c];
        } else {
            methods = [select Id, V2MOM__c, Value__r.Name, Value__c, Priority__c, 
                        Name, Description__c, Accountable_Person__c, Accountable_Person__r.Name
                        from Method__c 
                        where V2MOM__c =: v2momId and Value__c =: valueId order by Priority__c];
        }
        
    }
    // returns the values of the v2mom
     public List<SelectOption> getValueSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','- ' + Label.No_Value_Label + ' -'));
        
        if (values.size() > 0) {
            for (Value__c v : values){
                options.add(new SelectOption(v.Id,v.Name));
            }
        }else{
            options.add(new SelectOption('','- ' + Label.No_Values_Available_Label + ' -'));
        }

        return options;
     }

    // returns the methods of the v2mom
     public List<SelectOption> getMethodSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','- ' + Label.No_Method_Label + ' -'));
        
        if (methods.size() > 0) {
            for (Method__c m : methods){
                options.add(new SelectOption(m.Id,m.Name));
            }
        }else{
            options.add(new SelectOption('','- ' + Label.No_Methods_Available_Label + ' -'));
        }
        
        return options;
     }

    // returns the priority values 
     public List<SelectOption> getPrioritySelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Integer i;
        Integer max;
        
        if (isDeleteAllowed)
            max = metricSize;
        else
            max = metricSize + 1;
        
        i = max;

        if (metricSize == 0)
            options.add(new SelectOption('1', '1 - ' + Label.Highest_Label));
        else{
            while (i > 0){
                if (i == 1){
                    options.add(new SelectOption('1', '1 - ' + Label.Highest_Label));
                }else{
                    if (i == max){
                        options.add(new SelectOption(String.valueOf(i), String.valueOf(i) + ' - ' + Label.Lowest_Label));
                    }else{
                        options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
                    }
                }
                i = i - 1;
            }
        }
        return options;
     }
    
    // retrieves the data of the selected metric
    public void loadMetric(){
        String metricId = System.currentPageReference().getParameters().get('metricId');
        for (Measure__c m : metrics){
            if (m.Id == metricId){
                newMetric = m;
                metric = new MeasureDate(newMetric);
            }
        }
        
        if ((v2mom != null) && (!v2mom.Locked__c)){
            isDeleteAllowed = true;
            isSaveAllowed = true;
        }else{
            isDeleteAllowed = false;
            isSaveAllowed = false;
        }
    }

    // returns the v2mom Id
    public Id getV2momId(){
        return v2momId;
    }
    
    public void setV2MOM(V2MOM__c v){
        v2mom = v;
    }

    // returns the metrics of the v2mom
    public List<measureDate> getMetrics(){
        List<measureDate> showMetrics = new List<measureDate>();
        Integer i = 0;
        List<Note> noteByMetric = new List<Note>();
        List<Attachment> attachByMetric = new List<Attachment>();
        
        if (metrics != null){   
            List<Note> notes = getMetricNotes();
    		List<Attachment> attachs = getMetricAttach();
            while (i < metrics.size()){
            	noteByMetric = getNoteByMetric(notes, metrics.get(i));
            	attachByMetric = getAttachByMetric(attachs, metrics.get(i));
                showMetrics.add(new measureDate(metrics.get(i)));
                showMetrics[i].notes = noteByMetric;
                showMetrics[i].attachs = attachByMetric;
                i = i + 1;
            }
        }
        
        return showMetrics; 
    }
    
    public List<Note> getNoteByMetric(List<Note> notes, Measure__c metric)
	{
		List<Note> notesByMetric = new List<Note>();
		
		for (Note n: notes)
		{
			if (n.ParentId == metric.Id)
			{
				notesByMetric.add(n);
			}
		}
		
		return notesByMetric;
	}
	public List<Attachment> getAttachByMetric(List<Attachment> attachs, Measure__c metric)
	{
		List<Attachment> attachsByMetric = new List<Attachment>();
		
		for (Attachment a: attachs)
		{
			if (a.ParentId == metric.Id)
			{
				attachsByMetric.add(a);
			}
		}
		
		return attachsByMetric;
	}
    
    // returns the metric
    public MeasureDate getMetric(){
        return metric;
    }
    
    // sets the metric
    public void setMetric(MeasureDate m){
        metric = m;
        //newMetric.V2MOM__c = v2momId;
    }

    // returns the metric
    public Measure__c getNewMetric(){
        return newMetric;
    }
    
    // sets the metric
    public void setNewMetric(Measure__c m){
        newMetric = m;
        //newMetric.V2MOM__c = v2momId;
    }

    // returns the name of the v2mom
    public String getV2MOMName(){
        if (v2mom != null)
            return v2mom.Name;  
        return '';
    }
    
    // returns the value Id
    public Id getValueId(){ 
        return valueId;
    }
    
    // returns the method Id
    public Id getMethodId(){ 
        return methodId;
    }

    // returns true if there is a metric loaded that can be deleted
    public boolean getIsDeleteAllowed(){
        return isDeleteAllowed;
    }

    // returns true if there is a metric loaded that can be edited or a new metric that can be saved
    public boolean getIsSaveAllowed(){
        return isSaveAllowed;
    }
    
    // returns the number of metrics of the v2mom
    public Integer getMetricSize(){
        return metrics.size();
    }
    
    // sets to show 5 more metrics than currently showing
    public void show5More(){
        metricsShowing = metricsShowing + 5;
    }
    
    // returns true if the link to show 5 more metrics should be shown
    public boolean getShow5MoreLink(){
        if (metrics != null){   
            return (metricsShowing + 5 < metrics.size());
        }
        return false;
    }
    
    // sets to show 5 less metrics than currently showing
    public void show5Less(){
        metricsShowing = metricsShowing - 5;
    }
    
    // returns true if the link to show 5 less metrics should be shown
    public boolean getShow5LessLink(){
        return (metricsShowing > 5);
    }
    
    // sets to show all metrics
    public void showAll(){
        metricsShowing = (metrics.size()/5)*5 + 5;
    }
    
    // returns true if the link to show all metrics should be shown
    public boolean getShowAllLink(){
        if (metrics != null){   
            return (metricsShowing < metrics.size());
        }
        return false;
    }
    
    // returns the title to show on the overlay
    public String getOverlayTitle(){
        if (isDeleteAllowed){
            return Label.Metric_Label + ' ' + Label.Edit_label;
        }
        return Label.New_btn + ' ' + Label.Metric_Label;
    }
    
    public List<Note> getMetricNotes(){   	
    	return [select id, ParentId from Note Where ParentId in: metrics];       	
    }
    
    public List<Attachment> getMetricAttach(){   	
    	return [select id, ParentId from Attachment Where ParentId in: metrics];       	
    }
    
    public String getDateToday(){
    	String dateString = String.valueOf(Datetime.now().format('MM/dd/yyyy'));   	
    	return dateString;
    }
    
    public class measureDate{
        Measure__c metric;
        String startDate;
        String endDate;
        String priority;
        String description;
        List<Note> notes;
        List<Attachment> attachs;
        
        public measureDate(Measure__c m){
            metric = m;
            if (m.Start_Date__c != null)
                startDate = m.Start_Date__c.format();
            if (m.End_Date__c != null)
                endDate = m.End_Date__c.format();
            priority = String.valueOf(m.Priority__c);
        }
        
        public String getPriority(){
            return priority;
        }
        
        public String getDescription()
        {
        	return metric.Description__c.Replace('"', ' ');
        }
        public void setPriority(String p){
            priority = p;
            metric.Priority__c = Double.valueOf(p);
        }
        
        public Measure__c getMetric(){
            return metric;
        }
        
        public String getStartDate(){
            return startDate;
        }

        public String getEndDate(){
            return endDate;
        }
        
        public void setStartDate(Date d){
            metric.Start_Date__c = d;
            startDate = metric.Start_Date__c.format();
        }

        public void setEndDate(Date d){
            metric.End_Date__c = d;
            endDate = metric.End_Date__c.format();
        }
        
        public String getMetricShortId(){
            String metricId = metric.Id;
            
            return metricId.subString(0, metricId.length() -3);
        }
        
        public boolean getHasNotesOrAttachs(){
        	if(notes.size() == 0 && attachs.size() == 0){
        		return false;
        	}
        	return true;
        }
            
    }

}