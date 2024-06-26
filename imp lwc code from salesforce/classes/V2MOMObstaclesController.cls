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

public with sharing class V2MOMObstaclesController {
    
     List<Obstacle__c>   obstacles = new List<Obstacle__c>();
     List<Value__c>      values;
     List<Method__c>     methods;
     Id              v2momId;
     Id              v2momId2;
     Id              valueId;
     Id              methodId;
     V2MOM__c            v2mom = new V2MOM__c();
     Obstacle__c         obstacle;
     obstaclePriority    newObstacle;
     boolean             isEditPage = false;
     boolean             isDeleteAllowed = false;
     boolean             isSaveAllowed = false;
     Integer             obstaclesShowing = 5;
     Integer             obstacleSize;
     User 				currentUser;
   
    
   
    public V2MOMObstaclesController(){ 
        // sets the parameter to select if the table to show is the editable one or the read-only
        String typePage = System.currentPageReference().getParameters().get('type');
        v2momId = System.currentPageReference().getParameters().get('v2momId');
        loadObstacles();
        
        if(typePage == 'edit'){
        	isSaveAllowed = true;
            isEditPage = true;
        }
    } 
    // selects the obstacles of the v2mom
    public void setV2momId(String id){
        v2momId = id;
        
        obstacles = [select Name, Id, V2MOM__r.Name, V2MOM__c, Value__r.Name, Value__c, Description__c, Method__r.Name, Method__c, Priority__c 
                  from Obstacle__c
                  where V2MOM__c =: v2momId
                  order by Priority__c];
        
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
        
        obstacleSize = obstacles.size();
                  
        List<V2MOM__c> v = [select Name, Locked__c, Id from V2MOM__c where Id =: v2momId]; 
        
        if (v.size() > 0)
            v2mom = v.get(0);
        
        if ((v2mom != null) && (v2mom.Locked__c))
            isEditPage = false;
    }


    public void loadObstacles()
    {
        obstacles = [select Name, Id, V2MOM__r.Name, V2MOM__c, Value__r.Name, Value__c, Description__c, Method__r.Name, Method__c, Priority__c 
                  from Obstacle__c
                  where V2MOM__c =: v2momId
                  order by Priority__c];
        
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
        
        obstacleSize = obstacles.size();
                  
        List<V2MOM__c> v = [select Name, Locked__c, Id from V2MOM__c where Id =: v2momId]; 
        
        if (v.size() > 0)
            v2mom = v.get(0);
        
        if ((v2mom != null) && (v2mom.Locked__c))
            isEditPage = false;
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
            max = obstacleSize;
        else
            max = obstacleSize + 1;
        
        i = max;

        if (obstacleSize == 0)
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
    
    // returns the v2mom Id
    public Id getV2momId(){ 
        return v2momId;
    }
    
    // returns the value Id
    public Id getValueId(){ 
        return valueId;
    }
    
    // returns the method Id
    public Id getMethodId(){ 
        return methodId;
    }
    
    // returns true if there is an obstacle loaded that can be deleted
    public boolean getIsDeleteAllowed(){
        return isDeleteAllowed;
    }

    // returns true if there is an obstacle loaded that can be edited or a new obstacle that can be saved
    public boolean getIsSaveAllowed(){
        return isSaveAllowed;
    }
    
    // returns true if it is in edit mode
    public boolean getIsEditPage(){
        return isEditPage;  
    }
    
    // retrieves the data of the selected obstacle
    public void loadObstacle(){
        String obstacleId = System.currentPageReference().getParameters().get('ObstacleId');
        for (Obstacle__c o : obstacles){
            if (o.Id == obstacleId){
                newObstacle = new obstaclePriority(o);
                obstacle = o;
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
    
    // returns the obstacle
    public obstaclePriority getObstacle(){
        return newObstacle;
    }
    
    // sets the obstacle
    public void setObstacle(obstaclePriority obs){
         newObstacle = obs;
    }
    
    // returns the obstacles of the v2mom
    public List<obstaclePriority> getObstacles(){
        List<obstaclePriority> showObstacles = new List<obstaclePriority>();
        Integer i = 0;
        List<Note> noteByObstacle = new List<Note>();
        List<Attachment> attachByObstacle = new List<Attachment>();
        
        if (obstacles != null){ 
        	List<Note> notes = getObstacleNotes();
        	List<Attachment> attachs = getObstacleAttach();
            while (i < obstacles.size()){
            	
            	noteByObstacle = getNoteByObstacle(notes, obstacles.get(i));
            	attachByObstacle = getAttachByObstacle(attachs, obstacles.get(i));
                showObstacles.add(new obstaclePriority(obstacles.get(i)));
                showObstacles[i].notes = noteByObstacle;
                showObstacles[i].attachs = attachByObstacle;
                
                i = i + 1;
            }
        }
        
        return showObstacles;   
    }
    
    public List<Note> getNoteByObstacle(List<Note> notes, Obstacle__c obstacle)
	{
		List<Note> notesByObstacle = new List<Note>();
		
		for (Note n: notes)
		{
			if (n.ParentId == obstacle.Id)
			{
				notesByObstacle.add(n);
			}
		}
		
		return notesByObstacle;
	}
	public List<Attachment> getAttachByObstacle(List<Attachment> attachs, Obstacle__c obstacle)
	{
		List<Attachment> attachsByObstacle = new List<Attachment>();
		
		for (Attachment a: attachs)
		{
			if (a.ParentId == obstacle.Id)
			{
				attachsByObstacle.add(a);
			}
		}
		
		return attachsByObstacle;
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
       
    // returns the number of obstacles of the v2mom
    public Integer getObstacleSize(){
        return obstacles.size();
    }
    
    // sets to show 5 more obstacles than currently showing
    public void show5More(){
        obstaclesShowing = obstaclesShowing + 5;
    }
    
    // returns true if the link to show 5 more obstacles should be shown
    public boolean getShow5MoreLink(){
        if (obstacles != null){ 
            return (obstaclesShowing + 5 < obstacles.size());
        }
        return false;   
    }
    
    // sets to show 5 less obstacles than currently showing
    public void show5Less(){
        obstaclesShowing = obstaclesShowing - 5;
    }
    
    // returns true if the link to show 5 less obstacles should be shown
    public boolean getShow5LessLink(){
        return (obstaclesShowing > 5);
    }
    
    // sets to show all obstacles
    public void showAll(){
        obstaclesShowing = (obstacles.size()/5)*5 + 5;
    }
    
    // returns true if the link to show all obstacles should be shown
    public boolean getShowAllLink(){
        if (obstacles != null){ 
            return (obstaclesShowing < obstacles.size());
        }
        return false;
    }
    
    // returns the title to show on the overlay
    public String getOverlayTitle(){
        if (isDeleteAllowed){
            return Label.Obstacle_Label + ' ' + Label.Edit_label;   
        }
        return Label.New_btn + ' ' + Label.Obstacle_Label;
    }
   
   public List<Note> getObstacleNotes(){   	
    	return [select id, ParentId from Note Where ParentId in: obstacles];       	
    }
    
    public List<Attachment> getObstacleAttach(){   	
    	return [select id, ParentId from Attachment Where ParentId in: obstacles];       	
    }         
   
    public class obstaclePriority{
        Obstacle__c obstacle;
        String priority;
        String description;
        List<Note> notes;
        List<Attachment> attachs;
        
        public obstaclePriority(Obstacle__c o){
            obstacle = o;
            priority = String.valueOf(o.Priority__c);
        }
        
        public String getPriority(){
            return priority;
        }
        
        public String getDescription()
        {
        	return obstacle.Description__c.Replace('"', ' ');
        }
        
        public void setPriority(String p){
            priority = p;
            obstacle.Priority__c = Double.valueOf(p);
        }
        
        public Obstacle__c getObstacle(){
            return obstacle;
        }
        
        public String getObstacleShortId(){
            String obstacleId = obstacle.Id;
            
            return obstacleId.subString(0, obstacleId.length() -3);
        }
        
        public boolean getHasNotesOrAttachs(){
        	if(notes.size() == 0 && attachs.size() == 0){
        		return false;
        	}
        	return true;
        }
    }
    
}