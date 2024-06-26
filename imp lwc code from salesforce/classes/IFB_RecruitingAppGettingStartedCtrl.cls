public class IFB_RecruitingAppGettingStartedCtrl {
    public  IFB_RecruitingAppGettingStartedCtrl(){

    }
    
    private Integer RecruitingScoringCount = 0;
    private Integer InterviewQuestionCategoryMapCount = 0;
    private Integer InterviewQuestionCount = 0;
                                           
    public PageReference generateData(){
        String msg = 'Following Records were generated successfully:<br/>';
        msg += 'IFB_Recruiting_Scoring__c:' + RecruitingScoringCount + '<br/>';
        msg += 'InterviewQuestionCategoryMapCount:' + InterviewQuestionCategoryMapCount + '<br/>';
        msg += 'InterviewQuestionCount:' + InterviewQuestionCount + '<br/>';        
        ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO, msg);
        ApexPages.addMessage(infoMsg);
        return null;
    }

    private Integer loadSObjectDataFromCSV(String ObjectName, String StaticResourceName){
        

        StaticResource pascoring = [Select  s.Body From StaticResource s where s.Name =: StaticResourceName];
        blob tempB = pascoring.Body;
        List<List<String>> fileValues = IFB_CSVReader.readIETFRFC4180CSVFile(tempB);
        String contentFile = tempB.toString();
        String[] filelines = contentFile.split('\n');
        system.debug('FILE LINES SIZE::' + filelines.size());
        List<sObject> records = new List<sObject>();
        List<String> fieldNames = new List<String>();
        //Map<String, Schema.SObjectField> fieldmap = Schema.SObjectType.Account.fields.getMap();

        Schema.SObjectType t = Schema.getGlobalDescribe().get(ObjectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        String fieldNamesLine = filelines[0].replaceAll('\n', '');
        fieldNamesLine = filelines[0].replaceAll('\r', '');
        fieldNames = fieldNamesLine.split(',');
        system.debug('FIELD NAMES SIZE::' + fieldNames.size());
        system.debug('FIELD NAMES LAST FIELD NAME::' + fieldNames[fieldNames.size()-1]);

        for (Integer i=1;i<fileValues.size();i++)
        {
            List<String> fl = fileValues[i];
            system.debug('VALUES FROM CSV READER::' + fl);
            //PA_IFB_Recruiting_Scoring__c temp = new PA_IFB_Recruiting_Scoring__c();
            sObject temp = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
            String[] fieldvalues = fl; //filelines[i].split(',');
            system.debug('FIELD VALUES LINE::' + filelines[i]);
            system.debug('FIELD VALUES SIZE::' + fieldvalues.size());
                system.debug('FIELD VALUES SECOND LAST VALUE::' + fieldvalues[fieldvalues.size()-1]);
            //system.debug('FIELD VALUES LAST VALUE::' + fieldvalues[fieldvalues.size()]);
            for (Integer j=0;j<fieldNames.size();j++){
                String fn = fieldNames[j];
                system.debug('INDEX::' + String.valueOf(j) + 'FFFFF  FieldName::' + fn + ' - Field Value::' + fieldvalues[j]);
                
                Schema.DescribeFieldResult f = r.fields.getMap().get(fn).getDescribe();
                system.debug('FFFFF  FieldName::' + fn + ' Field Type::' + f.getType());
                if(f.getType() == Schema.DisplayType.Double){
                    temp.put(fn, Double.valueOf(fieldvalues[j]));
                }else if(f.getType() == Schema.DisplayType.Integer){
                    temp.put(fn, Integer.valueOf(fieldvalues[j]));            
                }else if(f.getType() == Schema.DisplayType.Boolean){
                    temp.put(fn, Boolean.valueOf(fieldvalues[j]));            
                }else if(f.getType() == Schema.DisplayType.String || f.getType() == Schema.DisplayType.TEXTAREA ||
                        f.getType() == Schema.DisplayType.PICKLIST || f.getType() == Schema.DisplayType.EMAIL ||
                        f.getType() == Schema.DisplayType.MULTIPICKLIST || f.getType() == Schema.DisplayType.PHONE ||
                        f.getType() == Schema.DisplayType.URL ){
                    temp.put(fn, fieldvalues[j]);            
                }
            }
            
            records.add(temp);  
        }
        system.debug('SIZE OF RECORDS::' + records.size());
        insert records;
        return records.size();

    }
}