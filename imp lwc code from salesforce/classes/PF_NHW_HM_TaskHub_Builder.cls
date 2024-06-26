@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public class PF_NHW_HM_TaskHub_Builder implements PF_TaskHub_Builder {
    
    public void buildOrigin(PF_TaskHub_Activity activity,PF_TaskHub_Activity.Taskhub_Origin origin) {
        activity.setOrigin(origin);
    }
    
    public void buildActor(PF_TaskHub_Activity activity,PF_TaskHub_Activity.Taskhub_Actor actor) {
        activity.setActor(actor);
    }
    
    public void buildObject(PF_TaskHub_Activity activity,PF_TaskHub_Activity_Object obj) {
        activity.setObj(obj);
    }
    
    public void buildTarget(PF_TaskHub_Activity activity,Object target) {
        activity.setTarget(target);
    }
    
    
    //this method builds and returns list of Taskhub_Activity
    public List<PF_Taskhub_Activity> build(String sys,List<Slack_Taskhub_Notification__e> evts, PF_TaskHub_Activity_Type activityType) {
        List<PF_Taskhub_Activity> activities = new List<PF_Taskhub_Activity>();
        
        //build Case Id to Event Map
        Map<Id,Slack_Taskhub_Notification__e> caseIdToEventMap = new Map<Id,Slack_Taskhub_Notification__e>();
        for(Slack_Taskhub_Notification__e evt:evts) {
            caseIdToEventMap.put(evt.Id__c,evt);
        }
        
        List<Id> ids = new List<Id>(caseIdToEventMap.keySet());
        String query = buildQuery(activityType);
        List<Case> NHWCases = Database.query(query);
        if(NHWCases != null && NHWCases.size()>0) {
            Map<Id,Map<String,Object>> caseDataMap = builDataMapUtil(NHWCases,activityType);
            for(ID id:caseDataMap.keySet()) {
                PF_Taskhub_Activity activity = new PF_TaskHub_Activity();
                activity.setId(String.valueOf(Math.abs(crypto.getRandomInteger())));
                activity.setCreated_at(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
                activity.setType(activityType.getActivityTypeName());
                buildOrigin(activity,new PF_TaskHub_Activity.Taskhub_Origin(sys,'System',sys+' Tasks'));
                buildActor(activity,activityType.generateActor(id,caseDataMap.get(id)));
                buildObject(activity,activityType.generateObject(id,caseDataMap.get(id),caseIdToEventMap.get(id).IsComplete__c));
                buildTarget(activity,activityType.generateTarget(id,caseDataMap.get(id)));
                activities.add(activity);
            }
        }        
        return activities;
    }
    
    public Map<Id,Map<String,Object>> builDataMapUtil(List<Case> NHWCases,PF_TaskHub_Activity_Type activityType) {
        Map<Id,Map<String,Object>> caseDataMap = new Map<Id,Map<String,Object>>();
        for(Case c:NHWCases) {
            Map<String,Object> m= new Map<String,Object>();
            for(String fieldName : activityType.getSObjectFields()) {
                String[] fieldsChain = fieldName.split('\\.');
                Object value = null;
                SObject o = c;
                for(Integer i = 0; i < fieldsChain.size() - 1; i++){
                    o = o.getSobject(fieldsChain[i]);
                    if(o == null){
                        break;
                    }
                }
                if(o != null){
                    value = o.get(fieldsChain[fieldsChain.size() - 1]);
                }
                if(value!=null || activityType.getNonRequiredFields().contains(fieldName)) {
                    m.put(fieldName,value);
                } else {
                    //if any of the required field is null
                    //return empty map so no payload is created and request to taskhub is not sent
                    System.debug('ERROR: Required field missing from case: '+fieldName);
                    return new Map<Id,Map<String,Object>>();
                }
            }
            caseDataMap.put(c.id,m);
        }
        return caseDataMap;
    }
    
    public String buildQuery(PF_TaskHub_Activity_Type activityType) {
        String query = 'Select ';
        for(String fieldName:activityType.getSObjectFields()) {
            query += fieldName + ',';
        }
        query = query.removeEnd(',');
        query += ' From ' + activityType.getSObjectName() + ' Where Id IN:ids';
        return query;
        
    }
    
}