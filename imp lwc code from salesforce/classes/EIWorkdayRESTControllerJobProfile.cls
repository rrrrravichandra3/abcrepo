/*
*****Written By: Charu Goyal
*****Created On: 06/28/2014
*****Description: Apex Class to upsert Job Profile related fields from EI Workday Metadata integration 
*/
@RestResource(urlMapping='/EIWorkdayMetadataJobProfile/')
global with sharing class EIWorkdayRESTControllerJobProfile{

@HttpPost  
global static Map<String, String> sendJSONPacket(){
    //Initialize the variables
    List<Job_Profile__c> jobProfileList = new List<Job_Profile__c>();
    Job_Profile__c jobProfile = new Job_Profile__c();
    List<Object> itemsList = new List<Object>();
    Id apiUserProfileId;
    
    //Send the HTTP Request
    RestRequest req = RestContext.request;
    
    //Deserialize the Request Body
    Map<String, Object> jsonInput = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
   
    //Verify that HTTP Request is being sent by a user with EI Metadata Integration Profile
    List<User> apiUserProfileList = new List<User>([select ProfileId from User where Name = 'PF SOA WD API Worker' and IsActive = true]); 
    if(!apiUserProfileList.IsEmpty()){
        apiUserProfileId = apiUserProfileList[0].ProfileId;
    }
    else{
        return generateAck('NOT OK,Profile not found');
    }
    
    if(userinfo.getProfileId() != apiUserProfileId && !Test.isRunningTest()){
        return generateAck('NOT OK, User has invalid profile');
    }
    
    if((String)jsonInput.get('businessObjectName') != 'jobProfile'){
        return generateAck('NOT OK, Invalid businessObjectName');
    }
       
    if((String)jsonInput.get('businessObjectEvent') != 'insert' && (String)jsonInput.get('businessObjectEvent') != 'update'){
        return generateAck('NOT OK, Not an Insert or Update operation');    
    }
    
    if(jsonInput.get('items') != null){
        itemsList = (List<Object>)jsonInput.get('items');
    }
    else{
        return generateAck('NOT OK, Items array has no elements');
    }
    //Since Items is a Map of key value pairs, fetch the pairs in a map
    Map<String,Object> items = (Map<String, Object>)itemsList[0];
    
    if((String)items.get('jobCode') != null && (String)items.get('jobCode') != '' ){
        jobProfile.Job_Code__c = (String)items.get('jobCode');
    }
    else{
        return generateAck('NOT OK, Received jobCode is null');
    }
    
    //Since jobFamily and exemptInfo are Maps of key value pairs, fetch the pairs in 2 maps
    List<Object> jobFamily = (List<Object>)items.get('jobFamilyIds');
    List<Object> exemptInfo = (List<Object>)items.get('exemptInfos');
    List<Object> compensationEligibilityRules = (List<Object>)items.get('compensationEligibilityRules');
    //If any of the item array values are blank, then ignore the field
    if((String)items.get('jobTitle') != null && (String)items.get('jobTitle') != ''){
        jobProfile.Name = (String)items.get('jobTitle');
    }
    if((Boolean)items.get('active') != null){
        jobProfile.Active__c = (Boolean)items.get('active');
    }
    if((String)items.get('jobGrade') != null && (String)items.get('jobGrade') != ''){
        jobProfile.Job_Grade__c = (String)items.get('jobGrade');
    }    
    if((String)items.get('summary') != null && (String)items.get('summary') != ''){
        jobProfile.Description__c = (String)items.get('summary');
    }    
        
    if((String)items.get('managementLevelId') != null && (String)items.get('managementLevelId') != ''){
        jobProfile.Management_Level__c = (String)items.get('managementLevelId');
    }    
    
    if(jobFamily.size() > 0){
        if(jobFamily[0] != null && jobFamily[0] != ''){
            List<Job_Family__c> jobFamilyList = [select Id from Job_Family__c where Name = :(String)jobFamily[0] and Active__c = true];
            if(!jobFamilyList.isEmpty()){
                jobProfile.Job_Family__c = jobFamilyList[0].Id;
            }
            else{
                return generateAck('NOT OK, Job Family is not found or is inactive');   
            }
        }
    }
    
    if(exemptInfo.size() > 0){
        for(Object o:exemptInfo){
            Map<String,Object> exemptCountry1 = (Map<String,Object>)o;    
            if(exemptCountry1.get('exemptCountry') != null && exemptCountry1.get('exemptCountry') != ''){
                if(exemptCountry1.get('exemptCountry') == 'US'){
                   Map<String,Object> exempt = (Map<String,Object>)o;    
                   if(exempt.get('exempt') != null){    
                       if((Boolean)exempt.get('exempt'))
                           jobProfile.U_S_Exempt_Non_Exempt__c = 'Exempt';
                       else 
                           jobProfile.U_S_Exempt_Non_Exempt__c = 'Non-Exempt';
                   }  
             }
            }
        }
     }
     
     if(compensationEligibilityRules.size() > 0 ){
        for(Object comp:compensationEligibilityRules){
            if(((String)comp).contains('Kokua Plan -')){
                Integer percentStartPosition = ((String)comp).indexOf('-') + 1;
                Integer percentEndPosition = ((String)comp).indexOf('%');
                if(((String)comp).substring(percentStartPosition,percentEndPosition) != null && ((String)comp).substring(percentStartPosition,percentEndPosition) != '' ){
                    jobProfile.Bonus_Target__c = integer.valueOf(((String)comp).substring(percentStartPosition,percentEndPosition).trim());
                }
                
            }
        }
    }
    
    //Since the batch size is always 1, the below list will always have a single element   
    jobProfileList.add(jobProfile);
    Boolean upsertErrored = upsertJobProfile(jobProfileList); 
    
    if(upsertErrored){
        return generateAck('NOT OK, Upsert Failed');
    }
    else{
        return generateAck('OK');
    }
}

public static boolean upsertJobProfile(List<Job_Profile__c> jobProfileList) {
    Map<String,Id> masterjobProfileList = new Map<String,Id>();
    List<Job_Profile__c> upsertJPList = new List<Job_Profile__c>();
    Boolean errorCode = false;
    if(!(jobProfileList.size() <= 0) && !(jobProfileList==null)){
        for(Job_Profile__c jP: jobProfileList){
               upsertJPList.add(jP);
        }   
    }
    if(upsertJPList.size() > 0){
        try{
            upsert upsertJPList Job_Code__c;
        }
        catch(Exception ex1){
            errorCode = true;
        }
    }
    return errorCode;
    
}
 
public static  Map<String, String> generateAck(String status){
    Map<String,String> ack = new Map<String,String>();
    if(status.contains('NOT')){
        ack.put('ack',status);
        return ack;
    }    
    else{
        ack.put('ack','OK');
        return ack;
    }
}
}