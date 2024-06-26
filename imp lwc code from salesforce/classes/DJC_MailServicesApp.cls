/*
    Rest service used by mailservices mobile app. 
*/
@RestResource(urlMapping='/MailServices/*')
global without sharing class DJC_MailServicesApp {   

    global static final String SUCCESS_MESSAGE = 'Success';

    @HttpPost
     global static ResponseWrapper createCaseAndPackages(Case ca, List<REWS_Package_Delivery__c> packages) {
        ResponseWrapper rw  = new ResponseWrapper();
        rw.isError = false;
        try{
            if(ca == null || packages == null){
                throw new ApplicationException('Case and package list cannot be null.');
            }
            if(ca.contactId == null){
                throw new ApplicationException('Contact field is required for package delivery cases.');
            } else if (ca.Type!='Mail Services'){
                throw new ApplicationException('Only cases of type \'Mail Services\' are allowed!.');
            }
            ca.RecordTypeId = REWS_Setting__c.getInstance().Case_Package_Delivery_Record_Type__c; 
            insert ca; 
            for(REWS_Package_Delivery__c pa : packages){
                pa.Case__c = ca.Id;
            }
            insert packages;
            rw.caseDetail = [select Id,caseNumber,Owner.Name,Status,Contact.Name from case where Id = : ca.Id];
        } catch(ApplicationException e){
            System.debug('Exception occured while creating case and packages.' + e.getMessage());
            rw.isError = true; 
            rw.errorMessage = e.getMessage(); 
        } catch(Exception e){
            System.debug('Exception occured while creating case and packages.' + e.getMessage());
            rw.isError = true; 
            rw.errorMessage = e.getMessage(); 
        }
        return rw;    
    }
    
    @HttpPatch
    global static String UpdateCurrentLocation(List<String> trackingNumbers, String currentLocation) {
        Set<Id> casesToUpdateSet = new Set<Id>(); 
        try{  
            if(currentLocation == null){
                throw new ApplicationException('Current Location field is required to update package location.');
            } else if(trackingNumbers == null){
                throw new ApplicationException('Please scan for packages before updating current location.');
            }
            //fetch packages. 
            for(REWS_Package_Delivery__c pack : [select Id,Case__c from REWS_Package_Delivery__c where REWS_Tracking_Number__c in : trackingNumbers]){
                casesToUpdateSet.add(pack.Case__c);
            }
            for(List<Case> cases : [select Id,REWS_Delivery_Location__c from Case where Id in : casesToUpdateSet]){
                for(Case c : cases){
                    c.REWS_Delivery_Location__c = currentLocation; 
                }
                update cases;
            }
            
        } catch(Exception e){
            System.debug('Exception occured while updating package location.' + e.getMessage());
            return e.getMessage();
        }
        return SUCCESS_MESSAGE; 
    }
    
    global class ResponseWrapper{
        global Case caseDetail;
        global String errorMessage;
        global boolean isError; 
    } 

}