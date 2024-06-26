@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public class SEF_Ext_NHW_HM_TaskHub_Builder extends SEF_Ext_ActivityStream_Builder {
    
    public override List<SEF_ActivityStream> build(List<SEF_Ext_Service_Input> sefInput) {
        List<SEF_ActivityStream> activities = new List<SEF_ActivityStream>();        
        Map<Id,SEF_Ext_Service_Input> mapIdToInput = new Map<Id,SEF_Ext_Service_Input>(); 
        
        for(SEF_Ext_Service_Input i: sefInput) {
            mapIdToInput.put(i.sObjId,i);
        }
        
        try {
            
            List<Case> nhwCases =(List<Case>) queryRecords(mapIdtoInput.keySet());
            
            for(Case c:nhwCases) {
                
                Map<String,Object> dataMap = c.getPopulatedFieldsAsMap().clone();
                datamap.put('IsCompleted', mapIdToInput.get(c.id).IsComplete);
                SEF_Actor actor = activityType.generateActor(dataMap);
                SEF_ActivityObject activityObject = activityType.generateObject(dataMap);     
                SEF_ActivityStream.Builder builderObject = new SEF_ActivityStream.Builder(activityType.getActivityTypeName(),
                                                                                          actor,activityObject).metadata(activityType.generateTarget(dataMap));
                
                activities.add(builderObject.build());  
            }
        } catch(Exception e) {
            System.debug('SEF_Ext_NHW_HM_Taskhub_Builder -  Exception while building SEF_Activity \n'+e.getMessage()+e.getTypeName()+e.getLineNumber());
        }
        return activities;
    }
    
}