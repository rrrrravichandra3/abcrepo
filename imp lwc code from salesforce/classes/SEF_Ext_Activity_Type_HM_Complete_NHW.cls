public class SEF_Ext_Activity_Type_HM_Complete_NHW implements SEF_Ext_Activity_Type {
    
    static final Id ProvisioningCaseRecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
    
    public String getActivityTypeName() {
        return 'nhw-complete-new-hire-wizard-activity';
    }
    
    public String getSobjectName() {
        return 'Case';
    }
     
	public Set<String> getFieldList() {
        return new Set<String>{'First_Name__c','NH_SLA_Due_Date__c','Last_Name__c','NH_Personal_Email__c','Status','Manager_Name__r.Name','Manager_s_Email__c','CreatedDate','recordtypeid','NHW_Employee_Type__c'};
    }
    
    public SEF_ActivityObject generateObject(Map<String,Object> dataMap) {
        map<string,object> mActivityObj = new map<string, object>();
        DateTime due_date = (DateTime) dataMap.get('NH_SLA_Due_Date__c');
        mActivityObj.put('due_date',due_date.format('yyyy-MM-dd\'T\'HH:mm:ss'));
        DateTime created_date = (DateTime) dataMap.get('CreatedDate');
        mActivityObj.put('created_at',created_date.format('yyyy-MM-dd\'T\'HH:mm:ss'));
        mActivityObj.put('status','REQUESTED');
        mActivityObj.put('action_type','CREATE');
        mActivityObj.put('type','Task');
        //if notification is for contractor
        //object.id is set as caseId+ActivityTypeName (smaller code = CMNHW) 
        if(dataMap.get('RecordTypeId') == ProvisioningCaseRecordTypeId && dataMap.get('NHW_Employee_Type__c') == 'Contractor') {
                mActivityObj.put('id',dataMap.get('Id')+'-CMNHW');       
        }
        //For FTEs set object.id - NHPersonalEmail+ManagerEmail (strip the @salesforce.com)+ActivityTypeName (smaller code = CMNHW) 
	    //For contractors - Just use CaseId
        //After WD4S pre-boarding case deprecation, refactor to use caseid for FTEs as well.
        else {
            mActivityObj.put('id',(String)dataMap.get('NH_Personal_Email__c')+'-'+((String)dataMap.get('Manager_s_Email__c')).substringbefore('@')+'-CMNHW');
		}
        
        //Auto Mark as Complete
        if((Boolean)dataMap.get('IsCompleted')) {
        	mActivityObj.put('status','COMPLETED');
            mActivityObj.put('action_type','UPDATE');
        }
        
        
        mActivityObj.put('name','Complete the New Hire Wizard');
        return new SEF_TaskHubObject(mActivityObj);
    }
    
    public Map<String,Object> generateTarget(Map<String,Object> dataMap) {
        Map<String,Object> m = new Map<String,Object>();
        m.put('id','target-id-'+Math.abs(crypto.getRandomInteger()));
        m.put('type', 'target-type');
        String fName =(String) dataMap.get('First_Name__c');
        String lName =(String) dataMap.get('Last_Name__c');
        m.put('NewHireFullName',fName+' '+lName);
        m.put('NewHireFirstName',fName);
        m.put('NewHireLastName',LName);
        m.put('NewHireEmail',dataMap.get('NH_Personal_Email__c'));
        return m;
    }
    
    public SEF_Actor generateActor(Map<String,Object> dataMap) {
        Map<string,object> mSEFActorData = new map<string, object>();
        mSEFActorData.put('id',dataMap.get('Manager_s_Email__c'));
        mSEFActorData.put('type','Person');
        mSEFActorData.put('name',((Contact)dataMap.get('Manager_Name__r')).Name);
        return new SEF_Actor(mSEFActorData);
    }
    
}