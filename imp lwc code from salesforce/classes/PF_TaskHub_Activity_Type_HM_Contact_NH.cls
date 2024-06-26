public class PF_TaskHub_Activity_Type_HM_Contact_NH implements PF_TaskHub_Activity_Type {
    
    public String getActivityTypeName() {
        return 'nhw-contact-new-hire-activity';
    }
    
    public String getSoBJECTName() {
        return 'Case';
    }
    
    public Set<String> getNonRequiredFields() {
        return new Set<String>{'NHW_Employee_Type__c'};
    }
    
    public Set<String> getSObjectFields() {
        return new Set<String>{'First_Name__c','NH_SLA_Due_Date__c','Last_Name__c','NH_Personal_Email__c','Status','Manager_Name__r.Name','Manager_s_Email__c','CreatedDate','NHW_Employee_Type__c'};
    }
    
    public PF_TaskHub_Activity_Object generateObject(Id id ,Map<String,Object> caseMap,Boolean IsNew) {
        PF_TaskHub_Activity_Object obj;
        obj = new PF_TaskHub_Activity_Object_Task();
        DateTime due_date = (DateTime) caseMap.get('NH_SLA_Due_Date__c');
        obj.setDue_date(due_date.format('yyyy-MM-dd\'T\'HH:mm:ss'));
        DateTime created_date = (DateTime) caseMap.get('CreatedDate');
        obj.setCreated_at(created_date.format('yyyy-MM-dd\'T\'HH:mm:ss'));
        obj.setStatus('REQUESTED');
    	obj.setAction_type('CREATE');    
        //if notification is for contractor
        //object.id is set as caseId+ActivityTypeName (smaller code = CMNHW) 
        if(caseMap.get('NHW_Employee_Type__c') == 'Contractor') {
            obj.setId(id+'-CONH');
        }
        //For FTEs set object.id - NHPersonalEmail+ManagerEmail (strip the @salesforce.com)+ActivityTypeName (smaller code = CMNHW) 
        //After WD4S pre-boarding case deprecation, refactor to use caseid for FTEs as well.
        else {
            obj.setId((String)caseMap.get('NH_Personal_Email__c')+'-'+((String)caseMap.get('Manager_s_Email__c')).substringbefore('@')+'-CONH');
		}
        
        obj.setName('Contact the New Hire');
        return obj;
    }
    
    public Object generateTarget(Id id,Map<String,Object> caseMap) {
        Object target;
        Map<String,Object> m = new Map<String,Object>();
        m.put('id','target-id-'+Math.abs(crypto.getRandomInteger()));
        m.put('type', 'target-type');
        String fName =(String) caseMap.get('First_Name__c');
        String lName =(String) caseMap.get('Last_Name__c');
        m.put('NewHireFullName',fName+' '+lName);
        m.put('NewHireFirstName',fName);
        m.put('NewHireLastName',LName);
        m.put('NewHireEmail',caseMap.get('NH_Personal_Email__c'));
        target = (Object) m;
        return target;
    }
    
 	public PF_TaskHub_Activity.Taskhub_Actor generateActor(Id id, Map<String,Object> dataMap) {
          return new PF_TaskHub_Activity.Taskhub_Actor((String)dataMap.get('Manager_s_Email__c'),'Person',(String)dataMap.get('Manager_Name__r.Name'));
    }
    
    
}