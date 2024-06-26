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
 * @author  - 4/2/2009
*/

public with sharing class V2MOMMethodsController {
     String 		 fromPage{get;set;}
     Id          v2momId;
     Id          v2momId2;
     Id          valueId;
     List<Value__c>  values;
     List<Method__c> methods;
     V2MOM__c        v2mom = new V2MOM__c();
     boolean         isEditPage = false;
     boolean         isDeleteAllowed = false;
     boolean         isSaveAllowed = false;
     Method__c       method;
     methodPriority  newMethod;
     Integer         methodsShowing = 5;
     Integer         methodSize;
	 User 			currentUser;
	 Id 			staticId;
	 
    
    public V2MOMMethodsController(){
        // sets the parameter to select if the table to show is the editable one or the read-only
        currentUser = [Select Id, Profile.Name from User Where Id =: userInfo.getUserId()]; 
        String typePage = System.currentPageReference().getParameters().get('type');
        v2momId = System.currentPageReference().getParameters().get('v2momId');
        
       transient List<StaticResource> staticResource = [Select Id From StaticResource s Where Name = 'PeopleForceResources' limit 1];
        
        if (staticResource.size() != 0)
        {
        	staticId = staticResource[0].Id;
        }
        
        
        loadMethods();
        
        if(typePage == 'edit'){
            isEditPage = true;
            isSaveAllowed = true;
        }
    }
    // returns true if it is in edit mode
    public boolean getIsEditPage(){
        return isEditPage;  
    }
   
	public Boolean getIsSysAdmin()
	{
		return (currentUser.Profile.Name == 'System Administrator' || currentUser.Profile.Name == 'systemadministrator');
	}
    // selects the methods of the v2mom
    public void setV2momId(String v2momp){
        v2momId = v2momp;
        
        methods = [select Id, V2MOM__c, Value__r.Name, Value__c, Priority__c, Weight__c,
                    Name, Color__c, Description__c, Accountable_Person__c, Accountable_Person__r.Name
                    from Method__c 
                    where V2MOM__c =: v2momId order by Priority__c];
        
        values = [select Name, Id, V2MOM__r.Name, V2MOM__c, Tag_Line__c, Priority__c 
                  from Value__c
                  where V2MOM__c =: v2momId
                  order by Priority__c];

        methodSize = methods.size();
        
        transient List<V2MOM__c> v = [select Name, Locked__c, OwnerId, Id from V2MOM__c where Id =: v2momId]; 
        
        if (v.size() > 0)
            v2mom = v.get(0);
        
        if ((v2mom != null) && (v2mom.Locked__c))
            isEditPage = false;
    }
    
    public void  loadMethods()
    {
        
        methods = [select Id, V2MOM__c, Value__r.Name, Value__c, Priority__c, Weight__c,
                    Name, Description__c, Color__c, Accountable_Person__c, Accountable_Person__r.Name
                    from Method__c 
                    where V2MOM__c =: v2momId order by Priority__c];
        
        values = [select Name, Id, V2MOM__r.Name, V2MOM__c, Tag_Line__c, Priority__c 
                  from Value__c
                  where V2MOM__c =: v2momId
                  order by Priority__c];

        methodSize = methods.size();
        
        List<V2MOM__c> v = [select Name, Locked__c, Id from V2MOM__c where Id =: v2momId]; 
        
        if (v.size() > 0)
            v2mom = v.get(0);
        
        if ((v2mom != null) && (v2mom.Locked__c)) 
            isEditPage = false;
    }
    
    // retrieves the data of the selected method
    public void loadMethod(){
        Id methodId = System.currentPageReference().getParameters().get('methodId');
        for (Method__c m : methods){
            if (m.Id == methodId){
                newMethod = new methodPriority(m);
                method = m;
            }
        }
        
        if ((v2mom != null) && (!v2mom.Locked__c)){
            isDeleteAllowed = true;
            isSaveAllowed = true;
        }else{
            if (currentUser.Profile.Name == 'System Administrator' || currentUser.Profile.Name == 'systemadministrator')
            {
	            isDeleteAllowed = true;
	            isSaveAllowed = true;
            }
            else
            {
            	isDeleteAllowed = false;
	            isSaveAllowed = false;	
            }
        }
    }

    // returns the values of the v2mom
     public List<SelectOption> getValueSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','- ' + Label.No_Value_Label + ' -'));
        
        if (values.size() > 0){
            for (Value__c v : values){
                options.add(new SelectOption(v.Id,v.Name));
            }
        }else{
            options.add(new SelectOption('','- ' + Label.No_Values_Available_Label + ' -'));
        }

        return options;
     }
    
    // returns the priority values
     public List<SelectOption> getPrioritySelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Integer i;
        Integer max;
        
        if (isDeleteAllowed)
            max = methodSize;
        else
            max = methodSize + 1;
        
        i = max;

        if (methodSize == 0)
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
    
    public boolean getIsSysAdminOrManager()
    {
    	
    	if (v2mom.Id != null)
    	{
    	if (currentUser.Profile.Name == 'System Administrator' || currentUser.Profile.Name == 'systemadministrator')
    	{
    		return true;
    	}
    	
    	User employee = [Select Id, Manager__c From User Where Id =: v2mom.OwnerId];
    	
    	if (employee.Manager__c != null)
    	{
    		User manager = [Select Id From User Where Id =: employee.Manager__c];

	    	if (userInfo.getUserId() == manager.Id)
	    	{
	    		return true;	
	    	}
    	}
    	
	    	return false;
    	}
    	return false;
    }
    // returns the v2mom Id
    public Id getV2momId(){
        return v2momId;
    }
    
    // returns the value Id
    public id getValueId(){ 
        return valueId;
    }
    
    public void setV2MOM(V2MOM__c v){
        v2mom = v;
    }

    // returns the methods of the v2mom
    public List<methodPriority> getMethods(){
        List<methodPriority> showMethods = new List<methodPriority>();
        Integer i = 0;
        List<Note> noteByMethod = new List<Note>();
        List<Attachment> attachByMethod = new List<Attachment>();
        
        if (methods != null){   
            List<Note> notes = getMethodNotes();
    		List<Attachment> attachs = getMethodAttach();
            while (i < methods.size()){
            	
        		noteByMethod = getNoteByMethod(notes, methods.get(i));
            	attachByMethod = getAttachByMethod(attachs, methods.get(i));
                showMethods.add(new methodPriority(methods.get(i)));
                showMethods[i].notes = noteByMethod;
                showMethods[i].attachs = attachByMethod;
                i = i + 1;
            }
        }
        
        return showMethods; 
    }
    
    public List<Note> getNoteByMethod(List<Note> notes, Method__c method)
	{
		List<Note> notesByMethod = new List<Note>();
		
		for (Note n: notes)
		{
			if (n.ParentId == method.Id)
			{
				notesByMethod.add(n);
			}
		}
		
		return notesByMethod;
	}
	public List<Attachment> getAttachByMethod(List<Attachment> attachs, Method__c method)
	{
		List<Attachment> attachsByMethod = new List<Attachment>();
		
		for (Attachment a: attachs)
		{
			if (a.ParentId == method.Id)
			{
				attachsByMethod.add(a);
			}
		}
		
		return attachsByMethod;
	}

    // returns all the methods of the v2mom
    public List<Method__c> getAllMethods(){
        return methods; 
    }
    
    // returns the method
    public methodPriority getNewMethod(){
        return newMethod;
    }
    
    // sets the method
    public void setNewMethod(methodPriority m){
        newMethod = m;
        //newMethod.V2MOM__c = v2momId;
    }

    // returns the name of the v2mom
    public String getV2MOMName(){
        if (v2mom != null)
            return v2mom.Name;  
        return '';
    }

    // returns true if there is a method loaded that can be deleted
    public boolean getIsDeleteAllowed(){
        return isDeleteAllowed;
    }

    // returns true if there is a method loaded that can be edited or a new method that can be saved
    public boolean getIsSaveAllowed(){
        return isSaveAllowed;
    }
        
    // returns the number of methods of the v2mom
    public Integer getMethodSize(){
        return methods.size();
    }
    
    // sets to show 5 more methods than currently showing
    public void show5More(){
        methodsShowing = methodsShowing + 5;
    }
    
    // returns true if the link to show 5 more methods should be shown
    public boolean getShow5MoreLink(){
        if (methods != null){   
            return (methodsShowing + 5 < methods.size());
        }
        return false;
    }
    
    // sets to show 5 less methods than currently showing
    public void show5Less(){
        methodsShowing = methodsShowing - 5;
    }
    
    // returns true if the link to show 5 less methods should be shown
    public boolean getShow5LessLink(){
        return (methodsShowing > 5);
    }
    
    // sets to show all methods
    public void showAll(){
        methodsShowing = (methods.size()/5)*5 + 5;
    }
    
    // returns true if the link to show all methods should be shown
    public boolean getShowAllLink(){
        if (methods != null){   
            return (methodsShowing < methods.size());
        }
        return false;
    }
    
    // returns the title to show on the overlay
    public String getOverlayTitle(){
        if (isDeleteAllowed){
            return Label.Method_Label + ' ' + Label.Edit_label;
        }
        return Label.New_btn + ' ' + Label.Method_Label;
    }
    
    public List<Note> getMethodNotes(){   	
    	return [select id, ParentId from Note Where ParentId in: methods];       	
    }
    
    public List<Attachment> getMethodAttach(){   	
    	return [select id, ParentId from Attachment Where ParentId in: methods];       	
    }    
    
    public String getGreenColor()
    {
    	
    	return '/images/buttons/1268248229_Circle_Green.png';
    }
    
    public String getGreenColorOFF()
    {
    	
    	return '/images/buttons/1268248229_Circle_Green_OFF.png';
    }
    
    public String getRedColor()
    {
    	
    	return '/images/buttons/1268248235_Circle_Red.png';
    }
    
    public String getRedColorOFF()
    {
    	
    	return '/images/buttons/1268248235_Circle_Red_OFF.png';
    }
    
    public String getYellowColor()
    {
    	return '/images/buttons/1268248232_Circle_Yellow.png';
    }
    
   	public String getYellowColorOFF()
    {
    	return '/images/buttons/1268248232_Circle_Yellow_OFF.png';
    }
    
    public class methodPriority{
        Method__c method;
        String priority;
        String description;
        List<Note> notes;
        List<Attachment> attachs;
        
        public methodPriority(Method__c m){
            method = m;
            priority = String.valueOf(m.Priority__c);
        }
        
        public String getPriority(){
            return priority;
        }
        
        public String getDescription()
        {
        	return method.Description__c.Replace('"', ' ');
        }
        public void setPriority(String p){
            priority = p;
            method.Priority__c = Double.valueOf(p);
        }
        
        public Method__c getMethod(){
            return method;
        }
        
        public String getMethodShortId(){
            String methodId = method.Id;
            
            return methodId.subString(0, methodId.length() -3);
        }
        
        public boolean getHasNotesOrAttachs(){
        	if(notes.size() == 0 && attachs.size() == 0){
        		return false;
        	}
        	return true;
        }
    }
    
}