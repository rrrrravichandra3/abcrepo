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
 * @author Mike Fullmore - 4/2/2009
*/

public with sharing class V2MOMValuesController {
     
     
     List<Value__c>  values = new List<Value__c>();
     Id          v2momId;
     V2MOM__c        v2mom = new V2MOM__c();
     Value__c        value;
     valuePriority   newValue;
     boolean         isEditPage = false;
     boolean         isDeleteAllowed = false;
     boolean         isSaveAllowed = false;
     Integer         valuesShowing = 5;
     Integer         valueSize;
    
    
    public V2MOMValuesController(){ 
        // sets the parameter to select if the table to show is the editable one or the read-only
        String typePage = System.currentPageReference().getParameters().get('type');
        v2momId =  System.currentPageReference().getParameters().get('v2momId');
        if(typePage == 'edit'){
            isEditPage = true;
        }

        loadValues();
    }

    public void loadValues()
    {
         
        values = [select Name, Id, V2MOM__r.Name, V2MOM__c, Tag_Line__c, Priority__c 
                  from Value__c
                  where V2MOM__c =: v2momId
                  order by Priority__c];
    }
    // selects the values of the v2mom
    public void setV2momId(String id){
        v2momId = id;
        
        values = [select Name, Id, V2MOM__r.Name, V2MOM__c, Tag_Line__c, Priority__c 
                  from Value__c
                  where V2MOM__c =: v2momId
                  order by Priority__c];

        valueSize = values.size();
        
        List<V2MOM__c> v = [select Name, Locked__c, Id from V2MOM__c where Id =: v2momId]; 
        
        if (v.size() > 0)
            v2mom = v.get(0);
            
        if ((v2mom != null) && (v2mom.Locked__c))
            isEditPage = false;
    }
    
    // returns the v2mom Id
    public Id getV2momId(){ 
        return v2momId;
    }
        
    // returns true if there is a value loaded that can be deleted
    public boolean getIsDeleteAllowed(){
        return isDeleteAllowed;
    }

    // returns true if there is a value loaded that can be edited or a new value that can be saved
    public boolean getIsSaveAllowed(){
        return isSaveAllowed;
    }
    
    // returns true if it is in edit mode
    public boolean getIsEditPage(){
        return isEditPage;  
    }
    
    // retrieves the data of the selected value
    public void loadValue(){
        String valueId = System.currentPageReference().getParameters().get('ValueId');
        
        for (Value__c v : values){
            if (v.Id == valueId){
                newValue = new valuePriority(v);
                value = v;
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
    

    // returns the value
    public valuePriority getValuePriority(){
        return newValue;
    }
    
    // sets the value
    public void setValue(valuePriority val){
         newValue = val;
         //value.V2MOM__c = v2momId;
    }
    
    // returns the values of the v2mom
    public List<valuePriority> getValues(){
        List<valuePriority> showValues = new List<valuePriority>();
        Integer i = 0;
        List<Note> noteByValue = new List<Note>();
        List<Attachment> attachByValue = new List<Attachment>();
        
        if (values != null){   
        	
        	List<Note> notes = getValueNotes();
        	List<Attachment> attachs = getValueAttach();
        	 
            while (i < values.size()){
            	
            	noteByValue = getNoteByValue(notes, values.get(i));
            	attachByValue = getAttachByValue(attachs, values.get(i));
                showValues.add(new valuePriority(values.get(i)));
                showValues[i].notes = noteByValue;
                showValues[i].attachs = attachByValue;
                i = i + 1;
            }
        }
        
        return showValues;  
    }

	public List<Note> getNoteByValue(List<Note> notes, Value__c value)
	{
		List<Note> notesByValue = new List<Note>();
		
		for (Note n: notes)
		{
			if (n.ParentId == value.Id)
			{
				notesByValue.add(n);
			}
		}
		
		return notesByValue;
	}
	public List<Attachment> getAttachByValue(List<Attachment> attachs, Value__c value)
	{
		List<Attachment> attachsByValue = new List<Attachment>();
		
		for (Attachment a: attachs)
		{
			if (a.ParentId == value.Id)
			{
				attachsByValue.add(a);
			}
		}
		
		return attachsByValue;
	}
    // returns the priority values
     public List<SelectOption> getPrioritySelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Integer i;
        Integer max;
        
        if (v2mom == null){
            options.add(new SelectOption('1', '1 - ' + Label.Highest_Label));
            return options;
        }
        
        if (isDeleteAllowed)
            max = valueSize;
        else
            max = valueSize + 1;
        
        i = max;

        if (valueSize == 0)
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
    
    // returns the v2mom
    public V2MOM__c getV2mom(){
        return v2mom;  
    }
    
    public void setV2MOM(V2MOM__c v){
        v2mom = v;
    }
    
    // returns the name of the v2mom
    public String getV2MOMName(){
        if (v2mom != null)
            return v2mom.Name;  
        return '';
    }
    
    public boolean getShowError(){
        return false;
    }
    
    public String getMsgError(){
        return 'error';
    }         
    // returns the number of values of the v2mom
    public Integer getValueSize(){
        return values.size();
    }
    
    // sets to show 5 more values than currently showing
    public void show5More(){
        valuesShowing = valuesShowing + 5;
    }
    
    // returns true if the link to show 5 more values should be shown
    public boolean getShow5MoreLink(){
        if (values != null){    
            return (valuesShowing + 5 < values.size());
        }
        return false;
    }
    
    // sets to show 5 less values than currently showing
    public void show5Less(){
        valuesShowing = valuesShowing - 5;
    }
    
    // returns true if the link to show 5 less values should be shown
    public boolean getShow5LessLink(){
        return (valuesShowing > 5);
    }
    
    // sets to show all values
    public void showAll(){
        valuesShowing = (values.size()/5)*5 + 5;
    }
    
    // returns true if the link to show all values should be shown
    public boolean getShowAllLink(){
        if (values != null){    
            return (valuesShowing < values.size());
        }
        return false;
    }
    
    // returns the title to show on the overlay
    public String getOverlayTitle(){
        if (isDeleteAllowed){
            return Label.Value_Label + ' ' + Label.Edit_label;  
        } 
        return Label.New_btn + ' ' + Label.Value_Label;
    }

    public PageReference cancel(){
        return null;
    }
    
    public List<Note> getValueNotes(){   	
    	return [select id, ParentId from Note Where ParentId in: values];       	
    }
    
    public List<Attachment> getValueAttach(){   	
    	return [select id, ParentId from Attachment Where ParentId in: values];       	
    }
        

    public class valuePriority{
        Value__c value;
        String priority;
        String description;
        List<Note> notes;
        List<Attachment> attachs;
        
        public valuePriority(Value__c v){
            value = v;
            priority = String.valueOf(v.Priority__c);
        }
        
        public String getPriority(){
            return priority;
        }
        
        public void setPriority(String p){
            priority = p;
            value.Priority__c = Double.valueOf(p);
        }
        
        public Value__c getValue(){
            return value;
        }
        
        public String getValueShortId(){
            String valueId = value.Id;
            
            return valueId.subString(0, valueId.length() -3);
        }
        
       
        public boolean getHasNotesOrAttachs(){
        	if(notes.size() == 0 && attachs.size() == 0){
        		return false;
        	}
        	return true;
        }
    }
    
}